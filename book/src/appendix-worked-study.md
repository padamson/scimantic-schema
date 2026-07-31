<!-- DRAFT — not yet linked in SUMMARY.md; scaffold for the real-world-study dogfood. -->

# Appendix A — A Worked Study

<!-- ============================================================
CHARTER (set 2026-06-16). Prove scimantic workable by instantiating a
REAL published study end-to-end as LinkML instance data, validating it,
and letting the gaps it surfaces drive a polish pass in ch07. The
demand-driven dogfood made visible: this appendix is the demand, the
main body (especially ch07) is the supply, and the iteration between
them is the loop the reader gets to watch.

Each section takes one provenance stage, gives the study's real content,
embeds its LinkML instance listing (frozen), and maps it to the schema.

SECTION OUTLINE (one per provenance stage):
A.1 The question      — QuestionFormation -> Question (OpenState)
A.2 Hypothesis        — LiteratureSearch + HypothesisFormation -> Hypothesis
A.3 Design & method   — DesignOfExperiment -> ExperimentalMethod (tests)
A.4 Experiment & data — Experimentation -> Dataset
A.5 Analysis & result — Analysis -> Result (+ Uncertainty / UncertaintyModel)
A.6 Evidence          — EvidenceExtraction + EvidenceAssessment -> Evidence/Premise
A.7 Conclusion        — ResultAssessment -> Conclusion
A.8 Validation        — linkml-validate (structural) + competency questions
                        as SPARQL over the RDF projection (workability)

PREREQUISITES (the study forces these; also tracked in ch07):
[ ] Study selection — one open-access published study, a clear
    question->conclusion chain, not a meta-analysis, ideally in a
    domain the author knows well.
[ ] Identifiers — an id (identifier: true) slot so instances cross-
    reference into a DAG (ch07 deferral).
[ ] linkml-validate in CI; LinkML -> RDF projection for the CQ litmus
    (ch07 deferrals).

When the study is picked: split A.1-A.8 into linked sections, freeze the
instance listings, and link this appendix in SUMMARY.md.
============================================================
-->
