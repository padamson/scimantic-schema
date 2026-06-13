# scimantic-schema

A minimal domain ontology for representing the scientific method as
provenance chains, authored as a [LinkML](https://linkml.io) schema.

## Status

Pre-1.0. The LinkML schema at [schema/scimantic.yaml](schema/scimantic.yaml)
is the single authoritative source; OWL/SHACL/types/JSON Schema/HTML outputs
are all generated downstream by [panschema](https://github.com/padamson/panschema).
This repo is panschema's flagship dogfood case — expect the schema, the
generators, and the layout to co-evolve in lockstep until 1.0 (and beyond).

## Layout

```
schema/
  scimantic.yaml          # source of truth (LinkML)
book/                     # mdbook documenting the v0.3.0 rebuild
scripts/
  dev.sh                  # local hot-reload preview (book + versioned schema docs)
  rebuild.sh              # one-shot rebuild (mirrors CI)
panschema-publish.toml    # panschema's release + publish manifest
.github/workflows/
  docs.yml                # builds book + versioned schema docs; deploys to Pages
```

## Versioning

The schema's `version:` field is the source of truth. Release tags
match the version (e.g. `v0.2.0` ↔ `version: 0.2.0`). Between
releases, the version field carries a `-dev` suffix (e.g.,
`0.3.0-dev` while v0.3.0 is being rebuilt).

## What's in here

The schema models the scientific method as provenance chains —
questions, hypotheses, evidence, conclusions, and the acts that
connect them.

The canonical "what's in the schema today" reference is the rendered
class graph at [`/schema/current/`](https://padamson.github.io/scimantic-schema/schema/current/).
For the design rationale and chapter-by-chapter rebuild journey, see
the [book](https://padamson.github.io/scimantic-schema/) at the site
root.

> **v0.3.0 is a ground-up rebuild in progress.** v0.1.0 grounded the
> schema in PROV-O; v0.2.0 attempted to retrofit BFO/CCO grounding
> onto the PROV-derived structure; v0.3.0 starts fresh, applying Noy
> & McGuinness's *Ontology Development 101* (adapted to LinkML) from
> Step 1. The book documents the rebuild; the schema on `main` is
> currently a minimal stub being populated chapter by chapter. The
> last released class graph is at
> [`/schema/v0.2.0/`](https://padamson.github.io/scimantic-schema/schema/v0.2.0/).

## Authoring

The combined book + versioned schema docs run locally via:

```bash
./scripts/dev.sh
# → http://localhost:8000/
```

This builds the book at `/` and panschema-published versioned schema
docs at `/schema/{v0.1.0,v0.2.0,main,current}/`, serves the combined
site over HTTP, and rebuilds on any save in `schema/`, `book/`, or
(if you have the producer repos cloned locally — see "Dogfooding the
tooling" below) `panschema/`, `mdbook-listings/`, `mdbook-admonish/`
sources.

### Install once

```bash
# Schema + book tooling
cargo install wasm-pack --locked   # build prerequisite for panschema
cargo install --git https://github.com/padamson/panschema panschema --locked
cargo install --git https://github.com/padamson/mdbook-listings --locked
cargo install --git https://github.com/padamson/mdbook-admonish \
  --branch feat/mdbook-0.5-compat --locked
cargo install mdbook --locked
cargo install watchexec-cli --locked   # required by scripts/dev.sh

# Optional: in-browser auto-reload (otherwise refresh manually after each rebuild)
npm install -g live-server
```

### Other formats

panschema can also emit `ttl`, `jsonld`, `rdfxml`, `ntriples` via
`--format <fmt>`. See `panschema generate --help`.

## Dogfooding the tooling

This repo is [panschema](https://github.com/padamson/panschema)'s flagship
dogfood case, and also exercises the `mdbook-admonish` fork. (mdbook-listings
is a *published* crates.io dependency, pinned in CI and consumed like any
release — it's no longer a local-checkout producer here. Re-add it below if
you pick its development back up.) When you iterate on a producer's source,
`scripts/dev.sh` can rebuild it and regenerate the site from the fresh
binary, so producer changes show up live.

### The alias pattern

`scripts/rebuild.sh` invokes the local-checkout producers by name
(`panschema`, `mdbook-admonish`). To make both the scripts and your
interactive shell use your **local debug builds** instead of the
`cargo install`-ed releases, clone them under `~/src/github-padamson/` and
alias each to its `target/debug` binary:

```zsh
# ~/.zshrc
alias panschema="$HOME/src/github-padamson/panschema/target/debug/panschema"
alias mdbook-admonish="$HOME/src/github-padamson/mdbook-admonish/target/debug/mdbook-admonish"
```

Aliases load only in interactive shells; `rebuild.sh` re-derives the same
paths via `$PATH` prepends so non-interactive runs match.

### Three modes

- **Authoring only** — not touching the producers, just writing the schema
  and book against the released binaries. `./scripts/dev.sh`; producers you
  haven't cloned are skipped.
- **Light producer dogfooding** — an occasional producer tweak where you
  want edit-producer → site auto-rebuilds. `./scripts/dev.sh` (the default:
  it watches and `cargo build`s the producers). Fine when their builds are
  fast or infrequent.
- **Heavy producer development** — you're building out a producer (e.g.
  panschema features) and its per-change `cargo build` (linking panschema's
  ~35 MB debug binary) is too slow on every edit:

  ```bash
  SKIP_PRODUCER_BUILD=1 ./scripts/dev.sh
  ```

  dev.sh stops watching and building producers; you drive the producer's
  build in its own repo, then `touch schema/scimantic.yaml` to regenerate
  the site with the new binary.

> **panschema wasm note:** editing `panschema-viz/src` (the graph viz) does
> not rebuild the embedded wasm via `cargo build` — `build.rs` only runs
> `wasm-pack` when `panschema-viz/pkg/` is missing. Rebuild it with
> `wasm-pack build` in `panschema-viz`, or `rm -rf panschema-viz/pkg`.

## Related work

This schema is consumed by:

- [scimantic-extension](https://github.com/padamson/scimantic-extension) — VS Code extension and runtime
- [t2t](https://github.com/padamson/t2t) — book-and-app project on building a "trunk-to-theory" knowledge system

Both will consume tagged versions of this repo via [panschema](https://github.com/padamson/panschema) including projecting the schema into whatever target format
they need (e.g., Rust types).

## License

[CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) — see [LICENSE](LICENSE).
