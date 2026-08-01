<!-- IN PROGRESS. Written: intro + §"Culling the uncertainty cluster"
     (freeze v12) + §"What a data file needs that a schema did not"
     (freeze v13: id slot, ProvenanceRecord container, Study is_a Act,
     renumbering narration). Pending: the intro instance-graph preview
     (inserts between the culling and data-file-needs sections once the
     preview data file exists), the worked example (positron
     meta-analysis; Appendix A), validation, the SPARQL CQ litmus, and
     the graphRAG section. Scaffolding for unwritten sections is in
     the comment blocks below.
     NOTE: the >- unfold (soft-wrap tier 2) is deliberately NOT done —
     the folds also satisfy the repo's 72-col schema line-width hook,
     so they are policy now, not a badge-bug workaround. Decided
     2026-07-31; book/soft-wrap.css comment corrected to match. -->

# Refinement and Validation

This chapter applies **Step 7** of *Ontology Development 101* (Noy &
McGuinness, 2001) to scimantic, and with it closes the rebuild.

```admonish quote title="Noy & McGuinness 2001 — §Step 7"
The last step is creating individual instances of classes in the
hierarchy. Defining an individual instance of a class requires (1)
choosing a class, (2) creating an individual instance of that class, and
(3) filling in the slot values.
```

Step 7 is instances, but here instances are a means rather than the end.
Building them out against a real study is how the schema gets *validated*,
and refined in the same motion: each filled-in slot value tests whether the
ontology can carry the study, and the gaps that surface are the
refinements to make. Validation and refinement are not two phases here.
They are one interleaved activity.

That refinement comes from two directions. One is **dogfooding**: validating
the schema against Appendix A's worked study, instance by instance, surfaces
what it still lacks. The other is **reflection**, stepping back from the
finished hierarchy to ask whether every class it accumulated still earns its
place. This is the one kind of refinement that needs no instances to
motivate it. N&M's second rule, that ontology development is necessarily
iterative (Chapter 1), makes both expected. The chapter opens with the
reflection, because the graph alone made it plain.

## Culling the uncertainty cluster

At the end of Chapter 6 the schema was complete enough to review as a
whole. Its provenance classes form a single connected component in the
graph: claims, acts, and artifacts linked by `hasInput`, `hasOutput`, and
the act chain. Four classes stand outside it. `Uncertainty`, `Credibility`,
and `UncertaintyModel` form a fragment the provenance chain never reaches,
and `StatisticalMethod`, though placed under `AnalyticalMethod`, is used by
no act. All four were added in Step 4 and have gone unused since. The
question is whether they belong in scimantic at all.

Two reasons say they do not.

The first is a **category error**. `Uncertainty` and `Credibility` were
grounded as BFO *qualities* (`obo:BFO_0000019`), and Chapter 4 reasoned that
a result's uncertainty "inheres in the result." But a quality inheres only
in an **independent continuant**, and the thing it was meant to qualify, a
`Result`, is not one. A result is an information content entity, a
*generically dependent* continuant, and a quality cannot inhere in it.

```admonish info title="Jargon: independent vs. dependent continuant"
BFO splits continuants three ways by how they depend on other things. An
**independent continuant** exists in its own right and can bear qualities:
an organism, a sample, an instrument. A **specifically dependent
continuant**, such as a quality, exists only by inhering in one particular
bearer. A **generically dependent continuant** is a pattern of information
that can be copied across bearers; an ICE is one. Inherence (Chapter 4)
runs from a quality to an *independent* continuant, so grounding the
uncertainty of an information artifact as a quality mismatches the
categories.
```

The grounding was incorrect from the start, independent of the graph; the
disconnected component only made it easy to notice.

