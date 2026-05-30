<!-- DRAFT — not yet linked in SUMMARY.md. -->

# Slots

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
