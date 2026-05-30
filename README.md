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

## Related work

This schema is consumed by:

- [scimantic-extension](https://github.com/padamson/scimantic-extension) — VS Code extension and runtime
- [t2t](https://github.com/padamson/t2t) — book-and-app project on building a "trunk-to-theory" knowledge system

Both will consume tagged versions of this repo via [panschema](https://github.com/padamson/panschema) including projecting the schema into whatever target format
they need (e.g., Rust types).

## License

[CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) — see [LICENSE](LICENSE).
