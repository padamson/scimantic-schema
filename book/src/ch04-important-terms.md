# Important Terms

This chapter applies **Step 3** of *Ontology Development 101* (Noy &
McGuinness, 2001) to scimantic.

```admonish quote title="Noy & McGuinness 2001 — §Step 3"
It is useful to write down a list of all terms we would like either to
make statements about or to explain to a user. What are the terms we
would like to talk about? What properties do those terms have? What
would we like to say about those terms? [...] Initially, it is
important to get a comprehensive list of terms without worrying about
overlap between concepts they represent, relations among the terms, or
any properties that the concepts may have, or whether the concepts are
classes or slots.
```

The temptation in this step is to start organizing. N&M say not to:
the goal is a comprehensive list, not a sorted one. Overlap is fine;
whether a term becomes a class or a slot, and where it sits in a
hierarchy, is later work (Chapters 5 and 6). This chapter only gathers
the vocabulary.

That also means it is nearly free of code. Harvesting terms changes
nothing on its own, and the schema is almost as Chapter 3 left it; the
one exception is the second pass's reuse step, which commits a single
new prefix, `cito:` (its diff appears below). Otherwise the output of
this step is the list itself, plus what ch02 anticipated: harvesting
terms surfaces *new competency questions*, which we let happen and
record.

## How the competency questions drive the vocabulary

N&M's method is that the [competency questions from
Chapter 2](ch02-domain-and-scope.md#what-questions-should-the-ontology-answer)
— the sketch of questions a scimantic knowledge base should be able to
answer — tell you which terms you need: a knowledge base can answer a
question only if its vocabulary names the things the question asks
about. So we read each question the way someone writing the query
against the finished graph would: the question fixes a node to start
from, a thing to return, and a path of edges between them. The terms
the question demands are the node-types and edge-types on that path,
plus the ones it quietly presupposes.

What follows walks all fifteen questions in clusters, harvesting terms
as it goes. The harvest has three moves: it **carries** the
terms ch02/ch03 and v0.1/v0.2 already settled, it adds the ones a
question **surfaces** (marked *(new)*), and it **reconsiders** the v0.2
terms no question demands. A ground-up rebuild should prune as well as
accrete, so the terms the questions retire are collected at the end,
once every question, original and surfaced, has been asked.

## Walking the questions

### The search–question loop (CQ 1–2)

*"What questions did a given literature search address?"* (CQ 1) and
*"What new questions did a given literature search surface?"* (CQ 2)
are mirror images. CQ 1 reads a search's **input** questions (the ones
motivating it); CQ 2 reads its **output** questions (the ones it
raised). Together they demand that a single `Question` node be able to
play both roles — output of one act, input to a later one — which is
the shape of the whole method: a search raises questions that drive
the next search.

A literature search also ranges over something. The question says
"literature *search*," which presupposes the literature: the
documents searched. That forces a new artifact, **SourceDocument**,
that the search ranges over and that annotations later point at. v0.1
and v0.2 only had a free-form `source` string; CQ 3 will make the node
unavoidable.

New terms this pair forces: **SourceDocument** (artifact); the
relations **addresses** (search → its motivating question) and
**surfaces** (search → a question it raised), both specializations of
the generic `hasInput`/`hasOutput` that let a query tell a search's
motivating question apart from its document inputs and its raised
outputs; and a latent **open** state on a question (a search addresses
and raises *open* questions).

### The evidence-to-hypothesis spine (CQ 3–5)

These three chain into the core of the method. *"What annotations on
source documents grounded a given piece of Evidence?"* (CQ 3) runs
`Evidence → Annotation → SourceDocument`, with the annotation pinned to
a span by its `TextSelector` and offsets. *"What evidence has been
assessed for credibility and accepted as Premise?"* (CQ 4) filters
evidence by an assessment and its outcome. *"From which premises was a
given hypothesis synthesized?"* (CQ 5) returns the premises that a
`HypothesisFormation` act combined into the hypothesis.

CQ 4 is the sharp one. It needs the **outcome** of an
`EvidenceAssessment` — accepted, rejected, or deferred — as something
queryable, so it can return only the accepted evidence; and it needs
the link from accepted evidence to the **Premise** it became. That
link is not generic `derivedFrom`: Evidence and Premise are the *same
claim* at two epistemic stages, not one claim derived from another.
This is the Evidence/Premise overlap ch04 flagged earlier made
concrete: CQ 4 is the query the eventual modeling choice (two classes,
or one class with a status) has to serve, and CQ 5 then requires that a
premise be a node you can traverse *from*.

