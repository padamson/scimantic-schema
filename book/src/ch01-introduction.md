# Introduction

The `scimantic` schema is a [LinkML](https://linkml.io) schema for representing the
**scientific method** as provenance chains — questions, hypotheses,
evidence, conclusions, and the acts that connect them.

This book is the public log of rebuilding that schema from scratch in its third release (v0.3.0), guided by the methodology in *[Ontology Development 101](https://protege.stanford.edu/publications/ontology_development/ontology101.pdf)* (Noy & McGuinness, 2001 -- or *N&M*) adapted to *[LinkML Schema](https://linkml.io/linkml/schemas/index.html)* terminology and the [panschema](https://github.com/padamson/panschema) toolchain.

## Schema versions

| Version | Direction | Schema docs |
|---|---|---|
| **v0.1.0** | Initial cut grounded in [PROV-O](https://www.w3.org/TR/prov-o/) | [/schema/v0.1.0/](/schema/v0.1.0/) |
| **v0.2.0** | Re-grounded in [BFO 2020](https://github.com/BFO-ontology/BFO-2020) (ISO/IEC 21838-2:2020) and the [Common Core Ontologies](https://github.com/CommonCoreOntology/CommonCoreOntologies) | [/schema/v0.2.0/](/schema/v0.2.0/) |
| **main** (edge) | The v0.3.0 ground-up rebuild in progress — see this book for the journey | [/schema/main/](/schema/main/) |
| **current** | Whichever release is currently the recommended target | [/schema/current/](/schema/current/) |

v0.2.0 was an attempt to retrofit BFO/CCO grounding onto v0.1.0's
PROV-O-derived structure. The exercise was somewhat successful, but the path to get there was
indirect and imperfect. We translated PROV relations to CCO process-participant
relations after the fact rather than starting from BFO categories.
That experience motivated this rebuild using N&M as a guide.

## What this book does

It rebuilds the `scimantic` schema from scratch as v0.3.0, using the seven steps
of N&M as scaffolding:

1. Determine the domain and scope
2. Consider reusing existing ontologies
3. Enumerate important terms
4. Define classes and the class hierarchy
5. Define properties (slots)
6. Define facets (`slot_usage`)
7. Create instances and validate

Each step gets a chapter. The schema is built incrementally, with
frozen snapshots of `schema/scimantic.yaml` embedded at each stage so
the reader sees exactly where the schema was when that chapter was
written. Later chapters can call back to specific tagged listings
without ambiguity.

## How to read this book

- **Frozen listings** are exact snapshots of the schema at a moment in
  time, embedded inline via [mdbook-listings](https://github.com/padamson/mdbook-listings).
  The tag (*e.g.,* `scimantic-yaml-v1`) is the identity; the SHA-256
  in `book/listings.toml` is the integrity check.
- **Inline callouts** annotate specific lines or regions of a listing, 
  explaining design choices at the point they show -- in the schema itself or 
  in generated artifacts (*e.g.,* `.ttl`, `.json`).
- **Schema documentation** (rendered HTML class cards, graph viz,
  navigation) lives at the URLs above. The book describes the *journey*;
  the schema docs describe the *destination*.

## What this book doesn't do

It doesn't teach LinkML or BFO/CCO from scratch. There are better
resources for that. It references them as needed and links out for
depth. The audience is someone comfortable enough with LinkML and
ontology basics to follow design discussion at the level of "should
`Question` subclass `cco:DirectiveInformationContentEntity` or
`cco:DescriptiveInformationContentEntity`?" not someone learning what `slots:` means."
