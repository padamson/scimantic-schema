#!/usr/bin/env bash
# scripts/install-assets.sh
#
# Generate the CSS/JS assets the book needs to build: mdbook-admonish,
# mdbook-listings, and the mdbook-panschema schema-link button. These
# are produced (not source) files — intentionally gitignored (see
# .gitignore) — so a fresh clone has none of them and a bare
# `cd book && mdbook build` fails on the missing `mdbook-admonish.css`
# until this runs once. (book/soft-wrap.css is hand-authored, NOT
# generated, and stays committed.)
#
# Run it once after cloning (and any time the assets go missing). The
# dev loop (scripts/rebuild.sh) regenerates them on its own, so you
# only need this for the standalone `mdbook build` / `mdbook serve`
# path.
#
# Assumes `mdbook-admonish`, `mdbook-listings`, and `mdbook-panschema`
# are already on PATH — see README "Dogfooding the tooling":
# mdbook-listings from crates.io (released), mdbook-admonish from the
# feat/mdbook-0.5-compat fork, mdbook-panschema from the panschema
# workspace. This script only generates the book assets from those
# binaries; it does not install the binaries themselves. Mirrors the
# "Generate book assets" step in .github/workflows/docs.yml.

set -euo pipefail
cd "$(git rev-parse --show-toplevel)/book"

mdbook-admonish install .
mdbook-listings install
mdbook-panschema install