New terms: **AssessmentOutcome** (accepted / rejected / deferred);
the relations **groundedIn** (evidence → annotation), **promotedFrom**
(premise → the evidence it was accepted as), and **synthesizedFrom**
(hypothesis → its premises); a graded **credibility** value rather than
a bare flag (assessing *for* credibility implies a measured value); and
an **accepted** / premise-standing state — the previously thin
*States* kind gains its first well-motivated members here, since "being
a premise" is a condition that holds over an interval until retracted.

### Support and contrast (CQ 6–7)

*"Which evidence supports or contradicts a given hypothesis?"* (CQ 6)
is the question the starting vocabulary was seeded from; everything it
names is already present (`Evidence`, `Hypothesis`, `supports`,
`contradicts`). Its only new pressure is latent: if scimantic ever
wants to say *who* asserted that support, *when*, or *how strongly*,
the support edge has to become a node of its own (a reified
**evidential relation**), not a bare property.

*"For two competing hypotheses, what evidence has been gathered on
each side?"* (CQ 7) adds the first genuinely new *idea* to the
vocabulary: **contrast**. Up to here every relation has been lineage
(this came from that). CQ 7 needs two hypotheses to stand as
*rivals*, which nothing in the vocabulary expresses. It forces
**competesWith** (a symmetric hypothesis–hypothesis relation). And it
exposes a missing edge underneath it: two hypotheses compete *because
they answer the same question*, so there is a presupposed
**addresses** relation from a `Hypothesis` back to the `Question` it
answers — currently unstated. Whether competition is asserted directly
or derived from a shared question is a later decision; the terms go on
the list now.

### Method, experiment, dataset (CQ 8–11)

This cluster pivots on acts and methods, and the four questions cannot
be answered independently. *"What experimental methods were designed
to test a given hypothesis, and what evidence informed the design?"*
(CQ 8) needs a **tests** relation — and `tests` is a different verb
from `supports`/`contradicts`: it is *prospective intent* (we built
this to probe the hypothesis), where support is *retrospective verdict*
(the evidence came back and bears on it). The vocabulary must keep the
two apart.

*"What experiments executed a given experimental method?"* (CQ 9) needs
an **executes** relation tying an `Experimentation` to the
`ExperimentalMethod` it ran — an edge the vocabulary lacks. (In
BFO/CCO terms a method is a *plan specification* that an act *realizes*,
so this may reuse an upstream relation rather than mint a fresh one.)
*"What act produced a given dataset, and what method did it apply?"*
(CQ 10) widens both: it says "what *act*," not "what Experimentation,"
so it quantifies over acts generically and needs **Act** to be a real
superclass, not just a reading-group label; and an `Analysis` that
produced a dataset also "applied a method," which pushes
`ExperimentalMethod` toward a more general **Method**. *"What
dataset(s) did a given analysis consume to produce a result?"* (CQ 11)
reads inputs and outputs through one act node, and the idiomatic verbs
**consumes** / **produces** show up as candidate typed readings of
`hasInput`/`hasOutput`.

The four together force the chapter's biggest single tension: **is an
ExperimentalMethod a reusable template or a per-study instance?** CQ 9's
many-to-many "executed by" and CQ 10's "any act applies a method" both
argue for a reusable template plus a general `Method`, which in turn
argues that CQ 8's `tests` belongs on the *design act*, not the method.
Three questions, one decision — deferred to Chapter 5.

New terms: **tests** (design/method → hypothesis, prospective);
**executes** (act → method); **Act** (generic superclass); **Method**
(generalization of ExperimentalMethod, with experimental and analytical
sub-kinds); the typed readings **consumes** / **produces**; and a
cluster of optional descriptors the questions gesture at — a design
**rationale**, an execution **fidelity**/deviation, and per-execution
**parameter bindings** distinct from a method's default Parameters.

### Uncertainty and conclusions (CQ 12–13)

