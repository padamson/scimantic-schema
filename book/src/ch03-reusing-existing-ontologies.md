# Reusing Existing Ontologies

This chapter applies **Step 2** of *Ontology Development 101* (Noy &
McGuinness, 2001) to scimantic.

```admonish quote title="Noy & McGuinness 2001 — §Step 2"
It is almost always worth considering what someone else has done and
checking if we can refine and extend existing sources for our
particular domain and task. Reusing existing ontologies may be a
requirement if our system needs to interact with other applications
that have already committed to particular ontologies or controlled
vocabularies. [...] There are libraries of reusable ontologies on the
Web and in the literature. [...]

For this guide however we will assume that no relevant ontologies
already exist and start developing the ontology from scratch.
```

That last sentence is where scimantic parts ways with the guide. N&M
set reuse aside for pedagogy. They build their wine ontology from scratch because
it is easier to *teach* that way. scimantic makes the opposite choice on
purpose: the entire motivation for the v0.3.0 rebuild (Chapter 1) was
that v0.2.0 *retrofitted* an upper-ontology grounding after the fact,
and the fix is to **start from reused foundations** rather than bolt
them on later. So this chapter is load-bearing in a way N&M's Step 2
is not. It decides, term-source by term-source, what scimantic
imports versus invents, and the decisions here constrain every
chapter that follows.

The output of this chapter is deliberately small: a **prefix block**
and an unchanged `imports:` list in `schema/scimantic.yaml`.
Classes themselves come later (Steps 3–6). The prefix block is the
machine-readable record of the decisions below. Throughout, **reuse**
means *naming* scimantic's classes against foreign IRIs rather than
copying those ontologies. The LinkML mechanics of how that naming works
are described below, after the reuse decisions, just before the listing.

## The foundation: BFO 2020 and CCO

Two ontologies are not just *reused* but *foundational*. Every
scimantic class will ultimately subclass something in them.

