# Classes and Hierarchy

This chapter applies **Step 4** of *Ontology Development 101* (Noy &
McGuinness, 2001) to scimantic.

```admonish quote title="Noy & McGuinness 2001 — §Step 4"
There are several possible approaches in developing a class hierarchy
(Uschold and Gruninger 1996): A *top-down* development process starts
with the definition of the most general concepts in the domain and
subsequent specialization of the concepts. A *bottom-up* development
process starts with the definition of the most specific classes, the
leaves of the hierarchy, with subsequent grouping of these classes into
more general concepts. A *combination* development process [...] defines
the more salient concepts first and then generalizes and specializes
them appropriately.
```

ch04 produced the salient concepts bottom-up, by reading the competency
questions. This chapter places them top-down, under the BFO and CCO
categories [Chapter 3](ch03-reusing-existing-ontologies.md) committed
to. That is N&M's *combination* approach, and it is where the schema
starts to grow: ch04 was nearly free of code, but Step 4 turns the
vocabulary into classes.

The work of the chapter is the ledger ch04 left
[unsettled](ch04-important-terms.md#what-the-list-leaves-unsettled).
Those decisions are not independent, so the chapter takes them in
dependency order: first the scaffold under BFO/CCO, then the **claim
spine** (the core of the method), then **method and act**, then the
**reification** questions, and last the **higher-level layer** that
depends on all of them. Two decisions are slot-shaped rather than
hierarchy-shaped (which named relations become real slots, and which
are stored versus derived); those belong to Step 5 and wait for
Chapter 6.

## Anchoring to BFO and CCO

Every scimantic class ultimately subclasses one of the foundational
kinds Chapter 3 committed to. Placing the harvest under them is mostly
mechanical:

- **Artifacts** are information content entities (CCO Information Content
  Entity, under BFO *continuant*), and they fall into two of CCO's ICE
  kinds the chapter leans on. The *claims* (questions, hypotheses,
  evidence, results, conclusions) are **Descriptive** ICEs: content
  asserting what is or might be the case. The *methods* are **Directive**
  ICEs: content prescribing what to do. Datasets and annotations are
  ICEs alongside them.
- **Acts** — the formations, searches, assessments, experiments,
  analyses — are planned acts (CCO Planned Act, under BFO *occurrent*).
- **States** are conditions grounded in CCO Stasis (the subject of the
  next section).
- **Qualities** (credibility, the uncertainty facets) are BFO qualities.
- **Agents** are CCO Agents.
- **Temporal regions** locate the occurrents in time (BFO temporal
  region).

Two placements here are forced by the questions, not chosen, and the
chapter records them rather than deliberating them. CQ 10, 14, and 15
quantify over acts generically — *what act produced this dataset*, *the
acts in the lineage* — so `Act` has to be a real shared supertype over
the nine act classes, not a reading-group label. And CQ 14's "when" is
an interval: acts are occurrents that unfold over time, so an act is
located at a `TemporalInterval`, not stamped with a single `createdAt`
instant, which would be false for an experiment that runs for days.
These are the scaffold the contested decisions hang on.

## The claim spine

The core of the method is the chain from a question, through evidence
and premises, to a hypothesis and a conclusion. Three of ch04's open
decisions shape it, and they lock together: how standing is modeled,
what distinguishes evidence from a premise, and whether a hypothesis is
mandatory. They are taken in that order because each constrains the
next.

### Standing as state, not status

v0.2 recorded an act's lifecycle phase as an enum value on a `status`
slot. The rebuild does not. An enum value is a scalar: it can say a
premise is *accepted*, but it carries no interval over which the
acceptance holds and no trace of the act that conferred it. Every
standing the competency questions ask about is temporal and
provenanced. CQ 4 returns evidence an assessment *accepted*; the
second pass's gaps questions ask whether a premise is *still* accepted
or has been *retracted*, a question about an interval closed by a later
act.

So scimantic models standing as a reified **State**, grounded in CCO's
*Stasis*: a condition that obtains over a `TemporalInterval` and points
back to the act that established it and the agent who performed it.
`OpenState`, `AcceptedState`, `RetractedState`, and `StandingState` are
subtypes of `State`, each attached to the entity it qualifies. This is
the cross-cutting decision of the cluster: once standing is a state, the
same pattern carries an open question, an accepted or retracted premise,
a conclusion standing unrefuted, and a method validated by execution.
The next two decisions spend it.

### Evidence and Premise: one claim, two standings

When assessed evidence becomes a premise, is that a new class, a status
on the old one, or a derivation? ch04 settled the framing: evidence and
premise are the same claim at two epistemic stages, not one claim
derived from another. With standing now modeled as state, the
resolution is direct.

A piece of evidence is an information content entity: a claim about the
world, under CCO's Information Content Entity. An `EvidenceAssessment`
weighs it for credibility and, if it passes, confers an `AcceptedState`.
The premise *is that same claim*, now bearing the accepted state. There
is no second class and no `derivedFrom` edge; `promotedFrom` is
identity-preserving, a transition in standing rather than the creation
of a new node. CQ 4 then filters evidence by a queryable state, and
CQ 5 — which needs a premise to be a node you can traverse *from* into
`HypothesisFormation` — is satisfied because the premise is the evidence
node itself, reached with no indirection.

One distinction still earns a name. *Accepted* is a state, the outcome
of assessment. *Premise* is better read as a **role**, in BFO's sense of
a realizable entity: a claim plays the premise role when it serves as an
input to a particular hypothesis formation, and the same claim can be a
premise in one argument and not in another. scimantic models acceptance
as the Stasis state and premise-hood as the role an accepted claim
realizes when a `HypothesisFormation` takes it as input. The claim is
one node; its acceptance and its use are recorded without cloning it.

### Hypothesis is optional

Does the chain require a hypothesis? The seeded vocabulary runs Question
→ Hypothesis → Evidence → Conclusion, which reads as though every
conclusion descends from a hypothesis. [Chapter 2's
scope](ch02-domain-and-scope.md#what-domain-does-scimantic-cover) says
otherwise: it admits a literature-only meta-analysis, and the lesson
scimantic took from EXPO (Step 2's decline) is that some inquiry is
exploratory, with no prior hypothesis to test. Forcing a `Hypothesis`
node into every lineage would mismodel exactly the inquiry the domain
claims to cover.

So a `Conclusion` may trace to its premises and evidence with or without
an intervening `Hypothesis`. The hypothesis is a node that can sit in a
lineage, not a required link in it.

This leaves a consequence for the higher-level layer to collect. If the
spine must carry `supports`, `contradicts`, and `refines` whether or not
a hypothesis is present, those relations cannot range on `Hypothesis`
alone; they need a shared parent over everything a claim relation can
touch — hypothesis, premise, conclusion alike. The pressure for a
`Claim` superclass starts here, and the chapter settles it when it
reaches that layer.

With the spine fixed, the next cluster turns to method and act.

## Method and act

Three questions (CQ 8, 9, and 10) turn on a single decision: is an
experimental method a reusable template, or a thing made fresh for each
study? ch04 named this the chapter's biggest single tension. It resolves
the way Evidence and Premise did, by dissolving the dichotomy.

A method is a **plan specification**: a Directive information content
entity that prescribes how to carry out an act. As an ICE it is a
continuant, existing independently of any particular run, and an act
*realizes* it. `Experimentation` realizes an `ExperimentalMethod`;
`Analysis` realizes an analytical method. That is the reusable,
one-to-many shape CQ 9 ("what experiments executed a given method") and
CQ 10 ("what *act* applied a method") require: a method is executed by
many acts, and "act" generalizes across experimentation and analysis,
which pushes `ExperimentalMethod` up under a general `Method`. A generic
template and a study-specific protocol are then both plan specifications
at different grain, not two classes, and the template-versus-instance
framing falls away.

What does not live on the method is intent. A reusable method cannot
itself be "designed to test hypothesis H," because the same method
serves different hypotheses in different studies. The thing designed to
test H is the act that designed it. So `tests`, the prospective intent
CQ 8 asks for, attaches to `DesignOfExperiment`, not to `Method`. CQ 8's
"methods designed to test H" becomes a traversal: from the hypothesis,
back along `tests` to the design act, forward to the method it produced.
The method's type-level *capability* (the kind of hypothesis it can
test) is a separate affordance no question demands, so it waits.

Placing `tests` on the design act keeps it the distinct verb ch04
insisted on. `tests` is prospective intent, carried by a design act
before the evidence is in; `supports` and `contradicts` are
retrospective verdicts, carried by the evidence after. They never
collapse, because they sit on different nodes: an act and a claim.

Two threads from the spine run through here. A method is realized by an
act exactly as a premise's role is realized by a hypothesis formation:
the schema leans on BFO's one machinery for realizable entities in both
places. And the `State` pattern reaches methods too, a method gaining a
`ValidatedState` once an execution succeeds, as a premise gains an
accepted one.

Which CCO relation `executes` should map to, rather than a freshly
minted slot, is a Step 5 question that waits with the other slot
decisions for Chapter 6. With method and act placed, the next cluster
asks when a value or an edge should become a node of its own: the
reification questions behind uncertainty and the evidential relation.

## Reification: when an edge becomes a node

Some of what the questions ask for is not a thing but a relationship, and
a relationship can be modeled two ways: as a bare edge between two nodes,
or as a node of its own that both endpoints point to. Promoting an edge
to a node is *reification*, and it has a cost, an extra node on every
instance of the relationship. So the rule is not to reify everything, nor
nothing, but to reify on demand: a relationship becomes a node exactly
when a question asks for a property of the relationship itself, not just
of its endpoints.

scimantic has already reified its core relationships without naming it.
Every transformation in the method is an act, and an act is a node that
carries its own agent, time, inputs, and outputs, so the deriving of a
result, the forming of a hypothesis, and the assessing of evidence are
nodes already. The reification question is only about the relationships
the act model leaves as edges.

One of them earns a node. `supports`, `contradicts`, and `refines` are
edges from a claim to the claim it bears on, and for most purposes that
is enough. But the second pass asks more: for a given support, *which act
and agent established it, when, and with what strength*. Those are
properties of the support itself, which a bare edge has nowhere to hold.
So the support becomes an **`EvidentialRelation`**, a node reifying a
`cito`-typed link between two claims and carrying its polarity (the
`cito` mapping), a strength, the asserting act, and the agent. It is a
Descriptive ICE in its own right: a recorded claim that one claim bears a
given relation to another.

The other relationships stay edges. `derivedFrom` runs between artifacts,
but every derivation already has an act behind it that holds the agent
and the inputs, and reifying the edge as well would record the same
provenance twice. The evidence *line*, which groups several pieces of
evidence under one strength, is a reification too, but it belongs to the
higher-level layer, the chapter's capstone, so it waits there.

## Uncertainty as a model, not a number

The starting vocabulary carried uncertainty as a number on a result.
CQ 12 asks for more than a number: *what is the uncertainty model for a
given result, and how was it derived?* A model is a family (Gaussian,
bootstrap, posterior), its parameters, a confidence level, and a nature
(aleatory or epistemic). A scalar slot cannot hold that bundle. So
uncertainty is a class, the same reification move the last section made:
a value the questions interrogate becomes a node.

Two things hide in that class, and keeping them apart is the decision.
The *uncertainty* is a quality of the result: the result is uncertain,
and that quality inheres in it.

```admonish info title="Jargon: inheres in"
A dependence relation: a quality (or any specifically dependent entity)
**inheres in** a bearer, meaning it cannot exist on its own, only as a
quality *of* something. A result's uncertainty inheres in the result and cannot exist without
it. Inherence is that tie between a quality and the thing that has it.
```

The *model* is information that quantifies the quality: the choice of
family and the fitted parameters are content about the uncertainty, not
the uncertainty itself. So scimantic models an **`UncertaintyModel`**, a
Descriptive ICE that quantifies the result's uncertainty quality, rather
than loading structure onto a bare quality. The quality stays a BFO
Quality, as Chapter 3 grounded it; the model is the ICE that describes
it.

This is where URREF binds. Chapter 3 committed to URREF in principle and
pinned it behind a thin placeholder until the uncertainty classes landed;
they land here. The model's **nature** facet, aleatory versus epistemic,
is URREF's distinction, so the `UncertaintyModel` and its `nature` carry
`urref:` mapping annotations where the IRIs are stable, holding the
deferred-binding posture Chapter 3 set for the rest.

CQ 12's second half, *how was it derived*, is a relationship the
reification policy sends to an act. By what statistical method were the
result's uncertainty and credibility computed, from what inputs, by which
agent? Those are properties of a derivation, so the derivation is an act:
a deriving act applying a **`StatisticalMethod`**, which is a `Method` in
the sense the last cluster fixed, a Directive ICE realized by the act
that carries it out. Credibility is the simpler sibling of uncertainty, a
graded quality whose provenance is the `EvidenceAssessment` that produced
it, with no structured model of its own.

With reification settled, what remains is the layer above the individual
artifacts: whether the evidence line, the `Claim` superclass the spine
pressed for, and a `Study` container earn a place. That is the
higher-level layer, and it is the last cluster.

## The higher-level layer

The last decision is whether to build a layer above the individual
artifacts or keep the flatter vocabulary the harvest produced. ch04
surfaced three candidates from the *neighbors* questions, and those same
questions settle them: each is demanded, so each earns a place.

**A `Claim` superclass.** The spine already pressed for it. Because a
hypothesis is optional in the chain, `supports`, `contradicts`, and
`refines` cannot range on `Hypothesis`; they need a shared parent over
everything a claim relation can touch. The neighbors question makes the
demand explicit: *given any claim, hypothesis, premise, or conclusion,
what supports and what challenges it?* A query cannot range over "any
claim" unless the schema names one. So `Claim` is a Descriptive ICE over
`Hypothesis`, `Evidence` (and the premise it becomes), and `Conclusion`:
the things that assert something about the world, and the things an
`EvidentialRelation` connects. With `Claim` in place, that relation gets
its precise shape at last, a reified link from one claim to another.

**An `EvidenceLine`.** The reification section deferred this grouping to
here. The neighbors ask *how many independent lines of evidence back a
conclusion, and how strong is each?* A query cannot count lines or weigh
them unless a line is a thing. So an `EvidenceLine` is the reified
grouping the policy pointed to: an ICE collecting several pieces of
evidence under one strength, bearing on a claim. This is the closest
scimantic comes to an off-the-shelf model. SEPIO names an *evidence
line* for exactly this, and Micropublications reifies evidence the same
way; both become mapping targets on the deferred footing Chapter 3 set
for SEPIO, citing the pattern and binding the IRIs once they settle.

**A `Study`.** The neighbors ask *which acts and artifacts belong to the
same study?* That needs a study to be a node the rest belong to. So a
`Study`, or `Investigation`, is a container over one
question-to-conclusion cycle. Unlike the other two it sits on the act
side, not the artifact side: a planned process whose parts are the
formations, searches, experiments, and analyses of one inquiry, grounded
in CCO's planned-process layer. OBI offers an *investigation* class for
the same idea, and OBCS or STATO a home for the `StatisticalMethod` the
reification section named; both stay candidate mappings, deferred until
scimantic mints the classes, as the second pass left them.

Each of the three was forced by a neighbors question rather than chosen
for elegance, and each closes a thread left open earlier: `Claim`
answers the spine's pressure, `EvidenceLine` discharges the deferred
reification, and the typed `EvidentialRelation` finally has its
claim-to-claim shape. The structural work is done.

## Next

Step 4 is settled. Every term has a class, and every class a place under
BFO and CCO. The decisions ch04 left open have answers, the forced
placements are made, and the higher-level layer is in.

What remains is slot work, and it is Step 5. Chapter 6 settles three
questions this chapter left to it:

- which of the named relations become real slots, and which are a
  generic relation with a typed range;
- whether each inverse is stored or derived by the reasoner;
- whether scimantic renames its claim relations to CiTO's, or keeps its
  own and maps them with `skos:closeMatch`.

That is where the classes this chapter shaped get their properties.
