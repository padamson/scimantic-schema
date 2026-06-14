#!/usr/bin/env bash
# scripts/check-line-width.sh
#
# Fail if any *content* line in the schema exceeds the 72-column budget
# (see .yamllint). Long `description:` values must be folded with a `>-`
# block scalar so the frozen mdbook-listings snapshots don't force
# horizontal scroll in the book.
#
# `# CALLOUT:` marker comments are exempt: mdbook-listings strips them from
# the rendered listing (their text moves to a hover popover), so they never
# scroll in the book. This is the comment-aware enforcement yamllint can't
# do — its line-length rule can't exclude comments, which is why .yamllint
# keeps line-length at `level: warning` (editor/manual lens) and the
# blocking check lives here.
#
# Usage: scripts/check-line-width.sh [file ...]   (defaults to the schema)

set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

files=("${@:-schema/scimantic.yaml}")

awk '
  /# CALLOUT:/ { next }
  length > 72 {
    printf "%s:%d: %d cols (>72)\n", FILENAME, FNR, length
    flag = 1
  }
  END { exit flag }
' "${files[@]}"
