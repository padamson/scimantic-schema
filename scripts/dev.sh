#!/usr/bin/env bash
# scripts/dev.sh
#
# Simulate GitHub Pages locally with hot reload across:
#   - the schema source (`schema/scimantic.yaml`)
#   - the book source (`book/src/`, `book/*.toml`)
#   - PRODUCER source code (panschema, mdbook-listings, mdbook-admonish)
#
# Editing any of these triggers a full rebuild: refreshes producer debug
# binaries (incremental `cargo build`), then regenerates the book and
# versioned schema docs into `site/`. The producer binaries the rebuild
# uses are resolved via $PATH prepends in scripts/rebuild.sh, pointing
# at the freshly-built debug artifacts each time.
#
# With `live-server` (npm) installed, the browser auto-refreshes after
# each rebuild. Otherwise falls back to `python3 -m http.server`, where
# you refresh manually.
#
# Usage:
#   ./scripts/dev.sh                 # PORT=8000 (default)
#   PORT=8080 ./scripts/dev.sh
#   SKIP_PRODUCER_BUILD=1 ./scripts/dev.sh
#       Don't build or watch the producers; use the binaries already on
#       PATH and only regenerate the site on schema/book changes. Use when
#       you're iterating on a producer (e.g. panschema) in its own repo and
#       don't want its slow `cargo build` (linking a ~35 MB debug binary) on
#       every scimantic change. After rebuilding the producer yourself,
#       trigger a site refresh by touching a watched file
#       (e.g. `touch schema/scimantic.yaml`).
#
# Stop with Ctrl+C.
#
# Requires (in this repo):
#   - mdbook, mdbook-listings, mdbook-admonish, panschema on PATH —
#     ideally as aliases pointing at producer target/debug binaries
#     (see README "Dogfooding the tooling").
#   - watchexec (general-purpose file watcher; cargo-watch is the wrong
#     tool here because scimantic-schema is not a Cargo project):
#       cargo install watchexec-cli
#
# Requires (in adjacent producer repos under ~/src/github-padamson/):
#   - panschema/, mdbook-listings/, mdbook-admonish/ cloned with working
#     trees. Any missing producer is skipped with a warning.
#
# Optional:
#   - live-server (npm) for in-browser auto-reload:
#       npm install -g live-server

set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

PORT="${PORT:-8000}"
export PORT

# When set, skip building/watching the producers (panschema, mdbook-listings,
# mdbook-admonish); use the binaries on PATH and only regenerate the site.
SKIP_PRODUCER_BUILD="${SKIP_PRODUCER_BUILD:-}"
export SKIP_PRODUCER_BUILD

# --- Tool availability ---

missing=()
for cmd in mdbook mdbook-listings panschema watchexec; do
  command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
done
if [ "${#missing[@]}" -gt 0 ]; then
  echo "ERROR: required tools not on PATH:"
  for c in "${missing[@]}"; do echo "  - $c"; done
  echo ""
  echo "Setup:"
  echo "  - mdbook / mdbook-listings / mdbook-admonish / panschema:"
  echo "      see README 'Dogfooding the tooling' for the alias pattern"
  echo "  - watchexec: cargo install watchexec-cli"
  exit 1
fi

# --- Build watch path list ---

# This repo's source/config files.
watch_args=(
  --watch schema
  --watch book/src
  --watch book/book.toml
  --watch book/listings.toml
  --watch panschema-publish.toml
)

# Producer source paths. For each producer repo present locally, watch:
#   - top-level Cargo.toml
#   - top-level src/ if present (single-crate repos: mdbook-listings, mdbook-admonish)
#   - any workspace sub-crate's Cargo.toml + src/ (panschema's workspace
#     has panschema/, panschema-viz/)
# Crucially do NOT watch the whole repo — target/ would create a rebuild loop.
producer_dirs=()
for producer in panschema mdbook-listings mdbook-admonish; do
  # SKIP_PRODUCER_BUILD: don't watch producer source — you're driving the
  # producer's build in its own repo, so leave it out of this loop.
  [ -n "${SKIP_PRODUCER_BUILD:-}" ] && break
  repo="$HOME/src/github-padamson/$producer"
  [ -d "$repo" ] || continue

  [ -f "$repo/Cargo.toml" ] && watch_args+=( --watch "$repo/Cargo.toml" )
  [ -d "$repo/src" ] && watch_args+=( --watch "$repo/src" )

  # Workspace sub-crates
  for sub_toml in "$repo"/*/Cargo.toml; do
    [ -f "$sub_toml" ] || continue
    [ "$sub_toml" = "$repo/Cargo.toml" ] && continue
    sub_dir="$(dirname "$sub_toml")"
    watch_args+=( --watch "$sub_toml" )
    [ -d "$sub_dir/src" ] && watch_args+=( --watch "$sub_dir/src" )
  done

  producer_dirs+=("$producer")
done

# --- Initial build ---

scripts/rebuild.sh

# --- HTTP server ---

if command -v live-server >/dev/null 2>&1; then
  echo ""
  echo "Starting live-server on http://localhost:$PORT/ (browser auto-reload)"
  (cd site && live-server --port="$PORT" --no-browser --quiet) &
else
  echo ""
  echo "Starting python3 -m http.server on http://localhost:$PORT/"
  echo "  (no auto-reload; refresh the browser manually after each rebuild)"
  echo "  Tip: npm install -g live-server  # for browser auto-reload"
  (cd site && python3 -m http.server "$PORT" >/dev/null 2>&1) &
fi
SERVER_PID=$!

cleanup() {
  echo ""
  echo "Stopping server (PID $SERVER_PID)"
  kill "$SERVER_PID" 2>/dev/null || true
}
# EXIT covers all paths (Ctrl+C, set -e bail-out, normal exit).
trap cleanup EXIT

# --- Watch + rebuild ---

echo ""
echo "Watching for changes in:"
echo "  schema/, book/src/, book/*.toml, panschema-publish.toml"
for p in "${producer_dirs[@]}"; do
  echo "  $p source (producer dogfood)"
done
[ -n "${SKIP_PRODUCER_BUILD:-}" ] && echo "  (producers skipped — SKIP_PRODUCER_BUILD set; using binaries from PATH)"
echo ""
echo "Edit any of those to trigger a rebuild. Ctrl+C to stop."
echo ""

watchexec \
  --debounce 500ms \
  --no-vcs-ignore \
  --clear \
  "${watch_args[@]}" \
  -- scripts/rebuild.sh
