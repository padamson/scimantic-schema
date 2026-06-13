#!/usr/bin/env bash
# scripts/rebuild.sh
#
# Rebuild the dogfood-loop site: refresh producer debug binaries
# (panschema, mdbook-admonish) via `cargo build`, then rebuild the
# combined site (book + versioned schema docs) into `site/`. mdbook-listings
# is a published crates.io dependency, not a local-checkout producer.
#
# Mirrors what `.github/workflows/docs.yml` does in CI (minus the deploy
# step), but with producer-source changes flowing in via the local debug
# binaries the user's shell aliases point at (see README "Dogfooding the
# tooling"). Called by `scripts/dev.sh` for the initial build
# and re-invoked on every file change via `cargo-watch`.
#
# Set SKIP_PRODUCER_BUILD=1 to skip the producer `cargo build` step and
# regenerate the site from the producer binaries already on PATH — useful
# while iterating on a producer (e.g. panschema) in its own repo, so its
# slow build doesn't run on every scimantic change.

set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

ts() { date '+%H:%M:%S'; }

# Shell aliases (e.g. `alias panschema=.../target/debug/panschema` in
# ~/.zshrc) only load in *interactive* shells — non-interactive scripts
# like this one resolve `panschema`, `mdbook-admonish` via $PATH, which
# would hit the cargo-installed releases in ~/.cargo/bin/ instead of the
# dogfood-fresh debug binaries.
#
# Prepend each producer's target/debug to PATH so script invocations of
# the producer use the same binaries the user's interactive shell does.
for producer in panschema mdbook-admonish; do
  debug_dir="$HOME/src/github-padamson/$producer/target/debug"
  if [ -x "$debug_dir/$producer" ]; then
    export PATH="$debug_dir:$PATH"
  fi
done

echo ""
if [ -n "${SKIP_PRODUCER_BUILD:-}" ]; then
  echo "==> [$(ts)] Skip producer rebuild (SKIP_PRODUCER_BUILD set) — using binaries on PATH."
else
  echo "==> [$(ts)] Refresh producer debug binaries (no-op if no change):"

  # Each producer: if the repo exists locally, `cargo build` it. Incremental
  # build is a few hundred ms when nothing changed; updates target/debug/
  # (the path the user's shell aliases resolve to) when source changed.
  for producer in panschema mdbook-admonish; do
    repo="$HOME/src/github-padamson/$producer"
    if [ -d "$repo" ]; then
      echo "  - $producer"
      (cd "$repo" && cargo build 2>&1 | tail -3) || {
        echo "    ❌ $producer build failed — bailing this rebuild cycle."
        exit 1
      }
    else
      echo "  - $producer: ⚠ not cloned at $repo — skipping"
    fi
  done
fi

echo ""
echo "==> [$(ts)] Rebuild the combined site:"

# 1. Book — outputs to book/build/
(
  cd book
  mdbook-listings install >/dev/null 2>&1
  mdbook build
)

# 2. Versioned schema docs — site/schema/{v0.1.0,v0.2.0,main,current}/
# --edge-from-worktree: render /schema/main/ from the working tree
# rather than `git show main:schema/scimantic.yaml`, so local edits
# appear immediately. CI (.github/workflows/docs.yml) deliberately
# omits this flag so deployed docs always reflect committed state.
panschema publish --edge-from-worktree

# 3. Combine — book at site/ root, schema docs already at site/schema/
mkdir -p site
cp -r book/build/* site/

echo "==> [$(ts)] Done. Reload http://localhost:${PORT:-8000}/"
