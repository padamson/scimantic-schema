<!-- IN PROGRESS. Written: intro + §"Culling the uncertainty cluster"
     (reflection-driven polish; freeze scimantic-yaml-v12). Pending: the
     worked-study instantiation (Appendix A) and the dogfood-driven polish
     and validation it pulls. Scaffolding for the unwritten sections is in
     the comment blocks below.
     NOTE for next freeze (v13): schema/scimantic.yaml carries an
     unfrozen edit — the hasInput/hasOutput descriptions now say
     "Chapter 6" (post-renumbering; was "Chapter 7"). The v12→v13 diff
     will surface those two lines; narrate the 2026-07-30 renumbering
     (Introduction unnumbered, chapter N = step N) alongside whatever
     schema change triggers the freeze. Optionally also unfold the >-
     folded description scalars at that freeze (tier 2 of the
     soft-wrap dogfood — the folds only dodged a fixed badge bug;
     see book/soft-wrap.css). -->

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
[ ] Identifiers — instances form a provenance DAG with SHARED
    references (one act's output is another's input), so add an
    identifier slot (identifier: true) so hasInput/hasOutput/hasPart
    can point at a node by id. Currently zero identifier slots — this
    blocks instance authoring; lands as a schema polish (new freeze).
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
[ ] Study is_a Act? — Study is a sibling of Act (both subclass_of CCO
    Planned Act), so it carries only hasPart, not agent / performedAt /
    hasInput / hasOutput. If a study should have a PI, a timespan, and a
    question-in / conclusion-out, make Study is_a Act (inheriting those
    plus hasPart). A class-hierarchy change (Step 4), surfaced in ch06's
    cluster-4 discussion. (Surfaced 2026-06-17.)
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