The second is a **layering error**. Uncertainty is a property of the data,
not of the provenance chain. A distribution over a data point or a
confidence interval on a result belongs with the data itself, a layer below
the one scimantic models. That layer already has a vocabulary for it:
scimantic's `Dataset` is a `dcat:Dataset`, and DCAT's quality companion,
the W3C [Data Quality Vocabulary](https://www.w3.org/TR/vocab-dqv/) (DQV),
attaches quality measurements and annotations to a dataset. A consumer
records a result's uncertainty as one such measurement, against the data
rather than the provenance graph. scimantic records *that* a result was
produced, by
which act and from which dataset; how far it could vary is the data layer's
to express.

So all four classes are removed, along with the slots only they bore
(`quantifies`, `family`, `parameters`, `confidenceLevel`, and `nature`),
the `UncertaintyNature` enum, and the now-unused `urref:` prefix.

Removing a class is not the same as denying what it named, and two of the
four need a note on where their content goes. **Credibility** is not lost,
only relocated. An `EvidenceAssessment` already weighs a piece of evidence
and, on acceptance, confers an `AcceptedState` on it; credibility is the
judgment that assessment makes, read from the conferred state, not a
separate quality that needs its own class. (If a graded score is wanted
over the plain accept-or-reject verdict, it is a slot on
`EvidenceAssessment`, where the judgment is made.) **StatisticalMethod** was
`is_a AnalyticalMethod`, but statistics is orthogonal to the
analytical/experimental split rather than a subtype of one side. If a
concrete statistical method type is needed later, it returns as a `mixin`
composed onto the relevant method, added on demand rather than now.

The removal also settles two threads earlier chapters left open. Chapter
2's twelfth competency question, *what is the uncertainty model for a given
result, and how was it derived?*, falls to the data layer rather than
scimantic, and the validation pass will mark it out of scope. The `[0, 1]`
bound Chapter 6 placed on `confidenceLevel` is removed with the class that
carried it; the matching bound on `strength` is unaffected.

{{#diff scimantic-yaml-v11 scimantic-yaml-v12 context=3 caption="Culling the uncertainty cluster"}}

## What a data file needs that a schema did not

The dogfood direction starts before the first record is written.
scimantic's worked example is a data file: LinkML instance data,
records conforming to the schema's classes, held apart from the schema
itself. Trying to write one surfaced three things six chapters of
schema building never needed, and each lands here as a refinement —
new freezes, not retro-edits to earlier snapshots.

The first is an **identifier**. Instances form a provenance graph with
shared references: one act's output is another act's input, a state
points back at the act that established it, an evidential relation
names two claims. A reference needs something to point *at*, and no
scimantic class had a key. The new `id` slot ({{#callout identifier}})
is marked `identifier: true` and joins every referenceable class, so
`hasInput: [ghosh-2022-eb]` in a record means the node carrying that
id. Identifiers are unique across a whole file, not per class — two
records may not share one even when their classes differ.

The second is a **root**. A YAML file holds one document, and a
document conforming to a schema must *be* an instance of some class —
so the schema needs a class whose instances are data files.
`ProvenanceRecord` ({{#callout record}}) is that class, marked
`tree_root: true`, holding one multivalued collection per concrete
class plus a `title` and `description` for the file itself. Its
collections are `attributes:` rather than entries in the shared
`slots:` block: they exist only on the container, and the container
exists only because a data file needs a root.

The third the schema had seen coming. Chapter 6's relational
discussion left open whether `Study` should stay a sibling of `Act` —
both grounded in CCO Planned Act, with `Study` carrying only
`hasPart` — or become an act itself. Building the record forced the
call: a study has a principal investigator, which is `agent`; it runs
over a timespan, which is `performedAt`; and one question goes in and
one concluding claim comes out, which are `hasInput` and `hasOutput`
narrowed to `Question` and `Conclusion`. So `Study` is now `is_a Act`
({{#callout study-act}}), inheriting the act slots and the Planned Act
grounding through `Act` instead of declaring its own.

One more change rides this freeze without being schema design at all.
Between the last freeze and this one the book was renumbered: the
Introduction became an unnumbered prefix chapter, so each chapter now
carries the number of the N&M step it applies. Two slot descriptions
that pointed at "Chapter 7" for the per-act narrowing now say
Chapter 6, and the diff shows the edit. The frozen listings of earlier
chapters keep the bytes they were frozen with — where one renders the
old number, a note beside it says why.

{{#diff scimantic-yaml-v12 scimantic-yaml-v13 context=3 label="data-file-needs" caption="What a data file needs"}}

<!-- ============================================================
CHARTER (set 2026-06-16). ch07 is the dogfooding-driven polish +
validation chapter. The worked example is a REAL published study,
instantiated end-to-end in Appendix A as LinkML instance data. This
chapter narrates what that dogfood surfaced — the schema refinements it
forced, landing as new freezes (v9+), NOT retro-edits to earlier
chapters' snapshots — and the validation: linkml-validate (structural
conformance) + the competency-question litmus run as SPARQL over the
RDF projection. The demand-driven method made explicit: Appendix A =
the demand, this chapter = the polish it pulls.
============================================================
-->

<!-- ============================================================
CARRIED-IN DEFERRALS → Step 7 (instances + validation).

Every "deferred to Step 7 / Chapter 7 / validation" an earlier
chapter wrote lands here as a checkbox. Convention: see
CLAUDE.md › Conventions.

[ ] CQ litmus — re-run the whole competency-question set (original
    and surfaced) against instance data as the validation test of
    the vocabulary's shape, not just its contents.
    (Ch 4 §"questions that test shape"; Ch 4 §surfaced —
    "Chapter 7 will revisit the whole question set")
[ ] DAG constraint — enforce that the provenance graph is acyclic
    (the one shape-finding Ch 4 recorded). (Ch 4 §"questions that
    test shape")

Prerequisites the real-study dogfood (Appendix A) forces:
[x] Identifiers — id slot (identifier: true) on every referenceable
    class, plus the ProvenanceRecord tree_root container. Froze
    scimantic-yaml-v13; narrated in §"What a data file needs".
    (Done 2026-07-31.)
[ ] linkml-validate in CI — the structural proof that the study's
    instance data conforms to the schema. External tool (not
    panschema); wire into the docs/CI workflow.
[ ] LinkML → RDF projection — lower instance data to RDF via the
    class_uri/slot_uri grounding so the competency questions run as
    SPARQL (the CQ litmus above). (Ch 3 grounding enables it)

Schema polish surfaced dogfooding the viz:
[x] Drop the uncertainty cluster — removed Uncertainty, UncertaintyModel,
    Credibility, StatisticalMethod (plus the slots only they bore:
    quantifies, family, parameters, nature, confidenceLevel), the
    UncertaintyNature enum, and the orphaned urref: prefix. Froze
    scimantic-yaml-v12; narrated in §"Culling the uncertainty cluster".
    Two reasons given: a BFO Quality cannot inhere in an ICE (Result /
    Evidence / Dataset are GDCs, not independent continuants), and
    uncertainty is a data-layer concern that DCAT's quality companion
    (DQV) already covers. Superseded the former inheresIn /
    UncertaintyModel-granularity / nature-URREF deferrals. Credibility is
    derivable from EvidenceAssessment; StatisticalMethod may return later
    as a mixin if a concrete method type needs it. (Done 2026-06-18.)
[ ] Revisit CQ #12 + the ch01 uncertainty anticipation in the CQ litmus —
    ch07 work, NOT a ch01 edit. ch01 deliberately keeps CQ #12 ("what is
    the uncertainty model for a given result, and how was it derived?") and
    its inclusion-list "uncertainty representation (URREF-derived
    qualities)" as the chronological record of a planned-then-culled path.
    The CQ-litmus section revisits CQ #12 and reports that scimantic does
    not answer it: it relocates to the data layer (DQV on the
    dcat:Dataset), out of scope here. Closes the loop ch01 promised
    ("Chapter 7 will revisit each question"); the culling section already
    foreshadows it ("the validation pass will mark it out of scope").
    (Decided 2026-06-18: handle in ch07, not ch01.)
[x] Study is_a Act? — decided YES: Study is_a Act with hasInput →
    Question and hasOutput → Conclusion narrowings, inheriting agent /
    performedAt and the Planned Act grounding through Act. Froze in
    v13; narrated in §"What a data file needs". (Decided 2026-07-31.)
=============================================================
-->

<!-- ============================================================
N&M QUOTE BANK — §Step 7 (ontology101.pdf, verbatim; lift into
admonish quote blocks as this chapter is written). N&M Step 7 is
instances only; validation is scimantic's own addition (re-running the
competency questions as the litmus), so it has no N&M quote.

§Step 7 — Create instances:
"The last step is creating individual instances of classes in the
hierarchy. Defining an individual instance of a class requires (1)
choosing a class, (2) creating an individual instance of that class, and
(3) filling in the slot values."
============================================================ -->
