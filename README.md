# scimantic-schema

A minimal domain ontology for representing the scientific method as
provenance chains, authored as a [LinkML](https://linkml.io) schema.

## Status

Pre-1.0. The LinkML schema at [schema/scimantic.yaml](schema/scimantic.yaml)
is the single authoritative source; OWL/SHACL/types/JSON Schema/HTML outputs
are all generated downstream by [panschema](https://github.com/padamson/panschema).
This repo is panschema's flagship dogfood case — expect the schema, the
generators, and the layout to co-evolve in lockstep until 1.0.

## Layout

```
schema/
  scimantic.yaml     # source of truth (LinkML)
```

`generated/` and per-format subdirectories will land as panschema gains the
writers to populate them (see the [feature roadmap discussion](#related-work)).

## Versioning

The schema's `version:` field is the source of truth. Git tags will match
the schema version (e.g. `v0.1.3` ↔ `version: 0.1.3`).

## What's in here

The schema models the scientific method as a chain of [PROV-O](https://www.w3.org/TR/prov-o/)
entities (`Question`, `Hypothesis`, `Evidence`, `Conclusion`, ...) and
activities (`QuestionFormation`, `LiteratureSearch`, `Experimentation`, ...),
re-using established vocabularies rather than inventing new ones:

- [PROV-O](https://www.w3.org/TR/prov-o/) for provenance relations
- [DCAT](https://www.w3.org/TR/vocab-dcat-3/) for dataset metadata
- [W3C Web Annotation](https://www.w3.org/TR/annotation-model/) for text selectors over source documents
- [URREF](https://github.com/adelphi23/urref) for uncertainty representation

A future workstream will re-ground the schema in [BFO](https://github.com/BFO-ontology/BFO-2020)
(ISO/IEC 21838-2:2020) and the [Common Core Ontologies](https://github.com/CommonCoreOntology/CommonCoreOntologies)
so the domain hangs off a recognized upper-level/mid-level backbone.

## Related work

This schema is consumed by:

- [scimantic](https://github.com/padamson/scimantic) — VS Code extension and runtime
- t2t — book-and-app project on building a "trunk-to-theory" knowledge system

Both consume tagged versions of this repo (typically as a git submodule)
and call panschema to project the schema into whatever target format
they need (Rust types, Python types, SHACL shapes, JSON Schema, etc.).

## License

[CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) — see [LICENSE](LICENSE).
