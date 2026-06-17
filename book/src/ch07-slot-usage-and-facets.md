# Slot Usage and Facets

This chapter applies **Step 6** of *Ontology Development 101* (Noy &
McGuinness, 2001) to scimantic.

```admonish quote title="Noy & McGuinness 2001 — §Step 6"
Slots can have different facets describing the value type, allowed values,
the number of the values (cardinality), and other features of the values
the slot can take.
```

Step 5 gave every class its slots, each defined once at the most general
class that bears it. Step 6 tightens them *at the point of use*. A facet
says what a slot's values may be, and how many; LinkML's `slot_usage` adds
the per-class dimension: how one subclass narrows a slot it inherited
without touching the slot's global definition. The Step-5 definitions were
deliberately wide: the abstract `Act` carries `hasInput` over every
artifact, `strength` is an unbounded float. Step 6 narrows that breadth
class by class, tightening each slot to what its bearer actually uses.

One rule governs all of it: **a facet may only restrict, never widen.**
`slot_usage` on a subclass can shrink an inherited range, raise a minimum
cardinality, or pin a value, but it can never re-admit what the parent
left out. So each Step-5 envelope is also the outer bound on every Step-6
refinement that narrows it.

## Per-act inputs and outputs

ch06 gave every act the same `hasInput` and `hasOutput`: the abstract `Act`
carries both, ranged over the whole artifact union: `Claim`, `Question`,
`Result`, `Method`, `Dataset`, `Annotation`, `SourceDocument`. That was the
envelope. This cluster spends it. Each concrete act narrows those two slots,
in `slot_usage`, to the artifacts it actually consumes and produces.

The narrowing takes three shapes. Most acts restrict a slot to a **single
range**: `Analysis` consumes a `Dataset` and produces a `Result`,
`ResultAssessment` consumes a `Result` and produces a `Conclusion`. A few
keep a **smaller union**: `EvidenceExtraction` draws on either an `Annotation`
or the `SourceDocument` it sits on; `QuestionFormation` may be prompted by a
prior `Question` or `Result`, or by nothing at all. And two acts narrow a
slot to **nothing**:

```admonish quote title="Noy & McGuinness 2001 — §Step 6, cardinality"
Sometimes it may be useful to set the maximum cardinality to 0. This setting
would indicate that the slot cannot have any values for a particular subclass.
```

`EvidenceAssessment` weighs a piece of evidence and, on acceptance, confers
an `AcceptedState` on it. Its effect is a *standing*, carried by
`State.establishedBy`, not a new artifact. So its `hasOutput` is
`maximum_cardinality: 0` ({{#callout assess-no-output}}): the act yields no
artifact at all. `DesignOfExperiment`'s `hasInput` is zero for the mirror
reason ({{#callout design-no-input}}). The hypothesis it works from arrives
through `tests`, so nothing flows in through `hasInput`.

**This table is also the method's sequencing.** scimantic has no `precedes`
slot and no fixed pipeline; the order of acts is *emergent*, and this is
where it emerges. An act that consumes an artifact can only run after the act
that produced it. `ResultAssessment hasInput→Result` and `Analysis
hasOutput→Result` together say, without ever stating an order, that assessment
follows analysis. The nine narrowings induce a **partial order** on the acts:
a happens-before read straight off the input and output types. We don't
hard-wire the textbook question→…→conclusion sequence, because real inquiry
doesn't obey it. Exploratory work has no hypothesis, a `LiteratureSearch` can
surface fresh questions, studies iterate and skip steps. scimantic records
what happened as a DAG and lets the familiar order fall out of the types. (BFO
offers `precedes` / `preceded by` for occurrents if an explicit order were
ever wanted; here the I/O chain plus each act's `performedAt` interval already
fix it, so scimantic doesn't reach for it.)

Every narrowing only *restricts*: each act's inputs and outputs stay a subset
of the Step-5 envelope, never more. That is the chapter-opening rule, applied
nine times.

{{#diff scimantic-yaml-v7 scimantic-yaml-v8 context=5 caption="Per-act inputs and outputs"}}

<!-- ============================================================
BUILDOUT PLAN — ch07 facet clusters (working order; not yet prose).
Mirrors ch06's cluster rhythm. Each advances the schema and freezes a
new scimantic-yaml tag with a v(n)->v(n+1) diff.

1. Per-act inputs and outputs — slot_usage on each Act subtype narrowing
   hasInput/hasOutput from the Step-5 any_of union to what that act
   actually consumes/produces. The chapter's central worked example.
2. Numeric bounds — strength's interval and confidenceLevel in [0, 1]
   (minimum_value / maximum_value), plus requiredness/defaults.
3. Relational characteristics — irreflexive / asymmetric / symmetric on
   the claim relations and the reified EvidentialRelation.
4. Required and optional — the cardinality sweep: which slots a competency
   question forces to be present, exactly-one, or many.

Housekeeping: Ch 2 prose says "Chapter 6" for slot_usage; it is Step 6 /
this chapter. Reconcile the Ch 2 wording when cluster 1 lands.
============================================================
-->

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
