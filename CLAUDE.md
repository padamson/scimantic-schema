# scimantic-schema

A [LinkML](https://linkml.io) schema for representing the scientific
method as provenance chains (questions → hypotheses → evidence →
conclusions and the acts connecting them), grounded in BFO 2020 and
the Common Core Ontologies (CCO).

The repo is two things at once:

- **`schema/scimantic.yaml`** — the schema artifact itself.
- **`book/`** — *Building scimantic-schema*, an mdbook that is the
  public log of rebuilding the schema from scratch as **v0.3.0**,
  following *Ontology Development 101* (Noy & McGuinness, 2001 — "N&M")
  adapted to LinkML. Each N&M step gets a chapter; the schema grows
  incrementally with **frozen listings** embedded at each stage.

v0.3.0 is an in-progress ground-up rebuild (`version: 0.3.0-dev`).
v0.1.0 was PROV-O-grounded; v0.2.0 retrofitted BFO/CCO onto it; v0.3.0
grounds in BFO/CCO from first principles. Prior releases are reachable
via their git tags (`v0.1.0`, `v0.2.0`).

## Chapter ↔ N&M step

Chapters map to the seven N&M steps and live at
`book/src/chNN-<kebab-title>.md`, listed in `book/src/SUMMARY.md`:

1. Determine domain and scope · 2. Reuse existing ontologies ·
3. Enumerate important terms · 4. Define classes and hierarchy ·
5. Define slots · 6. Facets (`slot_usage`) · 7. Instances + validate

(The Introduction is an unnumbered prefix chapter — `introduction.md`
— so chapter N = N&M step N.) Match the
existing voice: design discussion aimed at a reader comfortable with
LinkML and ontology basics, N&M quotes in `admonish quote` blocks,
external claims backed by citations.

## Authoring with mdbook-listings

This repo uses the **mdbook-listings** plugin, installed at project
scope (see `.claude/settings.json`). Its bundled skill documents the
full mechanics — `freeze`/`list`, the `{{#include}}` / `{{#callout}}`
/ `{{#diff}}` directives, inline `# CALLOUT:` markers vs. sidecar
TOML, and the tag/SHA-256 identity model. **Consult that skill
(`references/cli.md`, `references/directives.md`) for how the tool
works** — this section records only what's specific to *this* repo.

The book embeds **frozen snapshots** of `schema/scimantic.yaml` so a
later edit can't silently change what a chapter renders. Repo
conventions on top of the plugin:

- **Freeze from `book/`**, source `../schema/scimantic.yaml`, tag
  `scimantic-yaml-v<N>`. Each chapter that advances the schema bumps
  the tag so earlier chapters keep pointing at the snapshot they
  froze:
  `cd book && mdbook-listings freeze ../schema/scimantic.yaml --tag scimantic-yaml-v2 --force`
- **Callouts on files we author here** (e.g. `schema/scimantic.yaml`)
  go *inline* as `# CALLOUT:` markers — never sidecar TOML, which is
  reserved for generated/third-party/no-comment-syntax listings.
- **Integrity check:** `mdbook build` exiting 0 already fails on a
  missing `{{#callout}}` label or a broken `{{#include}}`;
  `mdbook-listings verify --book-root book` additionally checks every
  frozen listing against its recorded SHA-256 (also enforced by the
  pre-commit hook).

### Dev loop (`scripts/dev.sh`) and the freeze foot-gun

`scripts/dev.sh` watches `schema/`, `book/src/`, and `book/*.toml`
and rebuilds the combined `site/` on change (via `scripts/rebuild.sh`,
which also runs `mdbook-listings install` to refresh callout CSS/JS).
But **editing `schema/scimantic.yaml` does not re-freeze the listing**
— a frozen listing is a point-in-time snapshot by design. The watcher
will rebuild from the *old* frozen bytes, so callout/listing changes
won't appear until you re-freeze. The loop:

1. Edit `schema/scimantic.yaml` (markers and all).
2. `cd book && mdbook-listings freeze ../schema/scimantic.yaml --tag <tag> --force`
   (writing `book/src/listings/<tag>.yaml` — itself watched — triggers the rebuild).
3. Hard-refresh the browser (Cmd+Shift+R) to bust cached CSS/JS/HTML.

If callouts seem missing, suspect a **stale `site/`** first: confirm
the freshly built `book/build/<chapter>.html` has `callout-badge`
elements before debugging anything deeper.

For anything not covered above, defer to the installed mdbook-listings
plugin skill, then `mdbook-listings <cmd> --help`.

## Building

```
cd book && mdbook serve   # local preview with live reload
cd book && mdbook build   # output to book/build/
```

Preprocessors must be on `PATH`: `mdbook-listings`, and the
`mdbook-admonish` fork (`feat/mdbook-0.5-compat`). The published docs
site (schema HTML + the book) is built and deployed by
`.github/workflows/docs.yml` via the panschema toolchain on push to
`main` and on `v*` tags.

## Conventions

- **Trunk-based on `main`.** Commit directly to `main`; don't propose
  feature branches as a workflow.
- **Schema edits are chapter-scoped.** When a chapter advances the
  schema, freeze a new listing tag in the same change so the prose and
  the snapshot stay consistent.
- **External grounding is by URI, not import.** BFO/CCO/etc. are
  referenced via `class_uri`/`slot_uri` + prefixes (and mapping
  annotations), *not* LinkML `imports:` (which is for other LinkML
  schemas — only `linkml:types` is imported).
- **Deferrals are tracked in the target chapter's scaffold.** When
  prose defers work to a later chapter or N&M step ("deferred to
  Chapter 5", "Step 5 work", "Chapter 7 will revisit"), add a
  matching `[ ]` TODO line in that chapter's draft `.md` scaffold,
  inside an HTML-comment `CARRIED-IN DEFERRALS` block (the
  `ch05-slots.md` pattern), citing the source chapter/section. Write
  the prose deferral and the scaffold TODO *together* so nothing
  promised is dropped. Draft scaffolds stay out of `SUMMARY.md`
  until the chapter is written; the HTML comments never render.
  (Within-chapter "next increment" work — not yet deferred to a
  *later* chapter — stays in the buildout plan, not these blocks.)
