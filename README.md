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
  scimantic.yaml     # source of truth (LinkML)
```

`generated/` and per-format subdirectories will land as panschema gains the
writers to populate them (see the [feature roadmap discussion](#related-work)).

## Versioning

The schema's `version:` field is the source of truth. Git tags will match
the schema version (e.g. `v0.2.0` ↔ `version: 0.2.0`).

## What's in here

The schema models the scientific method as a chain of information content
entities (`Question`, `Hypothesis`, `Evidence`, `Conclusion`, ...) and
planned acts (`QuestionFormation`, `LiteratureSearch`, `Experimentation`,
...), grounded in a recognized upper-level/mid-level ontology backbone:

- [BFO 2020](https://github.com/BFO-ontology/BFO-2020) (ISO/IEC 21838-2:2020)
  as the upper-level ontology — every domain class sits under a BFO category
  (continuant / occurrent, ICE / process, quality, etc.)
- [Common Core Ontologies](https://github.com/CommonCoreOntology/CommonCoreOntologies)
  for mid-level alignment — domain entities subclass CCO Information Content
  Entity (and its `Descriptive` / `Designative` / `Directive` subclasses);
  activities subclass CCO `Planned Act` and its specializations
  (`Act of Observation`, `Act of Estimation`, `Act of Information Processing`,
  `Act of Planning`)
- [DCAT](https://www.w3.org/TR/vocab-dcat-3/) for dataset metadata
- [W3C Web Annotation](https://www.w3.org/TR/annotation-model/) for text
  selectors over source documents
- [URREF](https://github.com/adelphi23/urref) for uncertainty representation
  (reified as BFO qualities)

Provenance is expressed via the CCO process-participant relations
(`hasInput`, `hasOutput` / `isOutputOf`, `hasAgent`) and BFO `preceded by`,
rather than PROV-O. Entity-to-entity derivation is always traversed
through the act that did the deriving (e.g., a `Result` is the output of an
`Analysis` whose input is a `Dataset`), not via shortcut relations.

> **v0.2.0 — re-grounding in BFO/CCO.** v0.1.0 grounded the schema in PROV-O;
> v0.2.0 replaces that with BFO + CCO. PROV mappings are not included in this
> release, but can be added back in a future release as `close_mappings` if 
> downstream users identify a need to support PROV tooling.

## Authoring

For local iteration on the schema with rendered HTML feedback.

### Install panschema

```bash
cargo install wasm-pack    # build prerequisite (panschema's build.rs runs wasm-pack)
cargo install --git https://github.com/padamson/panschema panschema
```

### Build the HTML docs

```bash
panschema generate -i schema/scimantic.yaml -o site/ -f html
```

Open `site/index.html` in a browser.

### Hot-reload server

```bash
panschema serve -i schema/scimantic.yaml
```

Open <http://localhost:3000>. Edits to `schema/scimantic.yaml` trigger a regenerate.

Other formats (`ttl`, `jsonld`, `rdfxml`, `ntriples`) are available via `--format`.

## Related work

This schema is consumed by:

- [scimantic](https://github.com/padamson/scimantic) — VS Code extension and runtime
- [t2t](https://github.com/padamson/t2t) — book-and-app project on building a "trunk-to-theory" knowledge system

Both will consume tagged versions of this repo via [panschema](https://github.com/padamson/panschema) including projecting the schema into whatever target format
they need (e.g., Rust types).

## License

[CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) — see [LICENSE](LICENSE).
