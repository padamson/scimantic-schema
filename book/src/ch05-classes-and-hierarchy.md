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
  Entity, under BFO *continuant*), falling into a few of CCO's ICE kinds.
  The *claims* — hypotheses, evidence, results, conclusions — are
  **Descriptive** ICEs: content asserting what is or might be the case.
  A *question* is an ICE too, but interrogative rather than descriptive
  (it asks, it does not assert), so it grounds in the general ICE. The
  *methods* are **Prescriptive** ICEs (CCO's directive branch): content
  prescribing what to do. Datasets and annotations are ICEs alongside them.
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

```admonish info title="Grounding vs reuse: subclass_of and class_uri"
LinkML's `is_a` links classes *within* a schema; it cannot point at an
external term. So each anchor grounds in its BFO/CCO category with
**`subclass_of`**, LinkML's `rdfs:subClassOf` to an external CURIE, and
the domain classes that `is_a` the anchor inherit it (the pattern Biolink
uses to anchor in BFO). That is how scimantic *specializes* a category.
A class it *reuses wholesale* instead sets **`class_uri`** to the external
term directly, co-identifying with it rather than subclassing: `Dataset`
is `dcat:Dataset`, `Annotation` is `oa:Annotation`. (LinkML marks
`subclass_of` deprecated in favor of `is_a`, but `is_a` cannot reach an
external IRI, so it stays the tool for cross-ontology grounding.)
```

`Dataset` and `Annotation` make the `class_uri` side of that distinction
concrete {{#callout reuse-wholesale}}:

```yaml
{{#include listings/scimantic-yaml-v3.yaml:274:286}}
```

The remaining foundational kinds and artifacts take their places — `Agent`
grounded in CCO Agent {{#callout agent}} and an act's `TemporalInterval`
in BFO's one-dimensional temporal region {{#callout temporal-interval}},
`Question` under the general ICE {{#callout ice-general}}, `Result` a
Descriptive ICE {{#callout descriptive-ice}}, and `SourceDocument` a CCO
Document {{#callout document}} — the bearer evidence is drawn from, not the
content — leaving the contested decisions the rest of the chapter settles:

```yaml
{{#include listings/scimantic-yaml-v3.yaml:189:223}}
```

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
`OpenState`, `AcceptedState`, and `RetractedState` are subtypes of
`State`, each attached to the entity it qualifies. They are
kind-agnostic: the standing lives in the act that confers it and the
interval it holds over, not in a class per claim type, so three
adjudication standings cover every entity rather than one state each.
This is the cross-cutting decision of the cluster: once standing is a
state, the same three carry an open question, an accepted or retracted
premise, a conclusion accepted in review and standing until refuted, and
a method validated by execution. The next two decisions spend it.

In the schema, that is `State` and its three standings, each grounded in
CCO Stasis {{#callout stasis}}:

```yaml
{{#include listings/scimantic-yaml-v3.yaml:160:187}}
```

### Evidence and Premise: one claim, two standings

When assessed evidence becomes a premise, is that a new class, a status
on the old one, or a derivation? ch04 settled the framing: evidence and
premise are the same claim at two epistemic stages, not one claim
derived from another. With standing now modeled as state, the
resolution is direct.

A piece of evidence is an information content entity: a claim about the
world, under CCO's Descriptive Information Content Entity. An
`EvidenceAssessment`
weighs it for credibility and, if it passes, confers an `AcceptedState`.
The premise *is that same claim*, now bearing the accepted state. There
is no second class and no `derivedFrom` edge {{#callout claim-spine}}; `promotedFrom` is
identity-preserving, a transition in standing rather than the creation
of a new node. CQ 4 then filters evidence by a queryable state, and
CQ 5 — which needs a premise to be a node you can traverse *from* into
`HypothesisFormation` — is satisfied because the premise is the evidence
node itself, reached with no indirection.

Step 4 places the pieces — the `Evidence` claim, the `AcceptedState` it
comes to bear, and the `EvidenceAssessment` that confers it — but the
promotion *between* them is relational: a claim bearing a state, an act
conferring it. Those are slots, so the wiring that makes the promotion
queryable, and `promotedFrom` a transition rather than a phrase, is
Step 5 work that lands in Chapter 6. The listings here show the
participating classes; the slots that carry a promotion come with the
rest of the slot work. This is also why the three pieces sit in three
different listings below — the claim layer, the states, and the acts —
rather than in one place: nothing yet binds them into a single view.

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
scimantic took from EXPO — the experiment ontology Chapter 4 declined to
reuse, because it builds on SUMO rather than the BFO/CCO base — is that
some inquiry is exploratory, with no prior hypothesis to test. Forcing a `Hypothesis`
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

The claim layer is a single abstract `Claim`, grounded in CCO's
Descriptive Information Content Entity {{#callout ice}} by `subclass_of`
{{#callout grounding}}, over `Hypothesis`, `Evidence`, and `Conclusion`:

```yaml
{{#include listings/scimantic-yaml-v3.yaml:45:78}}
```

It carries the three claim relations, mapped to CiTO and bound for
reification into an `EvidentialRelation` when this chapter reaches it {{#callout cito-supports}}:

```yaml
{{#include listings/scimantic-yaml-v3.yaml:288:307}}
```

With the spine fixed, the next cluster turns to method and act.

## Method and act

Three questions (CQ 8, 9, and 10) turn on a single decision: is an
experimental method a reusable template, or a thing made fresh for each
study? ch04 named this the chapter's biggest single tension. It resolves
the way Evidence and Premise did, by dissolving the dichotomy.

A method is a **plan specification**: a Prescriptive information
content entity (CCO's directive branch) that prescribes how to carry
out an act. As an ICE it is a
continuant, existing independently of any particular run, and an act
*realizes* it. `Experimentation` realizes an `ExperimentalMethod`;
`Analysis` realizes an `AnalyticalMethod`. That is the reusable,
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
places. And the `State` pattern reaches methods too, a method gaining an
`AcceptedState` when a successful execution validates it, as a premise
gains one when an assessment accepts it.

Which CCO relation `executes` should map to, rather than a freshly
minted slot, is a Step 5 question that waits with the other slot
decisions for Chapter 6.

Both halves are in the schema now. The `Method` plan specifications,
grounded in CCO's Prescriptive ICE {{#callout prescriptive}}, with
`ExperimentalMethod` and `AnalyticalMethod` under the general `Method`:

```yaml
{{#include listings/scimantic-yaml-v3.yaml:139:158}}
```

And the nine acts that realize them, under the `Act` supertype
{{#callout planned-act}}:

```yaml
{{#include listings/scimantic-yaml-v3.yaml:80:137}}
```

With method and act placed, the next cluster asks when a value or an
edge should become a node of its own: the reification questions behind
uncertainty and the evidential relation.

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
higher-level layer — the chapter's capstone — so it is introduced there,
not here.

In the schema, that reified node is the `EvidentialRelation`
{{#callout evrel-ice}}:

```yaml
{{#include listings/scimantic-yaml-v3.yaml:225:231}}
```

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

Chapter 3 committed to URREF in principle for exactly this: the model's
**nature** facet, aleatory versus epistemic, is URREF's distinction. But
nothing binds in this chapter. `nature` is itself a Step-5 slot (Chapter
6), and URREF's namespace is still the provisional placeholder Chapter 3
flagged — so the `UncertaintyModel` carries no `urref:` mapping here.
scimantic adopts the distinction now and defers its encoding — a `urref:`
mapping, or a plain enum if URREF's IRIs never settle — to Chapter 6. And
it would be a *mapping* target, not a grounding: scimantic stays grounded
in BFO/CCO and points out to URREF the way the claim relations point to
CiTO, on the deferred footing Chapter 3 set.

CQ 12's second half, *how was it derived*, is a relationship the
reification policy sends to an act. By what statistical method were the
result's uncertainty and credibility computed, from what inputs, by which
agent? Those are properties of a derivation, so the derivation is an act:
a deriving act applying a **`StatisticalMethod`**, which is a `Method` in
the sense the last cluster fixed, a Prescriptive ICE realized by the act
that carries it out. Credibility is the simpler sibling of uncertainty, a
graded quality whose provenance is the `EvidenceAssessment` that produced
it, with no structured model of its own.

In the schema, the uncertainty cluster is two BFO qualities
{{#callout quality}} — `Uncertainty` and `Credibility` — the
`UncertaintyModel` {{#callout model-ice}} that quantifies the first, and
the `StatisticalMethod` that derives them:

```yaml
{{#include listings/scimantic-yaml-v3.yaml:233:258}}
```

With reification settled, what remains is the layer above the individual
artifacts: whether the evidence line, the `Claim` superclass the spine
pressed for, and a `Study` container earn a place. That is the
higher-level layer, and it is the last cluster.

## The higher-level layer

The last cluster asks whether anything sits *above* the individual
artifacts, or whether the flatter, artifact-by-artifact vocabulary is
enough. ch04 surfaced three candidates from the *neighbors* questions.
One — the `Claim` superclass — the spine already settled and the schema
already has: the neighbors question (*given any claim, hypothesis,
premise, or conclusion, what supports and what challenges it?*) only
confirms why a queryable parent had to exist, and `Claim` is the parent an
`EvidentialRelation` links. The other two are new, and each is demanded.

**An `EvidenceLine`.** The reification section deferred this grouping to
here. The neighbors ask *how many independent lines of evidence back a
conclusion, and how strong is each?* A query cannot count lines or weigh
them unless a line is a thing. So an `EvidenceLine` is the reified
grouping the policy pointed to: a Descriptive ICE collecting several
pieces of evidence under one strength, asserting their joint bearing on a
claim. This is the closest
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

Each was forced by a neighbors question rather than chosen for elegance:
`EvidenceLine` discharges the reification the earlier section deferred,
and `Study` gives the acts and artifacts of one inquiry a container to
belong to. With them placed — and `Claim` already settled — the
structural work of Step 4 is done.

In the schema, the higher-level layer adds `EvidenceLine`
{{#callout line-ice}} and the `Study` container {{#callout study-act}}
(the `Claim` superclass the spine pressed for is already in place):

```yaml
{{#include listings/scimantic-yaml-v3.yaml:260:272}}
```

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