*"What is the uncertainty model for a given Result, and how was it
derived?"* (CQ 12) is the strongest pull toward promoting **uncertainty
from a slot to a structured class**. The word "model" means uncertainty
is not a scalar: it carries a model family (Gaussian, bootstrap,
posterior), its **parameters** and **confidence level**, and a
**nature** (aleatory or epistemic, the URREF distinction ch03
committed to). And "how was it derived" straddles two readings —
derivation as a *descriptive attribute* (URREF-style metadata) or as a
*deriving act* (an error-propagation or calibration step with its own
inputs and agent). The question gives different answers depending on
which the schema picks.

*"What conclusions derive from a given experimental result?"* (CQ 13)
forces almost no new noun but presses a relation: `derivedFrom`
(conclusion → result) must stay *consistent with* the act path behind
it (a `ResultAssessment` that took the result in and put the conclusion
out), so that CQ 13's answers compose into CQ 15's lineage. The
adjective "experimental" also presupposes a way to tell a result's
origin — recoverable by tracing back to an `Experimentation` act rather
than by a new attribute.

Terms, new and reconsidered: a structured **uncertainty** (model,
nature, derivation, parameters, confidence level), of which `model`,
`parameters`, and `confidence level` are new. **UncertaintyDerivation**
is *not* new but a v0.2 class CQ 12 re-surfaces. And v0.2's four
fine-grained natures (`Ambiguity`, `Vagueness`, `Incompleteness`,
`Aleatory`) fold into the coarse aleatory/epistemic `nature` the
question actually asks for. Plus the relations **hasModel** /
**hasNature** linking an uncertainty to its facets, and a candidate
**statistical / inference method** as the thing that produces
uncertainty and credibility values (see the comparative findings
below).

### Agency, time, and lineage (CQ 14–15)

*"Who (which Agent) performed a given act, and when?"* (CQ 14) is the
question that promotes **time** from background grounding to a named
term. The "who" half reuses `hasAgent`. The "when" half is where the
precision lives: acts are occurrents that *unfold in* time (ch03's
continuant/occurrent backbone), so an act's "when" is a temporal
*region* — an interval — not merely a creation instant. The starting
vocabulary only had `createdAt`, which silently asserts every act is
instantaneous; that is false for an Experimentation running for days.
CQ 14 forces a real, interval-capable temporal term and the relation
that attaches it.

*"What are the acts in the lineage of a given conclusion, traced back
to the originating question?"* (CQ 15) is the capstone: a recursive
provenance query that exercises the whole graph. To enter the chain
from a conclusion you traverse *backward* from artifact to act, so it
forces **producedBy** — the named inverse of `hasOutput` — as a
first-class, traversable relation. It needs `precededBy` and
`derivedFrom` to be **transitive** (the recursion is a property path).
And it surfaces that lineage is encoded *three ways at once* — act-to-
act `precededBy`, artifact-to-artifact `derivedFrom`, and the
act↔artifact threading of `hasInput`/`hasOutput` — which must be kept
mutually consistent. CQ 15 also quietly assumes the provenance graph is
a **DAG**: lineage is generally a converging tree, "the originating
question" may be plural, and an act can never precede one that occurred
later.

New terms: **TemporalRegion** (with the **instant** vs **interval**
distinction, and **startTime** / **endTime** / **duration**); the
relation **occursAt** / **hasTemporalRegion** (act → time);
**producedBy** (artifact → its producing act — v0.2's `isOutputOf`,
renamed to read as a relation); an optional materialized
**hasOriginatingQuestion** shortcut; and the recorded *characteristics*
that lineage demands — transitivity on `precededBy`/`derivedFrom` and
an acyclicity assumption on the whole graph.

## The vocabulary, enlarged

Collecting the harvest. Terms carried from ch02/ch03 are plain; terms
**surfaced by reading the questions closely** are marked *(new)*. The
grouping is for reading only — it is not the class hierarchy, and a
term's group does not decide class-versus-slot.

**Artifacts**

- Question, Hypothesis, Evidence, Premise, Result, Conclusion
- ExperimentalMethod (with Parameters); **Method** *(new — generalizes
  ExperimentalMethod to cover analytical methods)*
- Dataset
- Annotation (with TextSelector)
- **SourceDocument** *(new — the document a search ranges over and an
  annotation targets)*