**[Basic Formal Ontology (BFO) 2020](https://github.com/BFO-ontology/BFO-2020)**
is a top-level ontology standardized as
[ISO/IEC 21838-2:2020](https://www.iso.org/standard/74572.html) and
the shared upper layer of the OBO Foundry. Its job is to fix a small
set of rigorous categories for *what exists*. Of those, the one
scimantic leans on hardest is the **continuant / occurrent** split.

```admonish info title="Jargon: continuant and occurrent"
The foundational distinction every upper ontology draws (BFO's labels
here; DOLCE calls them *endurant* and *perdurant*). A **continuant**
persists through time while keeping its identity: a document, a person, a
dataset. An **occurrent** unfolds *in* time, its parts never all present
at once: a search, an experiment, an assessment.
```

scimantic's domain is a *process*:
questions get formed, evidence gets gathered, conclusions get drawn.
So the continuant/occurrent distinction is the backbone the schema
needs. We reuse BFO via the `obo:` prefix; BFO
terms are opaque IRIs of the form `obo:BFO_0000015` (process). See
Arp, Smith & Spear, *[Building Ontologies with Basic Formal
Ontology](https://mitpress.mit.edu/9780262527811/building-ontologies-with-basic-formal-ontology/)*
(MIT Press, 2015) for the rationale behind those categories.

**[Common Core Ontologies (CCO)](https://github.com/CommonCoreOntology/CommonCoreOntologies)**
is a suite of mid-level ontologies that extend BFO, bridging the gap
between BFO's abstractions and domain-specific vocabularies. CCO is
where scimantic gets most of the general categories it would otherwise
have to reinvent. Between them, BFO and CCO supply the handful of kinds
the whole schema is built from, each one a category scimantic commits
to reuse:

- **Artifacts** — the information itself: Question, Hypothesis,
  Evidence, Premise, Result, Conclusion. Grounded in CCO **Information
  Content Entity** (ICE, `cco:ont00000958`) and its descriptive /
  designative / directive subdivisions.
- **Acts** — the agentive processes that produce and transform
  artifacts: QuestionFormation, LiteratureSearch, Experimentation,
  Analysis. Grounded in CCO **Planned Act** (`cco:ont00000228`). They
  count as *planned* acts because each carries out a method or protocol
  (itself a directive ICE) that prescribes it.
- **States** — conditions that hold steady over an interval: a
  conclusion standing unrefuted, a measured value holding constant, a
  question left open. Grounded in CCO **Stasis** (`cco:ont00000819`).
- **Qualities** — the properties an artifact carries, chiefly its
  *uncertainty* and credibility. Grounded in BFO **Quality**
  (`obo:BFO_0000019`). CCO ships no uncertainty quality of its own, so
  defining one under BFO Quality is a candidate for a later chapter to
  weigh, with URREF (below) the likely vocabulary.
- **Agents** — who performs the acts: researchers, groups,
  organizations. Grounded in CCO **Agent** (`cco:ont00001017`).

All of it unfolds over **time**, BFO **temporal region**
(`obo:BFO_0000008`), which timestamps each act and bounds the interval
a state occupies.

These already exist as standardized, BFO-grounded categories; rolling
scimantic's own versions would duplicate that work and give up the
main thing grounding buys: interoperability. One caveat the survey
turned up: CCO's Stasis is under active revision upstream, so a later
chapter may want to insulate scimantic against the churn. One candidate
is to pin a thin local class over Stasis rather than subclass it
directly, the same defensive move URREF's unstable namespace invites.

CCO's v2.0 (2024) terms are the opaque IRIs above (`cco:ont00000958`
is Information Content Entity); see Jensen et al., *[The Common Core
Ontologies](https://arxiv.org/abs/2404.17758)* (FOIS 2024) and the
CUBRC *[Overview of the Common Core
Ontologies](https://www.nist.gov/document/nist-ai-rfi-cubrcinc004pdf)*
(Rudnicki, 2019).

This is the grounding ch01 promised and the decision ch02 deferred
here: *"should `Question` subclass `cco:DirectiveInformationContentEntity`
or `cco:DescriptiveInformationContentEntity`?"* is now a
**well-posed** question, because both candidate parents exist in a
vocabulary we've committed to reuse. Answering it is Chapter 5's job;
making it answerable is this chapter's.

## Provenance without PROV-O

One reuse decision runs the other way: not reusing PROV-O at all. It
needs justifying, because on the surface it looks counterintuitive.

scimantic's domain *is* provenance. The competency questions in
[Chapter 2](ch02-domain-and-scope.md) ("what act produced this
dataset?", "who performed it, and when?", "trace this conclusion back
to its originating question") are textbook provenance queries. The
[W3C **PROV-O** Recommendation](https://www.w3.org/TR/prov-o/) is the
lingua franca for exactly these: `prov:Entity`, `prov:Activity`,
`prov:Agent`, `prov:wasGeneratedBy`, `prov:used`. scimantic v0.1.0
was *grounded* in PROV-O for this reason. So why does
v0.3.0 not declare a `prov:` prefix at all?

Because grounding in PROV-O is what v0.2.0 spent its effort trying to
walk back. PROV-O is loose by design: `prov:Entity` spans both
continuants and occurrents, which helps interchange but breaks down
under a rigorous upper ontology. Going from v0.1.0 to v0.2.0 meant
translating PROV relations into BFO/CCO process-participant relations
*after the fact*, the indirect path ch01 calls out; re-importing
PROV-O as a grounding now would repeat it.

The bridge scimantic needs **already exists as an external,
maintained, peer-reviewed artifact**. Beverley et
al., *[A semantic approach to mapping the Provenance Ontology to Basic
Formal Ontology](https://www.nature.com/articles/s41597-025-04580-1)*
(*Nature Scientific Data*, 2025;
[arXiv:2408.03866](https://arxiv.org/abs/2408.03866)) align **every**
class and object property of PROV-O and its W3C extensions to BFO,
CCO, and **RO** (the [OBO Relations Ontology](https://oborel.github.io/),
the BFO-aligned standard for relations like *part of* and *participates
in*, where much of PROV's relational vocabulary lands). The mappings
ship as three standalone files: `PROV-BFO`, `PROV-CCO`, and `PROV-RO`.
Because scimantic grounds in CCO, it inherits that bridge
**transitively**. This is what ch02 meant by "PROV-O Agent
(transitively, via CCO/BFO mappings)."

With that alignment in hand, declaring PROV mappings in scimantic
would be redundant, not helpful. A consumer who needs PROV
interoperability applies `PROV-CCO` against a scimantic graph and gets
canonical PROV typing, more complete than the handful of
`close_mappings` scimantic could hand-author, and without the risk of
an over-tight `exactMatch` where the real relationship is approximate.
The alignment lives upstream, not in scimantic. The specific
correspondences (`cco:Agent` to `prov:Agent`, the act hierarchy to
`prov:Activity`, and so on) live in the `PROV-CCO` file; spelling them
out belongs with the chapters where scimantic defines its own classes
and relations. scimantic grounds in BFO/CCO and cites the alignment
for anyone who needs PROV, meeting the interoperability need by reuse
rather than by importing PROV-O itself.

## Specialized vocabularies

Beyond the foundation, scimantic reuses five narrower vocabularies,
each covering a concern ch02 explicitly declined to model itself.
None are foundational (they attach to specific classes that arrive in
later chapters), but committing to them now keeps the prefix block an
honest manifest.

- **`dcterms`** ([Dublin Core Terms](http://purl.org/dc/terms/)) —
  general metadata (titles, dates, creators, free-form `citation`).
  ch02 sends typed bibliographic structure downstream to DC/CSL/BibTeX
  and institutional/funding context to dcterms; this is that landing
  pad, and an uncontroversial one to reuse.
- **`oa`** ([W3C Web Annotation Data
  Model](https://www.w3.org/TR/annotation-model/)) — annotations and
  text selectors. scimantic's `Annotation` (a highlight over a span of
  a source document, produced by a LiteratureSearch) is a W3C
  annotation; reusing `oa:Annotation` and its selector machinery means
  scimantic doesn't reinvent text-anchoring. A W3C Recommendation with
  real tool support.
- **`dcat`** ([Data Catalog
  Vocabulary](https://www.w3.org/TR/vocab-dcat-3/)) — dataset
  description. ch02 draws a firm line: `Dataset` is a *process-artifact
  handle*, and the internal structure of the data is DCAT's job (or a
  discipline-specific schema's), not scimantic's. The `dcat:` prefix is
  how that handle connects to the catalog layer.
- **`np`** ([Nanopublication
  schema](http://www.nanopub.org/nschema#)) — small, attributed,
  independently-citable assertions. scimantic's claim-bearing
  artifacts (Hypothesis, Evidence, Result, Conclusion) are natural
  nanopublications; `np:` lets a consumer mint them as such for
  citation and attribution without scimantic prescribing the
  packaging.
- **`urref`** ([Uncertainty Representation and Reasoning Evaluation
  Framework](https://ieeexplore.ieee.org/document/6290584)) — the
  uncertainty layer (Costa et al., *Towards unbiased evaluation of
  uncertainty reasoning: the URREF ontology*, Fusion 2012). ch02 lists
  "URREF-derived qualities on relevant artifacts" as in-scope, so the
  uncertainty model of an Evidence or Result has a vocabulary to
  attach to. It is also the one reuse target without a stable,
  canonical IRI {{#callout urref-namespace}}, a Step-2 finding in its
  own right, since reuse decisions include judging a source's
  long-term addressability, not just its concepts.

## What scimantic invents

Reuse is not the whole story. Everything *characteristic* of
scimantic, the discipline-neutral vocabulary of the scientific method,
is **original**: `Question`, `Hypothesis`, `Evidence`, `Premise`,
`Result`, `Conclusion` and the acts `QuestionFormation`,
`LiteratureSearch`, `EvidenceExtraction`, `HypothesisFormation`,
`Experimentation`, `Analysis`, and so on. None of these exist in
BFO, CCO, or any vocabulary above; supplying them is why scimantic
exists.

The division of labor is the consistent pattern from ch02: **reuse
the scaffolding, invent the discipline.** BFO supplies the categories
of being; CCO supplies the generic shapes of information and action;
the specialized vocabularies cover annotation, datasets, citation,
nanopublication, and uncertainty. What scimantic adds is the *process
structure of research itself*, built by subclassing the reused
categories under original names. Those classes live under the
`scimantic:` prefix. The one place CCO leaves a gap is an uncertainty
quality; whether scimantic fills it under BFO Quality is a candidate
for Chapter 6 to take up, with URREF's guidance.

## The reuse decision, at a glance

| Vocabulary | Prefix | Role | Decision |
|---|---|---|---|
| LinkML types | `linkml` | Built-in type library | **Import** (`imports:`) |
| BFO 2020 | `obo` | Top-level grounding (continuant/occurrent, quality, time) | **Reuse** (by URI) |
| Common Core Ontologies | `cco` | Mid-level grounding (artifacts, acts, states, agents) | **Reuse** (by URI) |
| Dublin Core Terms | `dcterms` | Metadata | **Reuse** (by URI) |
| W3C Web Annotation | `oa` | Annotations / selectors | **Reuse** (by URI) |
| W3C DCAT | `dcat` | Dataset description | **Reuse** (by URI) |
| Nanopublication | `np` | Attributed assertions | **Reuse** (by URI) |
| URREF | `urref` | Uncertainty | **Reuse** (by URI, namespace TBD) |
| PROV-O | *(none)* | Provenance | **Decline**: inherit transitively via CCO |
| The scientific method | `scimantic` | Artifacts, acts, states, qualities | **Invent** |

## How reuse works in LinkML

With the decisions made, here is one mechanical point before the
listing, because LinkML's reuse model may trip up people who arrive
from OWL.

In OWL you reuse an ontology by `owl:imports`-ing it. The imported
axioms become part of the ontology's logical closure. LinkML's
`imports:` keyword *looks* like that but is **not** that. LinkML
`imports:` pulls in other **LinkML schemas** (most commonly
`linkml:types`, the built-in type library). It does **not** ingest
external OWL ontologies like BFO or CCO.

Instead, scimantic reuses external ontologies the way LinkML intends:

- **`class_uri` / `slot_uri`** bind a scimantic class or slot to a
  canonical IRI in another vocabulary. For example, a class `Agent` with
  `class_uri: cco:Agent` *is* the CCO agent class as far as the
  generated RDF/OWL is concerned. scimantic just gives it a readable
  local name and LinkML-shaped slots.
- **Mapping slots** (`exact_mappings`, `close_mappings`,
  `related_mappings`, `broad_mappings`, `narrow_mappings`) record
  looser cross-vocabulary correspondences as SKOS-style annotations,
  without claiming identity.
- **`prefixes`** declare the namespaces those IRIs live in. This is
  the only piece that lands in *this* chapter; the `class_uri`s that
  consume the prefixes arrive in Chapter 5.

The upshot: reusing BFO and CCO costs scimantic nothing at the
`imports:` level. `imports:` stays at just `linkml:types`. Reuse is
expressed by *naming* (*i.e.,* pointing local classes at foreign IRIs) rather than by ingestion.
This keeps `scimantic.yaml` human-readable while the
generated OWL still carries correct upstream ancestry.

## The schema so far

The decisions above land as changes to the `prefixes:` and `imports:` blocks in `schema/scimantic.yaml`:

```yaml
{{#include listings/scimantic-yaml-v1.yaml}}
```

The prefix block is a reuse *manifest* {{#callout reuse-manifest}};
BFO and CCO are the foundation every later class hangs from
{{#callout foundation}}; the absent `prov:` prefix is a decision, not
an oversight {{#callout prov-transitive}}; URREF is committed but its
namespace is provisional {{#callout urref-namespace}}; and `imports:`
stays minimal because external ontologies are reused by *naming*, not
ingestion {{#callout imports-by-uri}}.

```admonish tip title="Frozen listings and callouts, via mdbook-listings"
The YAML above is a **frozen listing**: an exact snapshot of
`schema/scimantic.yaml` as of this chapter, embedded by
[mdbook-listings](https://github.com/padamson/mdbook-listings). Its tag
(`scimantic-yaml-v1`) is its identity, and a SHA-256 in
`book/listings.toml` is its integrity check, so a later edit to the
live schema can't silently change what you see here.

The numbered badges are **inline callouts**. Each one is a `# CALLOUT:`
comment in the real schema; mdbook-listings strips the comment from the
rendered listing, draws the badge in its place, and lets the prose link
to it by name (the callout references in the paragraph above). The
rationale rides on the lines it explains, and a reader of the raw
`scimantic.yaml` sees the same notes as plain comments.

It's an open-source mdBook preprocessor for keeping embedded source
honest as the code evolves. Worth a look for any technical book with
live code.
```

## Next

The foundations are chosen and named; nothing is yet classified
against them. Chapter 4 takes N&M Step 3, enumerating the important
terms of the domain to produce the candidate vocabulary that Chapter 5
will then arrange into a class hierarchy beneath the BFO and CCO
categories committed here.
