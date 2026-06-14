<!-- DRAFT — not yet linked in SUMMARY.md. -->

# Slots

<!-- ============================================================
CARRIED-IN DEFERRALS → Step 5 (Slots).

Every "deferred to Chapter 6 / Step 5" an earlier chapter wrote
lands here as a checkbox. Settle or re-route each before this
chapter is done. Convention (CLAUDE.md › Conventions): a prose
deferral and its line here are written together, so nothing
promised is dropped.

[ ] Inverse slots — explicit slot vs upstream owl:inverseOf, per
    relation. Detailed rationale in the block below.
    (Ch 2 §scope; Ch 4 §"reading edges backward"; Ch 4 §surfaced)
[ ] Relation typing — which of addressedBy / extractedInto /
    consumedBy / hasInput / hasOutput / derivedFrom become real
    slots vs a generic relation with a typed range.
    (Ch 4 §"reading edges backward")
[ ] Stored vs derived — which relations are materialized and which
    the reasoner computes (e.g. a hypothesis's weight of evidence
    from its support/contradict edges).
    (Ch 4 §"stored versus derived")
[ ] Cardinalities — per-slot multiplicities. (Ch 2 §scope)
[ ] Claim-relation naming — rename supports/contradicts/refines to
    CiTO's terms, or keep scimantic's and map with skos:closeMatch.
    (Ch 5 §Next)
[ ] Promotion wiring — the Claim→State bearing slot and the
    EvidenceAssessment slot that confers an AcceptedState; whether
    promotedFrom is a real slot or a derived transition.
    (Ch 5 §"Evidence and Premise")
[ ] tests — materialize the prospective-intent slot on
    DesignOfExperiment (placement decided in Ch 5).
    (Ch 5 §"Method and act")
[ ] executes — which CCO relation it maps to. (Ch 5 §"Method and act")
[ ] State attachment — how OpenState / AcceptedState /
    RetractedState attach to the entity each qualifies and point
    back to the act + agent that established them.
    (Ch 5 §"Standing as state")
[ ] Act participation — agent, time (a TemporalInterval, not a
    createdAt instant), inputs, and outputs on Act. (Ch 5 §Anchoring)
[ ] Reified-class slots — the fields the new reification classes carry:
    EvidentialRelation's cito polarity / strength / asserting act /
    agent; UncertaintyModel's family / parameters / confidence / nature
    (nature: a urref: mapping or a plain enum — URREF deferred per Ch 3);
    EvidenceLine's members + strength;
    Study's parts. (Ch 5 §Reification, §Uncertainty, §"higher-level layer")
=============================================================
-->

<!--
================================================================
Deferred design decision: bidirectional / inverse slots
Captured 2026-05-30 during Ch 2 (Domain and Scope) work.
================================================================

We defer the question of "does every relation get an explicit
inverse slot in scimantic, or do we rely on upstream
`owl:inverseOf` declarations (mostly from CCO) for the reverse
direction?"

Defer-then-decide rationale:

- Bidirectionality is a Step 5-6 implementation choice (N&M-101).
- v0.2.0 mixed both styles (`isOutputOf` was explicit; `isInputOf`
  was derived).
- Once grounded in CCO (Ch 3), the upper ontology's `owl:inverseOf`
  declarations give us the inverse direction "for free" via OWL
  reasoning or SPARQL `^prop` queries.
- Pre-emptively defining every inverse doubles slot count and
  creates drift risk; pre-emptively forbidding inverses blocks
  consumer authoring patterns that genuinely need them.

Suggested per-slot rule when this chapter lands:

- **No explicit inverse slot** when:
  - the inverse is declared upstream (CCO/BFO), AND
  - consumers can reasonably use OWL reasoning or SPARQL inverse
    paths to traverse the reverse direction.

- **Explicit inverse slot** when:
  - the inverse is heavily used in authoring (e.g., the VS Code
    extension's UI is structured around it), OR
  - the reasoner / SPARQL pathway isn't reliable for the consumer
    (e.g., the consumer's runtime doesn't have an OWL reasoner).

Lead the chapter with this principle, then walk each scimantic
relation and apply it.

Cross-refs:
- Ch 2 (Domain and Scope): "provenance is core to the scope;
  implementation mechanics are deferred to Chapter 6."
- Ch 3 (Reusing existing ontologies): lands the CCO grounding that
  this decision depends on.
================================================================
-->
