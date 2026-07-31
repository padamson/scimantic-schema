# Domain and Scope

This chapter applies **Step 1** of *Ontology Development 101* (Noy &
McGuinness, 2001) to scimantic.

```admonish quote title="Noy & McGuinness 2001 — §Step 1"
We suggest starting the development of an ontology by defining its
domain and scope. That is, answer several basic questions:

- What is the domain that the ontology will cover?
- For what we are going to use the ontology?
- For what types of questions the information in the ontology should
  provide answers?
- Who will use and maintain the ontology?

The answers to these questions may change during the ontology-design
process, but at any given time they help limit the scope of the model.
```

The next four sections address each question in turn. A fifth section
covers what scimantic deliberately does *not* model, and a closing note
on iteration.

## What domain does scimantic cover?

Scimantic models the **scientific method as a process** — the sequence
of acts and artifacts by which researchers turn questions into
published, evidence-supported analyses and conclusions.

Three categories of concepts:

- **Process artifacts** — Question, Hypothesis, Evidence, Result,
  Conclusion, Premise, ExperimentalMethod, Dataset, Annotation, ...
- **Acts that produce or transform them** — QuestionFormation,
  LiteratureSearch, EvidenceExtraction, EvidenceAssessment,
  HypothesisFormation, DesignOfExperiment, Experimentation, Analysis,
  ResultAssessment
- **Relations** between them — `hasInput`, `hasOutput`, `precededBy`,
  `hasAgent`, `supports`, `contradicts`, `derivedFrom`, ...

scimantic is **domain-neutral**. It is equally applicable to a physics
simulation, a biology experiment, a literature-only meta-analysis, or a
software-measurement (*e.g.,* metrology) study. Whatever discipline you bring, the same
process structure applies. Questions get formed, evidence gets
gathered, hypotheses get tested, conclusions get drawn.

Domain-specific vocabulary and processes live in lower-level ontologies (*e.g.,* a physics ontology, a
biology ontology, etc.) and attach via class-and-slot URIs when
consumers need it. This will enable fine-grained knowledge base development within a particular domain as well as effective cross-domain research and discovery.

## What are we going to use the ontology for?

Two consumers drive the design:

- **A structured-provenance authoring tool** — for authoring research
  notes as provenance graphs. Needs Question / Hypothesis / Evidence /
  Premise / Conclusion as first-class authoring concepts.