- **AssessmentOutcome** *(new — accepted / rejected / deferred verdict
  of an assessment)*

**Acts**

- QuestionFormation, LiteratureSearch, EvidenceExtraction,
  EvidenceAssessment, HypothesisFormation, DesignOfExperiment,
  Experimentation, Analysis, ResultAssessment
- **Act** *(new — the generic superclass CQ 10/14/15 quantify over)*
- **UncertaintyDerivation** *(from v0.2; conditional — only if
  uncertainty derivation is modeled as an act)*

**Agents**

- Agent, with Person, Group (of researchers), Organization

**Qualities and other attributes**

- uncertainty *(carried, but CQ 12 pushes it toward a structured term)*
  with **model**, **nature** (aleatory/epistemic), **derivation**,
  **parameters**, **confidence level** *(the last two new)*
- credibility, and a graded **credibility value** *(new)*
- value, unit
- the selector offsets: exact, prefix, suffix, startOffset, endOffset,
  pageNumber
- label, citation, source, content, accessLevel, publishable
- **startTime**, **endTime**, **duration** *(new — interval "when")*
- candidate descriptors *(new, optional)*: design **rationale**,
  execution **fidelity**/deviation, per-execution **parameter
  bindings**, result **origin/kind**, lineage **step order**

**States** *(the thin kind of ch04, now populated)*

- a question **open** *(new)*
- a claim **accepted** / standing as a premise *(new)*
- a conclusion **standing unrefuted** (carried)
- candidate: a hypothesis **favored over** a competitor, **under
  test**; a method **validated** by ≥1 execution *(new, latent)*

**Relations**

- carried: hasInput, hasOutput, precededBy, hasAgent, derivedFrom,
  supports, contradicts, refines, prescribes, hasUncertainty, hasBody,
  hasTarget, hasSelector
- **addresses** *(search → motivating question; hypothesis → its
  question)*, **surfaces** *(search → raised question)*
- **groundedIn** *(evidence → annotation)*, **promotedFrom** *(premise
  → evidence)*, **synthesizedFrom** *(hypothesis → premises)*
- **competesWith** *(hypothesis ↔ hypothesis, symmetric)*
- **tests** *(design/method → hypothesis, prospective intent)*
- **executes** *(act → method)*, **consumes** / **produces** *(typed
  readings of input/output)*
