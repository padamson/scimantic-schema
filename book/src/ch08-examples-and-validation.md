<!-- DRAFT — not yet linked in SUMMARY.md. -->

# Examples and Validation

<!-- ============================================================
CHARTER (set 2026-06-16). ch08 is the dogfooding-driven polish +
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

Every "deferred to Step 7 / Chapter 8 / validation" an earlier
chapter wrote lands here as a checkbox. Convention: see
CLAUDE.md › Conventions.

[ ] CQ litmus — re-run the whole competency-question set (original
    and surfaced) against instance data as the validation test of
    the vocabulary's shape, not just its contents.
    (Ch 4 §"questions that test shape"; Ch 4 §surfaced —
    "Chapter 8 will revisit the whole question set")
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
[ ] Connect the BFO qualities to their bearers — Uncertainty and
    Credibility ship from Step 5 grounded as BFO Quality but with no
    slots, so they float free of the provenance graph (the ch07 viz
    surfaced the island: UncertaintyModel → quantifies → Uncertainty,
    but Uncertainty reaches no bearer; Credibility reaches nothing).
    Add the BFO "inheres in" relation (obo:BFO_0000197, verify before
    encoding): Uncertainty inheresIn → Result, Credibility inheresIn →
    Evidence, threading UncertaintyModel → Uncertainty → Result and
    Credibility → Evidence into the chain (mirrors State.qualifies).
    Optionally also give each its establishing act (mirror
    State.establishedBy: Credibility conferred by EvidenceAssessment,
    Uncertainty derived by Analysis). Structural slot, not a facet, so
    it lands as a polish freeze (a later v; clusters 3-4 advance the
    chain first). (Surfaced 2026-06-17.)
[ ] Revisit UncertaintyModel granularity — family is an open string,
    parameters a multivalued string. For provenance, family +
    confidenceLevel + nature may suffice (the detailed stats are the
    Result's content, not a provenance record's). When the real study
    exercises a result-with-uncertainty, decide: drop or keep
    parameters; range family over an external stats ontology (STATO)
    vs leave it an open string. Don't model speculatively before the
    study shows what's needed. (Surfaced 2026-06-17, with inheresIn.)
[ ] Study is_a Act? — Study is a sibling of Act (both subclass_of CCO
    Planned Act), so it carries only hasPart, not agent / performedAt /
    hasInput / hasOutput. If a study should have a PI, a timespan, and a
    question-in / conclusion-out, make Study is_a Act (inheriting those
    plus hasPart). A class-hierarchy change (Step 4), surfaced in ch07's
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
