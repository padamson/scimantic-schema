<!-- DRAFT — not yet linked in SUMMARY.md. -->

# Slot Usage and Facets

<!-- ============================================================
CARRIED-IN DEFERRALS → Step 6 (slot_usage / facets).

Every "deferred to Step 6 / facets" an earlier chapter wrote lands
here as a checkbox. Convention: see CLAUDE.md › Conventions.

[ ] slot_usage refinements — per-class narrowing of the Step-5
    slots once they exist (ranges, requiredness, defaults tightened
    on a subclass). (Ch 2 §scope — note: Ch 2 prose says "Chapter 6";
    slot_usage is Step 6 / this chapter. Reconcile the Ch 2 wording,
    or the chapter split, when this lands.)

[ ] hasInput/hasOutput per-act narrowing — each concrete Act
    restricts the Step-5 any_of union (Claim/Question/Result/Method/
    Dataset/Annotation/SourceDocument) to the artifacts it actually
    consumes/produces; e.g. Experimentation hasInput→Method(+Dataset),
    hasOutput→Result; LiteratureSearch hasOutput→SourceDocument;
    HypothesisFormation hasOutput→Claim; Analysis hasInput→Dataset,
    hasOutput→Result. slot_usage can only restrict the inherited
    union, never widen it. (Ch 6 §Act participation — the hasInput/
    hasOutput descriptions promise "narrowed per-act in Chapter 7".)

[ ] Numeric bounds — strength and confidenceLevel ship from Step 5
    as unbounded floats; set their ranges as Step-6 facets
    (strength's interval, confidenceLevel in [0, 1]), plus
    requiredness/defaults. (Ch 6 §"One strength, shared and still
    unbounded")

[ ] nature URREF grounding — UncertaintyModel.nature is a plain
    enum (aleatory/epistemic); attaching a urref: meaning to its
    permissible values awaits a resolved URREF namespace. Not facet
    work — parked here for visibility until URREF lands. (Ch 6
    §"Enumerate what's closed"; Ch 3 §urref-namespace)

[ ] Relational constraints on the claim relations — decide, per
    relation, whether supports / contradicts / refines and the
    reified EvidentialRelation are irreflexive (no claim bears on
    itself) and symmetric or asymmetric (contradicts reads
    symmetric, refines asymmetric, supports neither), then declare
    them with LinkML's relational slot characteristics
    (irreflexive / asymmetric / symmetric / ...). Validating that
    instances honor them follows in Ch 8. (Ch 6 §"The reified
    fields" — Claim→Claim domain=range raises it; domain/range
    alone can't express it.)
=============================================================
-->

<!-- ============================================================
N&M QUOTE BANK — §Step 6 (ontology101.pdf, verbatim; lift into
admonish quote blocks as this chapter is written).

§Step 6 — Define the facets of the slots:
"Slots can have different facets describing the value type, allowed
values, the number of the values (cardinality), and other features of the
values the slot can take."

§Step 6 — Slot cardinality:
"Slot cardinality defines how many values a slot can have. Some systems
distinguish only between single cardinality (allowing at most one value)
and multiple cardinality (allowing any number of values). [...] Minimum
cardinality of N means that a slot must have at least N values. [...]
Maximum cardinality of M means that a slot can have at most M values.
[...] Sometimes it may be useful to set the maximum cardinality to 0.
This setting would indicate that the slot cannot have any values for a
particular subclass."

§Step 6 — Slot-value type:
"A value-type facet describes what types of values can fill in the slot.
Here is a list of the more common value types: String [...]; Number
[...]; Boolean [...]; Enumerated [...]; Instance [...]."
============================================================ -->