- **hasModel**, **hasNature** *(uncertainty → its facets)*
- **occursAt** / **hasTemporalRegion** *(act → time)*
- **producedBy** *(artifact → its producing act; the named inverse of
  hasOutput — v0.2's `isOutputOf`, renamed)*, optional
  **hasOriginatingQuestion**
- recorded characteristics: `precededBy` and `derivedFrom` are
  **transitive**; the provenance graph is assumed **acyclic** (a DAG)

**Temporal** *(promoted from background grounding to named terms)*

- TemporalRegion, with TemporalInstant and TemporalInterval

## A second pass: the new questions loop back through Steps 2 and 3

ch02 said the competency-question list was "a sketch, not a contract"
and predicted that later chapters "will likely surface gaps that
motivate new questions, and that's not failure — it's [Rule
2](ch02-domain-and-scope.md#on-iteration) made operational." Reading
the original fifteen closely did exactly that: it raised about forty
more. Rather than list them and defer, we do what Rule 2 asks and loop
back, running this new batch through the steps already taken — reuse
(Step 2) and term-harvesting (Step 3), the same passes the originals
went through. The hierarchy (Step 4) is still Chapter 5; these
questions feed it.

The ones that earn a place are the *inverses*, the *gaps*, the
*provenance-of-the-link*, the *contrast*, and the *integrity* questions
the original fifteen imply but never state:

- **Inverses (provenance runs both ways).** Which literature searches
  addressed a given question? What evidence was extracted from a given
  annotation or source document? What hypotheses were synthesized from
  a given premise? Which analyses consumed a given dataset? Which acts
  did a given agent perform, and over what period? What conclusions
  trace back, transitively, to a given originating question?
- **Gaps in the chain.** What evidence was assessed but rejected? What
  evidence remains unassessed? Is a given premise still accepted, or
  has its acceptance been retracted?
- **Provenance of the link.** For a given support or contradiction,
  which act and agent established it, when, and with what strength?
- **Contrast.** What question do two competing hypotheses jointly
  address? Across all the evidence, which of them carries the greater
  weight? Is one piece of evidence shared between them, supporting one
  while contradicting the other?
- **Method and uncertainty.** What hypotheses is a method *capable* of
  testing, versus the one it *was designed* to test? By what
  statistical method were a result's uncertainty and credibility
  derived? Is that uncertainty aleatory or epistemic?
- **Integrity and impact.** Is a given conclusion's lineage complete
  and acyclic — every artifact tracing to a producing act, back to a
  question? Do two conclusions share a common ancestor? If an upstream
  premise or result were retracted, which downstream conclusions are
  affected?
- **From the neighbors.** Given *any* claim — hypothesis, premise, or
  conclusion — what supports and what challenges it? How many
  independent lines of evidence back a conclusion, and how strong is
  each? Which acts and artifacts belong to the same study?

### Step 2 again — what to reuse for them

scimantic is not the first schema to model scientific claims, evidence,
and provenance, and several of the new questions ask for things the
neighbors already have. Running Chapter 3's "consider reuse" pass
again, now aimed at the new questions' terms, both validates the
existing vocabulary and turns up candidate sources — to adopt now, or
defer the way Chapter 3 deferred URREF. A research pass over the
neighbors sorted them into four buckets.

**Where scimantic aligns.** Its provenance relations map cleanly onto
[PROV-O](https://www.w3.org/TR/prov-o/): `hasInput`/`hasOutput`/
`derivedFrom`/`hasAgent`/`precededBy` are PROV's `used`/`wasGeneratedBy`/
`wasDerivedFrom`/`wasAttributedTo`/`wasInformedBy`. Its `Annotation` +
`TextSelector` are the W3C Web Annotation model it already reuses via
`oa:`, and the [Micropublications](https://link.springer.com/article/10.1186/2041-1480-5-28)
model pairs claims with exactly that anchoring. `supports` is the
universal positive term across the literature.

```admonish note title="Micropublications ≠ nanopublications"
Despite the near-identical names these are different artifacts, and
scimantic relates to each differently. **Nanopublications** (Groth et
al. 2010) are a *publishing container*: one assertion packaged with its
provenance and publication metadata as signed RDF, which scimantic
reuses via `np:`. **Micropublications** (Clark et al. 2014) are a
*claim–evidence–argument model*, the structure of a scientific argument
with reified support; scimantic cites it as the closest prior model to
its own claim spine but does not bind to it, for the IRI-stability
reasons below.
```

The same reconsidering retired v0.2's reuse *mixins*
(`Nanopublication`, `DCATDataset`, `UncertaintySubject`) in favor of
the by-URI prefix manifest, as recorded in *Reconsidered from v0.2*;
the second pass adds no mixins, only the reuse below.

**Adopt: CiTO, for the claim relations (a new prefix).** No established
model pairs `supports` with **`contradicts`**. The well-trodden
vocabulary is [CiTO](https://sparontologies.github.io/cito/current/cito.html),
the SPAR Citation Typing Ontology, whose object properties carry no
domain or range and so apply claim-to-claim as readily as
document-to-document. scimantic adopts it: `supports` maps to
`cito:supports`, `contradicts` to `cito:disputes` (or the stronger
`cito:refutes`), and `refines` to `cito:extends`/`updates`. CiTO is the
second pass's one manifest change — a `cito:` prefix, the only candidate
here that needs one, since the rest live under the `obo:` prefix Chapter
3 already declared. The manifest grows by one entry:

{{#diff scimantic-yaml-v1 scimantic-yaml-v2}}

The one caveat, recorded in the `cito` callout: CiTO's own narrative is
about citations between documents, not claims, though its authors'
examples are claim-level and its axioms impose no such limit.

**Adopt as mapping targets (no new prefix).** Two OBO-Foundry
ontologies are reachable through the existing `obo:` prefix and worth
binding to when the classes and slots land:

- [IAO](https://github.com/information-artifact-ontology/IAO), the
  Information Artifact Ontology, has neutral *hypothesis* and
  *conclusion* textual-entity terms. They become `exact_mappings` on
  scimantic's `Hypothesis` and `Conclusion`, with CCO's Information
  Content Entity staying the primary grounding: interoperability without
  a second ancestry claim.
- [RO](https://oborel.github.io/), the OBO Relations Ontology already
  named in Chapter 3's PROV alignment, supplies `has input` / `has
  output`; scimantic's input and output slots map to it for OBO-wide
  interoperability, with CCO and BFO relations primary.

**Defer, the URREF way.** The two closest conceptual fits are also the
least stable:

- [SEPIO](https://github.com/monarch-initiative/SEPIO-ontology), the
  Scientific Evidence and Provenance Information Ontology, is built for
  exactly this domain — *assertion*, *evidence line*, *evidence item* —
  but its OWL is mid-migration to a LinkML model, its last release is
  years old, and its term IRIs are not currently stable. It is the
  intended source for a `Claim` superclass and evidence lines, and like
  URREF it is committed in principle and pinned behind a thin local
  class until those IRIs settle.
- The Micropublications model (Claim, Evidence, Argument, with reified
  support) maps just as closely, but its IRI dead-ends in a personal
  repository last touched in 2016. Same posture: cite the pattern,
  defer the binding.

The Study container and a statistical-derivation method have candidate
homes in OBI and OBCS (also under `obo:`), but both are biomedical in
scope, and their genuinely neutral content — an investigation as a
planned process, a statistical analysis — is largely already reachable
through BFO, CCO Planned Act, and IAO. They stay candidate mappings to
revisit if scimantic mints those classes, with STATO weighed against
OBCS for the statistics.

**Decline.** The SPAR document-discourse ontologies (DoCO/DEO) model a
paper's *sections*, not its claims, and define no Hypothesis, Evidence,
or Premise. SWAN's IRIs are dead, its Google Code home gone, and its
ideas survive in Micropublications. EXPO is grounded in SUMO, a rival
upper ontology that would clash with the BFO/CCO base; its one portable
lesson — that some inquiry is exploratory, with no prior hypothesis — is
a question for Chapter 5 (is `Hypothesis` mandatory in the chain?). All
three are prior art, nothing to import.

### Step 3 again — the terms they add

Run the new questions through the same lens as the first pass: each
cluster is a fresh demand for terms. The yield is smaller, because most
of these questions reuse the existing vocabulary in new directions
rather than name new things. Two clusters are the exception.

**Inverses** force no new nouns. "Which searches addressed a question,"
"what evidence came from an annotation," "which analyses consumed a
dataset" each read an existing edge backward. What they force is a
Chapter 6 decision, not a Step 3 term: whether each inverse
(`addressedBy`, `extractedInto`, `consumedBy`, and the rest) is a
stored slot or derived from its forward relation by the reasoner. The
first pass already named one such inverse, `producedBy`, for the same
reason.

**Gaps in the chain** add an outcome value and a state. "What evidence
was assessed but rejected" needs the **rejected** value of the
`AssessmentOutcome` the first pass derived from CQ 4; "is a premise
still accepted, or retracted" needs a **retracted** state on a premise
or conclusion. "What remains unassessed" needs no new term, only the
absence of an assessment act. Together these thicken the *States* kind
the first pass left thin.

**Provenance of the link** forces a relation to become a node. "Who
asserted that this evidence supports that hypothesis, when, and how
strongly" cannot be answered by a bare `supports` edge, which has
nowhere to hang an asserter or a strength. The answer is a reified
**EvidentialRelation** carrying polarity, strength, an asserting act,
and an agent. This is the one place the second pass restructures a
relation the first pass treated as a plain edge.

**Contrast** mostly reuses. The competing-hypotheses questions lean on
`competesWith` and `addresses`, both derived in the first pass. The
only addition is a **weight of evidence** per hypothesis, computed from
the support and contradict edges rather than stored.

**Method and uncertainty** adds one term and sharpens one. "By what
statistical method were a result's uncertainty and credibility derived"
forces a **StatisticalMethod**, the act-or-method that produces the
uncertainty quality the first pass named but left unsourced. "What a
method is *capable* of testing versus what it *was designed* to test"
sharpens `tests` into a capability-versus-intent distinction, a
Chapter 5 refinement rather than a new term.

**Integrity and impact** name nothing. "Is a conclusion's lineage
complete and acyclic," "do two conclusions share an ancestor," "if a
premise is retracted, which conclusions break" ask the graph to be
*well-formed* and to support *impact analysis*. They are the first
questions that test the vocabulary's shape rather than its contents,
which makes them Step 7 (validation, Chapter 8) work more than Step 3.
The one finding to record is that the provenance graph must be a DAG,
which the first pass already surfaced from CQ 15.

**From the neighbors** force the genuinely new, higher-level terms.
With Step 2's reuse pass behind them, the "any claim," "lines of
evidence," and "same study" questions add a layer above the individual
artifacts: a **Claim / Assertion** superclass over Hypothesis, Premise,
and Conclusion (the thing `supports`, `contradicts`, and `refines` all
range over); an **EvidenceLine** grouping several pieces of evidence
with a strength; and a **Study / Investigation** container over one
question-to-conclusion cycle. Each also reconsiders v0.2's flatter
shape: v0.2 had Hypothesis, Premise, and Conclusion as unrelated
siblings under no `Claim` parent, and Evidence wired straight to a claim
with no line between.

In order of how much they reshape the model, the second pass's
additions are:

- **Claim / Assertion** — candidate superclass over Hypothesis,
  Premise, Conclusion
- **EvidentialRelation** — the reified support/contradict edge, with
  polarity, strength, asserter, and agent
- **EvidenceLine** — a grouping of evidence carrying a strength
- **Study / Investigation** — a container over one inquiry cycle
- **StatisticalMethod** — the deriver of uncertainty and credibility
- new **states and outcomes**: an assessment **rejected**, a claim
  **retracted**
- the **inverse relations**, read backward from existing ones

As with the first pass, this stops at naming. Whether a `Claim`
superclass, an evidence line, or a study earns a place in the
hierarchy, and whether the inverses are stored slots or derived, is
Step 4 and Step 5 work, for Chapters 5 and 6. Chapter 8 will revisit
the whole question set, original and surfaced, as the validation litmus
test.

## Reconsidered from v0.2

The harvest's third move, and the reason it comes last: a term is only
safely retired once *every* question is on the table, original and
surfaced. With both passes run, v0.2 still has terms that no question
asks for. A rebuild from the questions should reconsider these rather
than carry them by habit. None is settled-as-dropped here — Step 3 only
flags — but naming them keeps the rebuild honest: it prunes as well as
accretes, which is the point of starting from the questions instead of
from v0.2.

- **`status` / `ActStatus`.** v0.2's enum for an act's lifecycle phase.
  No question asks for it. The second pass's gaps questions ("is a
  premise still accepted, or *retracted*?") come closest, but they ask
  for a *claim's* standing, which the *States* kind (grounded in CCO
  Stasis) answers, not an *act's* lifecycle enum. A status enum and a
  Stasis state compete; choosing between them is a Chapter 5 decision,
  but the question set does not require the v0.2 enum.
- **`Ambiguity`, `Vagueness`, `Incompleteness`, `Aleatory`.** v0.2's
  four fine-grained uncertainty natures. Both CQ 12 and the second
  pass's "aleatory or epistemic?" ask only for the coarse split, so
  these fold into a single `nature` facet until a question needs the
  finer grain.
- **The reuse mixins `Nanopublication`, `DCATDataset`,
  `UncertaintySubject`, `URREFEvidence`.** v0.2 reused nanopublication,
  DCAT, and URREF by mixing in wrapper classes. Chapter 3 reuses them by
  URI through the prefix manifest instead, so the mixin classes are
  superseded rather than dropped for cause.
- **The BFO/CCO wrapper classes** (`BFOEntity`,
  `InformationContentEntity`, `Act`, and the rest). v0.2's thin classes
  carried upper-ontology IRIs; Chapter 3's grounding by `class_uri`
  makes them unnecessary. A mechanism change, recorded here for
  completeness.

Two more are not dropped but **renamed or relabeled**, and are
corrected in the lists above: `isOutputOf` is carried as `producedBy`,
and `UncertaintyDerivation` is a v0.2 class, not a new one.

## What the list leaves unsettled

The point of the list is to be comprehensive, not resolved. Most of
what two passes of close reading sharpened are genuine open choices,
left open on purpose for Chapters 5 and 6. Two are not choices at all:
the questions force them, and Chapter 5 only has to place them, so they
are set apart at the end. And the reuse *bind-later* calls from the
Step 2 passes belong on the same ledger.

- **Evidence versus Premise.** Two classes, one class with a status, or
  a subclass relation. CQ 4 (an acceptance outcome and a promotion
  link) and CQ 5 (a premise that must be a traversable node) jointly
  constrain the choice without settling it.
- **Method: template or instance.** The single decision behind CQ 8,
  9, and 10; resolve it once and the three fall into place. It also
  fixes where `tests` lives (on the design act or the method) and
  whether `tests` splits into capability (*can* test) versus intent
  (*designed to* test).
- **Uncertainty: slot or class.** CQ 12's "model, nature, parameters,
  derivation" is a structured bundle that strains a scalar slot.
- **Specialized versus generic relations.** Nearly every question
  wanted a named, typed edge (`addresses`, `surfaces`, `groundedIn`,
  `promotedFrom`, `synthesizedFrom`, `executes`, `consumes`,
  `producedBy`) that is semantically a specialization of the generic
  `hasInput`/`hasOutput`/`derivedFrom`. Which become real slots and
  which are generic-relation-plus-typed-range is a Chapter 6 question.
- **Stored versus derived relations.** A separate axis from the typing
  above: some edges may be *computed* rather than stored. `competesWith`
  can be asserted or derived from two hypotheses sharing an `addresses`
  question; the inverses (`addressedBy`, `consumedBy`, `extractedInto`,
  …) can be stored slots or reasoner-derived from their forward
  relation; and a hypothesis's weight of evidence is computed from its
  support and contradict edges. Which are materialized is a Chapter 6
  call.
- **To reify or not.** Support, derivation, and evidence-lines can stay
  as plain edges or become nodes that carry their own provenance. The
  questions that ask *who said so, when, and how strongly* push toward
  reification.
- **The higher-level layer.** Whether to add the candidates the second
  pass surfaced — a `Claim` superclass, evidence lines, a `Study`
  container, an explicit statistical-derivation method — or keep the
  flatter, artifact-by-artifact vocabulary. Each is a Chapter 5 call.
- **Is `Hypothesis` mandatory in the chain?** EXPO's portable lesson
  (Step 2's decline) was that some inquiry is exploratory, with no prior
  hypothesis. Whether the question-to-conclusion spine *requires* a
  `Hypothesis` node or lets evidence reach a conclusion without one is a
  Chapter 5 question about the core shape.
- **Naming alignment.** With CiTO adopted, `supports`/`contradicts`/
  `refines` have reuse targets (`cito:supports` / `cito:disputes` or
  `cito:refutes` / `cito:extends`). Whether scimantic *renames* its
  relations to CiTO's or keeps its own names and maps them with
  `skos:closeMatch` is a Chapter 5/6 call.
- **Status enum versus Stasis state.** v0.2 modeled an act's standing
  as a `status` enum value; the rebuild's *States* kind grounds the same
  idea in CCO Stasis. A slot-valued status or a reified state: the
  reconsidering surfaced the choice, and Chapter 5 makes it.
- **Reuse bindings still deferred.** Beyond the term and hierarchy
  choices above, the Step 2 passes left several *bind-later* calls open:
  SEPIO and Micropublications (cited as the closest models, not bound),
  OBI/OBCS with STATO weighed for the statistics, and URREF carried from
  Chapter 3. Each is revisited when the class or slot it would attach to
  actually lands.

The last two are not open questions: the competency questions **force**
them, and Chapter 5 only has to place them in the hierarchy.

- **`Act` as a real superclass.** CQ 10, 14, and 15 quantify over acts
  generically, so `Act` has to be a shared supertype, not a
  reading-group label.
- **Time as an interval.** Acts are occurrents that unfold over time, so
  CQ 14's "when" is a temporal *region*, not the instant `createdAt`
  silently assumed, which is simply false for an Experimentation that
  runs for days.

## Next

The vocabulary is on the table, enlarged over two passes and trailing
the new questions and the higher-level candidates the second pass
surfaced. Chapter 5 takes N&M Step 4,
sorting these terms into classes and arranging them into a hierarchy
beneath the BFO and CCO categories Chapter 3 committed to — resolving
the overlaps, the template-versus-instance and slot-versus-class
choices, and the naming alignments this chapter was free to leave open.
