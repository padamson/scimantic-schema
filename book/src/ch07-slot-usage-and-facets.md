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
a happens-before read straight off the input and output types.

```admonish info title="Jargon: partial order"
The acts are *partially* ordered, not *totally* ordered. The input/output
types fix the sequence between two acts only when one consumes what the
other produced ("X *happens-before* Y"); any two acts not linked that way
are unordered. A total order would put every act on a single line; a partial
order keeps only the dependencies and leaves the rest free.
```

We don't
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

## Numeric bounds

Two slots carry numbers rather than references: `strength` (on
`EvidentialRelation` and `EvidenceLine`) and `confidenceLevel` (on
`UncertaintyModel`). Step 5 left both as unbounded floats, with the
interval deferred to here. A `float` admits any real value, which is
wrong for both: a strength of 4.2 or a confidence of -0.3 is
meaningless. The `minimum_value` and `maximum_value` facets close that,
pinning each to `[0, 1]`.

`strength` is a magnitude, not a signed quantity. Direction already
lives in `polarity` (supports, contradicts, refines), so a bearing that
weakly contradicts is `polarity: contradicts` with a low `strength`,
never a negative one. Weakness, then, needs no slot of its own: it is the
low end of `[0, 1]`. The schema keeps the three senses of "weak" apart,
each on its own slot. A weak bearing is low `strength`, weak evidence is
low `Credibility`, and a shaky result is high `Uncertainty`.

`confidenceLevel` is a reported confidence, so `[0, 1]` is the
probability interval it lives on.

These are value bounds, a different facet from cluster 1's range
narrowing. There we restricted which classes a slot points at; here we
restrict which numbers a value may take. The instinct is the same: say no
more than the domain allows, applied now to the two kinds of value a slot
can hold.