- **[t2t](https://github.com/padamson/t2t)** — book-and-app project
  building a "trunk-to-theory" knowledge system. Uses the full graph as
  the backing data model.

These are the live consumers. The schema's class and slot choices
must support them. Other potential consumers (literature managers,
notebook tools, lab-notebook systems) are welcome but don't drive
design at this stage.

## What questions should the ontology answer?

```admonish quote title="Noy & McGuinness 2001 — §Step 1, Competency questions"
One of the ways to determine the scope of the ontology is to sketch a
list of questions that a knowledge base based on the ontology should
be able to answer, **competency questions** ([Gruninger and Fox 1995](http://www.eil.utoronto.ca/wp-content/uploads/enterprise-modelling/papers/gruninger-ijcai95.pdf)).
These questions will serve as the litmus test later: Does the
ontology contain enough information to answer these types of
questions? Do the answers require a particular level of detail or
representation of a particular area? These competency questions are
just a sketch and do not need to be exhaustive.
```

Sketch list — questions an instance graph built on scimantic should
answer:

1. What questions did a given literature search address?
2. What new questions did a given literature search surface?
3. What annotations on source documents grounded a given piece of
   Evidence?
4. What evidence has been assessed for credibility and accepted as
   Premise?
5. From which premises was a given hypothesis synthesized?
6. Which evidence supports or contradicts a given hypothesis?
7. For two competing hypotheses, what evidence has been gathered on
   each side?
8. What experimental methods were designed to test a given hypothesis,
   and what evidence informed the design?
9. What experiments executed a given experimental method?
10. What act produced a given dataset, and what method did it apply?
11. What dataset(s) did a given analysis consume to produce a result?
12. What is the uncertainty model for a given Result, and how was it
    derived?
13. What conclusions derive from a given experimental result?
14. Who (which Agent) performed a given act, and when?
15. What are the acts in the lineage of a given conclusion, traced
    back to the originating question?

Judging from this list (mirroring N&M's analytical pattern from their
wine example), the ontology will include: process artifacts (Question,
Hypothesis, Evidence, Premise, Result, Conclusion, ExperimentalMethod,
Dataset, Annotation); acts (QuestionFormation, LiteratureSearch,
EvidenceExtraction, EvidenceAssessment, HypothesisFormation,
DesignOfExperiment, Experimentation, Analysis, ResultAssessment);
provenance relations (`hasInput`, `hasOutput`, `derivedFrom`,
`precededBy`, `hasAgent`); and uncertainty representation
(URREF-derived qualities on relevant artifacts). Provenance —
tracing each artifact back to the act that produced it and the
agent who performed that act — is core to the scope; the specific
implementation mechanics (which relations carry explicit inverse
slots vs. derive from upper-ontology declarations, cardinalities,
`slot_usage` refinements) are deferred to Chapters 6 and 7.

This list is a **sketch**, not a contract. It informs design;
Chapter 7 will revisit each question and verify the ontology can
actually answer it.

## Who will use and maintain the ontology?

- **Authors**: contributors welcome once the rebuild stabilizes;
  the book is meant to make the design rationale legible enough
  that newcomers can extend the schema without archeology.
- **Methodology stewardship**: mappings to upper- and mid-level
  ontologies (BFO 2020, Common Core Ontologies) require ontology
  expertise; Chapter 2 starts that work and consults external
  references for each major term decision.
- **Downstream maintainers**: consumers such as t2t re-validate
  against their build pipelines on each scimantic-schema release tag.

## What scimantic does *not* model

The schema deliberately leaves several adjacent concerns to other
vocabularies:

- **Domain-specific terms.** No built-in physics / biology / chemistry
  / etc. concepts. The schema is domain-neutral; consumers bring their
  own domain ontologies or skip them entirely.
- **Truth-value or evidence-strength reasoning.** Evidence has
  `supports` / `contradicts` slots that *record* claimed relationships
  between artifacts; the schema doesn't adjudicate them. Reasoning
  layers (downstream SPARQL, LLM reasoners) do that
  work.
- **Full bibliographic structure.** `citation` is a free-form reference
  slot. DC, CSL, BibTeX, Wikidata, etc. cover typed bibliographic
  records better.
- **Institutional / funding context.** Orthogonal to the process.
  PROV-O Agent (transitively, via CCO/BFO mappings in Ch 3) and
  dcterms cover what's needed; the schema doesn't model institutions
  or grants directly.
- **Time-series / measurement data internals.** Dataset is a
  process-artifact handle. DCAT or discipline-specific data schemas
  cover the internal structure of the data itself.

The pattern is consistent: **scimantic models the process around
research, not the contents of the research domain**. Consumers compose
scimantic with whatever domain vocabularies and reasoning layers their
use case requires.

## On iteration

N&M-101 §3 opens with three fundamental rules:

```admonish quote title="Noy & McGuinness 2001 — §3, three fundamental rules"
1. There is no one correct way to model a domain— there are always
   viable alternatives. The best solution almost always depends on
   the application that you have in mind and the extensions that you
   anticipate.
2. Ontology development is necessarily an iterative process.
3. Concepts in the ontology should be close to objects (physical or
   logical) and relationships in your domain of interest. These are
   most likely to be nouns (objects) or verbs (relationships) in
   sentences that describe your domain.
```

The answers above will evolve. Today's competency questions reflect
what v0.1.0 and v0.2.0 surfaced as useful; Chapters 3 onward will
likely surface gaps that motivate new questions, and that's not
failure — it's Rule 2 made operational.

The schema as it stands at the end of Chapter 1 is the **minimal stub**
committed alongside this chapter: just metadata, no classes yet.
Chapter 2 takes the first concrete step of populating it — reviewing
existing ontologies to decide what to import vs. invent.
