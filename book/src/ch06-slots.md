# Slots

This chapter applies **Step 5** of *Ontology Development 101* (Noy &
McGuinness, 2001) to scimantic.

```admonish quote title="Noy & McGuinness 2001 — §Step 5"
The classes alone will not provide enough information to answer the
competency questions from Step 1. Once we have defined some of the
classes, we must describe the internal structure of concepts. [...] In
general, there are several types of object properties that can become
slots in an ontology: "intrinsic" properties such as the flavor of a
wine; "extrinsic" properties such as a wine's name, and area it comes
from; parts, if the object is structured [...]; relationships to other
individuals; these are the relationships between individual members of
the class and other items (e.g., the maker of a wine, representing a
relationship between a wine and a winery, and the grape it is made from).
```

ch05 placed the classes; this chapter gives them properties. For
scimantic that means, overwhelmingly, N&M's fourth kind — **relationships
to other individuals**. The schema models the scientific method as
*provenance*, and provenance is relational: which act produced a result,
which agent performed it, what evidence supports a conclusion, which
method an experiment executed. A few slots are intrinsic (a relation's
strength, an uncertainty's confidence level), but the spine of Step 5 is
wiring the classes together.

That wiring is where ch04's deferred *implementation* questions and ch05's
slot-shaped promises come due. They are not independent — every relation
faces the same handful of questions: how to type it, whether to give it an
inverse, whether to store or derive it, how many values it takes, and what
to call it. So the chapter settles those as **policies** first, then walks
the relations cluster by cluster and applies them.

## The policies

scimantic's relations are many, but they divide along a few axes that
recur for every one of them. Settling the axes once, up front, keeps the
per-relation walk that follows mechanical.

### Name the relation; don't genericize it

LinkML lets a relation be either a **named slot** with its own domain,
range, and mappings, or a single generic relation whose meaning rides on a
typed range. scimantic names them. `hasInput`, `supports`, `tests`, and
`performedAt` each become their own slot, not facets of one `relatedTo`. A
named slot is self-documenting, carries its own CiTO/CCO mapping, and is
directly queryable — *what supports this claim* is a slot traversal, not a
filtered scan of a polymorphic edge. The generic option is held in reserve
for a genuinely polymorphic relation, of which scimantic has none. This is
N&M's own counsel on domain and range — name the property and pin it to
the most general class that can bear it:

```admonish quote title="Noy & McGuinness 2001 — §Step 5, Domain and range"
When defining a domain or a range for a slot, find the most general
classes or class that can be respectively the domain or the range for the
slots. On the other hand, do not define a domain and range that is overly
general [...]. Do not choose an overly general class for range (i.e., one
would not want to make the range THING) but one would want to choose a
class that will cover all fillers.
```

### Inverses come from upstream, not from new slots

Every relation has a reverse reading — *what produced this result* is the
inverse of *what this act produced*. scimantic declares the forward
direction only, and leaves the reverse to the upstream `owl:inverseOf`
declarations its grounding inherits (mostly CCO's) plus SPARQL's `^prop`
path. It mints a second, explicit inverse slot only where a consumer must
traverse the reverse direction *without* a reasoner — for instance, where
a downstream consumer is built around it. The default halves the slot
count and avoids the drift v0.2 carried, where `isOutputOf` was an
explicit slot but `isInputOf` was derived, and the two could disagree.

### Store the edge; derive the aggregate

A provenance edge and the act, agent, and interval behind it are *primary
facts* — scimantic stores them. A roll-up computed from those facts is
not: a hypothesis's weight of evidence is a function of its
`supports`/`contradicts` edges, and whether a premise is *still* accepted
is a function of its state intervals and any later retraction.
Materializing those as stored slots would let them drift from the edges
they summarize, so scimantic derives them — by rule or SPARQL — rather
than storing them. The line is: store what an act asserts; derive what a
query computes.

### Cardinality from the competency questions

How many values a slot takes is read off the questions, not guessed. A
`Conclusion` draws on one *or more* premises, so the relation into it is
multivalued; an `Act` occupies exactly one `TemporalInterval`, so its time
slot is single and required; a `Hypothesis` is optional in a lineage
(ch05), so the relation that would reach it cannot be required. The
default is single-valued and optional, tightened to multivalued or
required only where a competency question demands a collection or a
mandatory filler. (N&M file cardinality under Step 6; scimantic decides it
alongside the slot, since the question that motivates a slot usually fixes
its multiplicity too.)

### Name for scimantic; map to the standard

Several relations have an upstream analogue: the claim relations align
with CiTO, act participation with CCO's process roles. scimantic keeps its
own names — `supports`, not `cito:supports` — and carries the upstream
term as an `exact_mappings` (the CiTO mappings are already on
`supports`/`contradicts`/`refines` from ch05). A domain-fit name reads
better in the schema and in instance data, and the mapping preserves the
interoperability a rename would buy, without adopting another vocabulary's
labels wholesale. The rule generalizes: name the relation for scimantic,
map it out.

With the policies set, the rest of the chapter is application. It takes the
relations in the order the classes came: the claim relations first (the
spine), then act participation, then the state attachments, and last the
fields the reified classes carry.

## The claim relations

The spine's three relations — `supports`, `contradicts`, and `refines` —
were minted in ch05 as a tracer, carrying only a range and their CiTO
mappings. Step 5 gives them the rest of their facets, and they are the
clearest place to watch the policies bite.

**Range is `Claim`, not its subtypes.** A claim relation runs claim to
claim, and any kind can sit at either end: evidence supports a conclusion,
a conclusion refines a hypothesis, one premise contradicts another. The
range is therefore the shared parent `Claim` — the superclass the spine
pressed ch05 into minting — not an enumeration of `Hypothesis`, `Evidence`,
and `Conclusion`. That is N&M's range rule:

```admonish quote title="Noy & McGuinness 2001 — §Step 5, Domain and range"
If a list of classes defining a range or a domain of a slot contains all
subclasses of a class A, but not the class A itself, the range should
contain only the class A and not the subclasses.
```

**Multivalued, optional.** One claim can bear on many: a single piece of
evidence supports several conclusions; a conclusion refines a string of
hypotheses. So each relation is multivalued. None is required — a claim
need not support, contradict, or refine anything.

**No inverse slot.** *What contradicts this claim* is the reverse of
`contradicts`, and the policy leaves it to a query — SPARQL `^contradicts`,
not a stored `isContradictedBy`. The reverse is derivable, so scimantic
does not double the slot.

**Stored edges, derived aggregate.** The edges are stored facts. The
roll-up they feed is not: a hypothesis's *weight of evidence* — how its
supporting evidence nets against its contradicting evidence — is computed
from these edges on demand, never materialized, so it cannot drift from
them.

Step 5 adds exactly one facet to each — the cardinality — over the bare
slots ch05 minted:

{{#diff scimantic-yaml-v3 scimantic-yaml-v4 context=5 caption="Cardinality on the claim relations"}}

**When the edge needs provenance, it reifies.** A bare `supports` edge
records *that* one claim bears on another; it has nowhere to hold *who*
asserted the support, *when*, or with *what* strength. When a question asks
for those — and the second pass does — the edge becomes an
`EvidentialRelation`, the node ch05 placed for exactly this. The bare slot and the reified node are two readings of one
link: the slot for the common case, the node when the relation itself
carries facts. `EvidentialRelation`'s own fields wait for the chapter's
last cluster.

## Act participation

The acts are where most of the provenance lives, so they carry most of the
relations. Four attach in this cluster; the two busiest — the input and
output edges — wait on a range question the section after settles.

**`agent` and `performedAt` attach at `Act`.** Every act has an agent who
performed it and an interval it ran over, so both sit at the shared `Act`
supertype and all nine acts inherit them — N&M's rule:

```admonish quote title="Noy & McGuinness 2001 — §Step 5"
A slot should be attached at the most general class that can have that
property.
```

`agent` ranges on `Agent`, multivalued (collaborative science gives an act
more than one), mapped to CCO's *has agent* (`cco:ont00001833`).
`performedAt` ranges on `TemporalInterval` — ch05's "when is an interval,
not an instant" — mapped to BFO's *occupies temporal region*
(`obo:BFO_0000199`).

**`tests` attaches at `DesignOfExperiment`.** ch05 settled that the
prospective intent to test a hypothesis rides on the *design act*, not the
method it produces, so `tests` (range `Hypothesis`) attaches there alone —
no other act bears it. It is scimantic's own: the upstream vocabularies
have no clean term for prospective experimental intent, so it carries no
mapping.

**`executes` attaches at `Experimentation` and `Analysis`.** An act that
runs a method `executes` it (range `Method`); only the two method-running
acts bear it, and they share no parent below `Act`, so it attaches at each.
Its mapping is the chapter's neatest catch: the intuitive name is
"realizes", but BFO `realizes` is reserved for *realizable entities* —
roles and dispositions — while a `Method` is *content* (a Prescriptive
ICE). The right relation is CCO's *prescribed by* (`cco:ont00001920`),
whose range is exactly Prescriptive ICE: the act is prescribed by the
method's plan specification.

The input and output edges remain. They are the acts' busiest relations —
the lineage questions (CQ 14, 15) walk them — but their fillers are diverse
(a `Dataset`, a `Result`, an `Annotation`, a `Method`), with no tight
common class to range over. How to range a relation whose fillers span the
schema is the open question, taken up next.

### Ranging the input and output edges

`hasInput` and `hasOutput` are the relations the lineage questions walk —
*what act produced this dataset*, *the acts feeding a conclusion* — so they
must be **single generic relations on `Act`**, not a thicket of per-act
slots a lineage query would have to union. That is the reasoning that made
`Act` a generic supertype, and it maps straight onto CCO's own generic
`has input` (`cco:ont00001921`) and `has output` (`cco:ont00001986`).

The catch is the range. An act's inputs and outputs span the schema — a
`Dataset`, a `Result`, an `Annotation`, a `Method`, a `Claim` — with no
single parent below "entity" to range over. N&M warns against both horns:

```admonish quote title="Noy & McGuinness 2001 — §Step 5, Domain and range"
Do not choose an overly general class for range (i.e., one would not want
to make the range THING) but one would want to choose a class that will
cover all fillers.
```

scimantic threads it with an **`any_of` union**: the base range enumerates
the artifact classes an act can touch, covering every filler without
inventing a near-THING superclass to retrofit onto ch05's hierarchy. The
precise per-act range — `Analysis.hasInput` is a `Dataset`,
`EvidenceExtraction.hasInput` an `Annotation` — is a `slot_usage`
refinement, and Chapter 7's central worked example.

The cluster's six slots, with their CCO/BFO mappings glossed:

{{#diff scimantic-yaml-v4 scimantic-yaml-v5 context=5 caption="Act participation slots"}}

With act participation wired, the next cluster turns to the state
attachments.

## State attachment

ch05 reified standing as a `State`, grounded in CCO's Stasis — *a process*
over which a claim holds an unchanging condition. Step 5 wires the three
relations that make a state a queryable node.

A state records *whose* standing it is, *which act* set it, and *over what
interval* it holds, so all three slots attach at the shared `State`
supertype and the standings inherit them:

- `qualifies` ranges on `Claim` or `Method` — the two things that bear a
  standing (a claim accepted or open, a method validated). It is scimantic's
  own: a Stasis presumes *independent continuants* endure, but scimantic's
  bearers are information content entities, so no upstream relation fits
  cleanly — the nearest, BFO `has participant`, is too generic to claim.
- `establishedBy` ranges on `Act`, mapped to CCO's *caused by*
  (`cco:ont00001819`): a state, itself a process, is caused by the act that
  conferred it.
- `occursOver` ranges on `TemporalInterval`, mapped to BFO's *occupies
  temporal region* (`obo:BFO_0000199`) — the same relation `performedAt`
  uses, because a `State` is a Stasis *process* and occupies its interval
  exactly as an act does.

The agent is not a fourth slot. The act that established a state already
carries its `agent`, so *who set this standing* is **derived** —
`establishedBy`, then the act's `agent` — not stored twice.

**`promotedFrom` is derived, not a slot.** ch05's evidence-to-premise
promotion is identity-preserving: the same claim acquires an `AcceptedState`,
no new node, no edge — so there is nothing to store. *What was this premise
promoted from* is answered by reading the claim's states (it gained an
`AcceptedState`, conferred by an `EvidenceAssessment`), a query over
`qualifies` and `establishedBy` — exactly the stored-versus-derived line the
policies drew.

{{#diff scimantic-yaml-v5 scimantic-yaml-v6 context=5 caption="State attachment slots"}}

With standing wired, the last cluster turns to the fields the reified
classes carry — the evidential relation, the uncertainty model, the evidence
line, and the study.

## The reified fields

Four of the classes ch05 placed are reifications: each turns a relationship
or a description into a node so it can carry its own provenance. Where
`supports` is a bare claim-to-claim edge, an `EvidentialRelation` is that
edge promoted to a node — and a node has to name its own endpoints. So it
carries a `subject` and an `object` (the two claims), a `polarity` for which
way it bears, a `strength`, and an `assertedBy` pointing at the act that
made the assertion. Agent and time aren't repeated on the relation: they
hang on that act, reached through `assertedBy`. As the claim-relations
cluster noted, the bare slot and the reified node are two readings of one
fact — the lightweight edge for the common case, the node when the
assertion's own provenance is what you need to record.

Both the bare slot and the reified node relate a claim to a claim —
domain and range alike are `Claim`. That raises a question neither
domain/range nor a facet can answer: may a claim bear on *itself*, and
does the bearing run both ways? Whether `refines` is irreflexive and
asymmetric, `contradicts` symmetric, `supports` neither — that is a
per-relation choice, deferred to Chapter 7, where LinkML's relational
slot characteristics can state it.

### Enumerate what's closed; leave open what isn't

`polarity` and `nature` get LinkML enums; `family` stays a string. The test
is whether the value space is closed. Polarity has exactly three members,
and they *are* the claim relations — so `EvidentialPolarity`'s permissible
values are `supports` / `contradicts` / `refines`, each carrying the same
CiTO `meaning` as the bare slot it mirrors. The reified polarity and the
lightweight edge then agree by construction, not by a parallel kept up by
hand. `nature` is the aleatory-versus-epistemic split — irreducible
randomness versus reducible ignorance — closed, but with no settled IRI:
it's a plain enum, and the URREF grounding flagged in Chapter 3 stays
deferred. `family` — Gaussian, bootstrap, a posterior draw — is open-ended;
enumerating it would be false precision, so it remains an open string.

### One strength, shared and still unbounded

`strength` is defined once and referenced by both `EvidentialRelation` and
`EvidenceLine`: the strength of a bearing reads the same whether the bearing
is a single relation or a line pooling several pieces of evidence under one
weight. It is a plain `float` here, as is `UncertaintyModel`'s
`confidenceLevel`. Their scales and bounds — strength on what interval,
confidence in [0, 1] — are *facets*, which N&M make Step 6 work; Chapter 7
sets them. `UncertaintyModel` also carries a `quantifies` edge to the
`Uncertainty` quality it models, so the descriptive node and the BFO quality
it describes are linked, not merely co-present.

### A study has *occurrent* parts

`Study` stands for a whole question-to-conclusion cycle, so its one slot is
`hasPart`, ranging over `Act`. The slot maps to BFO's *has occurrent part*
({{#callout has-part}}), not the general *has part* (`BFO_0000051`): a study
is a process and its parts are processes, so the occurrent-specific,
transitive relation is the exact one — generic parthood would drop the
commitment that these parts are themselves unfoldings in time.

{{#diff scimantic-yaml-v6 scimantic-yaml-v7 context=5 caption="Reified-class fields"}}

That closes Step 5: every class that needs slots now has them. What is left
is tightening, not adding — per-act narrowing of `hasInput` / `hasOutput`,
numeric bounds on `strength` and `confidenceLevel`, requiredness and
defaults — the facet work N&M reserve for Step 6, and the subject of
Chapter 7.