{{#diff scimantic-yaml-v8 scimantic-yaml-v9 context=5 caption="Numeric bounds"}}

## Required and optional

The last facet axis is cardinality: how many values a slot must have. Most
of the schema's slots are optional by default, so the sweep here is deciding
which ones a record cannot do without.

scimantic takes the lenient stance its PROV-O lineage suggests: an activity
asserts what is known, so provenance metadata stays optional. `agent`,
`performedAt`, and an act's inputs are left unconstrained, because real
records often lack a known performer, time, or explicit input. The schema
should capture a partial record, not reject it.

What it does require is structural integrity: the fields without which an
entity is not coherent. A reified relation needs its endpoints and
direction, so `EvidentialRelation` requires `subject`, `object`, and
`polarity`. An evidence line needs what it groups and what it bears on, so
`EvidenceLine` requires `members` and `bearsOn`. A state needs the thing it
qualifies, a study needs its parts, and an uncertainty model needs the
quality it quantifies.

The acts add one required slot apiece, on the output side. An act defined by
what it produces must produce it: a `QuestionFormation` without a `Question`,
or an `Analysis` without a `Result`, is incomplete in a way an act missing
its agent is not. So each act whose identity is its product requires that
output, narrowed in cluster 1 and now floored at one. Inputs stay optional,
since an act can usually be reconstructed from its output alone.

{{#diff scimantic-yaml-v9 scimantic-yaml-v10 context=9 caption="Required and optional"}}

## Relational characteristics

ch06 left a question open. The claim relations are `Claim`-to-`Claim`:
`supports`, `contradicts`, and `refines` take `Claim` as both domain and
range. That shape raised a question domain and range alone cannot answer:
may a claim bear on itself, and does a bearing run both ways? The answers
are not facets of a value or a count. They are *characteristics* of the
relation, which LinkML carries as boolean slot metaslots and lowers to OWL
property axioms a reasoner can enforce.

```admonish info title="Jargon: property characteristics"
Logical features of a relation, independent of any single pair. A relation
is *irreflexive* if nothing relates to itself; *symmetric* if A-to-B always
implies B-to-A; *asymmetric* if A-to-B forbids B-to-A (which makes it
irreflexive too); *transitive* if A-to-B and B-to-C imply A-to-C. Each
lowers to an OWL axiom.
```

All three claim relations are **irreflexive**: no claim bears on itself. A
claim that supports, contradicts, or refines itself is a small circularity
the reasoner can now reject, and it is the direct answer to ch06's
domain-equals-range question. The relation runs among claims, never from a
claim back to itself.

The three then part on direction. `refines` is **asymmetric**: if one claim
refines another, the second does not refine the first, since refinement
sharpens or extends what came before and the reverse cannot also hold.
(Asymmetry already implies irreflexivity, so the two travel together.)

`supports` and `contradicts` are directional but not one-way, so neither
symmetric nor asymmetric fits. Evidence supporting a hypothesis is not the
hypothesis supporting the evidence, yet two claims can support each other in
a coherent pair. Contradiction is subtler: logical incompatibility is
symmetric, but scimantic's `contradicts` is the evidential `cito:disputes`,
and disputation flows from the disputing claim to the disputed one. A null
result contradicts the hypothesis it tested; the hypothesis does not dispute
the result. Two studies with opposite findings, though, contradict each
other. So both relations stay where they began, irreflexive and nothing more.

The empty symmetric and transitive columns are deliberate, not an oversight.
The transitive relations in provenance are real, but they are *lineage* and
*order*, and a slot for each is the wrong place to keep them. scimantic
stores the atomic edges, `hasInput` and `hasOutput` and the act chain, and
lets the transitive closures fall out of SPARQL property paths, the same
store-the-edge-derive-the-aggregate call ch06 made. A symmetric
`corroborates` would be derivable too, from two claims supporting a common
target. Transitivity and symmetry are present in the graph; they are
queried, not declared.

One slot is the exception, and it earns the axiom. `Study.hasPart` maps to
BFO's *has occurrent part*, which BFO defines as transitive, so a study's
parts' parts are its parts. Because scimantic grounds in BFO by URI rather
than importing it, that transitivity is not inherited, so the schema
declares `transitive: true` to make BFO's own semantics explicit and to be
ready for composite acts with sub-acts.

```admonish info title="Jargon: mereology"
The logic of parts and wholes. A *mereological* relation such as `hasPart`
is characteristically transitive: a part of a part is a part of the whole.
BFO's *has occurrent part* is the version for processes.
```

That leaves `refines` and a tempting fourth characteristic. Refinement reads
transitively, a refinement of a refinement being a refinement, and declaring
it would let a reasoner hand back the whole ancestry. But OWL 2 DL forbids a
property from being both transitive and asymmetric or irreflexive, the
restriction that keeps reasoning decidable. Transitivity would cost the
one-way and no-self guarantees, and the ancestry it would infer is already a
`refines+` path away. Asymmetry wins; transitivity stays off.

{{#diff scimantic-yaml-v10 scimantic-yaml-v11 context=4 caption="Relational characteristics"}}

<!-- ============================================================
BUILDOUT PLAN — ch07 facet clusters. Each advances the schema and freezes
a new scimantic-yaml tag with a v(n)->v(n+1) diff. Order is
value -> count -> logic.

[done] 1. Per-act inputs and outputs — slot_usage narrowing hasInput/
   hasOutput per Act subtype. v7->v8.
[done] 2. Numeric bounds — strength and confidenceLevel pinned to [0, 1]
   (minimum_value / maximum_value). v8->v9.
[done] 3. Required and optional — required on structural-identity slots +
   per-act defining outputs; lenient on metadata (PROV-O stance). v9->v10.
[done] 4. Relational characteristics — irreflexive on the claim relations,
   asymmetric on refines, transitive on hasPart; symmetric/transitive
   otherwise derived not stored. v10->v11. EvidentialRelation's
   subject!=object is a rule, deferred to ch08 validation.

Housekeeping: Ch 2 prose says "Chapter 6" for slot_usage; it is Step 6 /
this chapter. Reconcile the Ch 2 wording when the chapter lands.
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
