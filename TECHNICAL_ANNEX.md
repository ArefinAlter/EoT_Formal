# Technical Annex

*The Formal–Informal Paradox of Indigenous Entrepreneurship in Bangladesh*



This annex collects the formal material supporting the main text: the mathematical formulation of the composite index, the consistency and coverage measures used in the fuzzy-set analysis, supplementary methodological notes, and Appendices A–D. Equation and appendix labels follow the main text.


## Mathematical Formulation of the Composite Index


To construct a measure of Indigenous business performance, we aggregate the 66 variables into five factors, each a superset of related dimensions. The index follows established procedures for composite scoring: normalisation, weighting and aggregation. First, the raw variables $X_i$, measured on different scales, are normalised to a common 0–1 scale:

$$
X_i^{\,\mathrm{norm}} = \dfrac{X_i - X_{\min}}{X_{\max} - X_{\min}} \tag{2}
$$

where $X_{\min}$ and $X_{\max}$ are the minimum and maximum observed values of $X_i$. This ensures that all variables contribute on the same scale to the aggregation.

The normalised variables are aggregated into factors. Let $F_j$ denote the $j$-th factor, computed as a weighted sum of the normalised variables in that category:

$$
F_j = \sum_{i=1}^{n_j} w_{ij}\, X_i^{\,\mathrm{norm}} \tag{3}
$$

where $n_j$ is the number of variables in factor $j$, and $w_{ij}$ is the weight on the $i$-th variable. Weights are normalised so that

$$
\sum_{i=1}^{n_j} w_{ij} = 1 \tag{4}
$$

The composite index $CI$ aggregates the factors into a single score:

$$
CI = \sum_{j=1}^{m} \alpha_j F_j \tag{5}
$$

with $m = 5$, corresponding to Business Practices ($F_1$), Formal Financial Access ($F_2$), Local Entrepreneurial Environment / Market Availability ($F_3$), Entrepreneurial Psychology ($F_4$) and Ease of Doing Business ($F_5$). The factor weights $\alpha_j$ satisfy

$$
\sum_{j=1}^{m} \alpha_j = 1 \tag{6}
$$

The weights $w_{ij}$ and $\alpha_j$ follow an equal-weight specification: within each factor every variable receives equal weight ($w_{ij} = 1/n_j$), so a factor score is the mean of its normalised items. The factors then enter the fsQCA as separately calibrated conditions rather than through a single composite, so no cross-factor weighting is imposed on the analysis; the composite index above is reported for descriptive completeness. The set-membership scores used in the analysis are available in the project repository.


## Consistency and Coverage Measures


Consistency measures the degree to which a statement about a set relation holds in the data. For claims of sufficiency, a condition $X$ is a subset of the outcome $Y$; consistency is

$$
\mathrm{Cons}_{\mathrm{suf}}(X_i \leq Y_i) = \dfrac{\sum_{i=1}^{N} \min(X_i, Y_i)}{\sum_{i=1}^{N} X_i} \tag{9}
$$

Following Ragin (2006), when all $X_i$ values are less than or equal to their corresponding $Y_i$ values the consistency score is 1.00; near-misses lower it slightly, and many large inconsistencies push it below 0.5. For claims of necessity (where $X$ is a superset of $Y$), consistency is

$$
\mathrm{Cons}_{\mathrm{nec}}(X_i \geq Y_i) = \dfrac{\sum_{i=1}^{N} \min(X_i, Y_i)}{\sum_{i=1}^{N} Y_i} \tag{10}
$$

To guard against simultaneous subset relations, we also report Proportional Reduction in Inconsistency (PRI):

$$
\mathrm{PRI} = \dfrac{\sum_i \min(X_i, Y_i) - \sum_i \min(X_i, Y_i, 1-Y_i)}{\sum_i X_i - \sum_i \min(X_i, Y_i, 1-Y_i)} \tag{11}
$$

Coverage indicates how much of the outcome a solution accounts for. Raw coverage is

$$
\mathrm{Cov}_{\mathrm{raw}} = \dfrac{\sum_{i=1}^{N} \min(X_i, Y_i)}{\sum_{i=1}^{N} Y_i} \tag{12}
$$

and unique coverage isolates the share of the outcome explained only by a given path (where $X_i^{(k)}$ collects the other paths):

$$
\mathrm{Cov}_{\mathrm{unique}} = \dfrac{\sum_i \min(X_i, Y_i) - \sum_i \min\!\left(X_i^{(k)}, Y_i\right)}{\sum_i Y_i} \tag{13}
$$

We distinguish solution coverage, raw coverage and unique coverage (Ragin 2006; Schneider and Wagemann 2010). By construction, unique coverage cannot exceed raw coverage for the same path.


## Supplementary Methodological Notes


### Composite Scoring


When several latent variables are present, composite scoring reduces them to a representative measure rather than treating each separately, where the variables are conceptually and statistically interconnected (Song et al. 2013). Several aggregation methods exist, including the arithmetic mean, factor analysis and adjusted means (De Muro et al. 2010). Constructing a composite index involves defining the phenomenon, selecting indicators, normalising them and aggregating the normalised indicators (Mazziotta and Pareto 2013). Principal component analysis (PCA) extracts information from a large dataset using representative components (Bro and Smilde 2014) and is used to analyse datasets with many intercorrelated variables (Abdi and Williams 2010). Composite scoring is widely used by institutions working on socioeconomic measurement (Greco et al. 2018), including measures of development and poverty (De Muro et al. 2010; Mazziotta and Pareto 2013).

Two further measures referenced in the main text support the data construction (their full statements appear in the body as equations 1 and 7; they are reproduced here for completeness). Inter-rater agreement in the qualitative coding of case-study items was assessed with Fleiss' $\kappa$ (eq. 1):

$$
\kappa = \dfrac{\bar{P} - \bar{P}_e}{1 - \bar{P}_e}
$$

where $\bar{P}$ is the mean observed agreement across items and $\bar{P}_e$ the mean agreement expected by chance. The reconstruction of the aggregate Future of Business Survey records used a censored negative-binomial model, fitted by maximising the grouped log-likelihood (eq. 7)

$$
\ell(\mu, \phi) = \sum_{k} c_k \ln\!\left[ \sum_{x=a_k}^{b_k} \frac{\Gamma(x+\phi)}{x!\,\Gamma(\phi)} \left(\frac{\phi}{\phi+\mu}\right)^{\!\phi} \left(\frac{\mu}{\phi+\mu}\right)^{\!x} \right]
$$

where each observed count band $[a_k, b_k]$ contributes $c_k$ cases, and $\mu$ and $\phi$ are the mean and dispersion parameters. (These reconstructed records inform the pooled robustness check in Appendix C only.)

### Consistency of Solution Paths


Consistency measures the degree to which a statement about subset relations is supported by the data. For sufficiency, complete consistency is achieved when all cases have membership in the outcome at least as large as their membership in the condition; coverage then indicates how much of the outcome the consistent condition accounts for.

### Logical Minimisation


QCA rests on Boolean minimisation, which seeks the simplest expression associated with an outcome. Here an expression is a disjunction of conjunctions of conditions; a conjunction of conditions is a configuration, and minimisation removes conditions that are redundant for the outcome.

**Complex (conservative) solutions.** Social-science diversity is limited: even with large datasets, many rows of the truth table have few or no observations (Ragin 2009). These rows are remainders. The complex solution examines only rows with empirical observations and makes no assumptions about remainders.

**Parsimonious solutions.** The parsimonious solution is simpler than but equivalent to the complex solution; it incorporates remainders into the minimisation and yields the fewest conditions needed for an outcome. Because all counterfactuals are admitted, some may be untenable.

**Intermediate solutions.** Once untenable assumptions are excluded, an intermediate solution incorporating theory-driven counterfactuals can be derived. The intermediate solution is a subset of the parsimonious solution and a superset of the complex solution, and is generally preferred for interpretation.


## Appendix A. Calibration anchors


Calibration used the direct method (Ragin 2008). Each condition was constructed as an equal-weighted factor score on the 0–1 interval after normalising the underlying 1–5 coded items with $(x-1)/4$, and the three anchors were fixed before minimisation. Anchors were set substantively rather than from sample percentiles; for reference, the membership-to-raw mapping is $\text{raw} = 4m + 1$, so, for example, a 0.80 membership anchor corresponds to an average item score of 4.20 on the 1–5 scale. FIN and EPSY use stricter full-membership thresholds because formal financial access and entrepreneurial orientation require stronger, more consistent evidence across their component items.

| Condition / outcome | Full (0.95) | Crossover (0.50) | Non-mem. (0.05) | Source / justification |
| :--- | :---: | :---: | :---: | :---: |
| BEASE | 0.80 | 0.50 | 0.20 | Ease of doing business. Full membership (0.80 ≈ 4.20/5) indicates clearly favourable access to registration, licensing, public/digital services and administrative procedures; crossover (0.50 ≈ 3.00) a neutral/moderate score; non-membership (0.20 ≈ 1.80) clear difficulty. |
| FIN | 0.85 | 0.55 | 0.25 | Formal financial access (stricter threshold). Full membership (0.85 ≈ 4.40) requires clear evidence of banking, mobile financial services, credit/loan access, documentation, savings/collateral or investor/grant contact; crossover (0.55 ≈ 3.20) partial but not decisive access; non-membership (0.25 ≈ 2.00) little or no reliable formal access. |
| BPRAC | 0.82 | 0.50 | 0.18 | Business practice (recordkeeping, pricing, inventory, marketing, supplier relations, quality control). Full membership (0.82 ≈ 4.28) consistently good practice; crossover (0.50 ≈ 3.00) mixed/moderate; non-membership (0.18 ≈ 1.72) weak or largely absent structured practice. |
| EPSY | 0.88 | 0.60 | 0.32 | Entrepreneurial psychology (high threshold). Full membership (0.88 ≈ 4.52) strong entrepreneurial orientation across items; crossover (0.60 ≈ 3.40) moderate but not decisive aptitude; non-membership (0.32 ≈ 2.28) weak orientation. |
| ENVO | 0.78 | 0.48 | 0.18 | Local entrepreneurial environment (set slightly lower, as moderately favourable local access is substantively meaningful in difficult CHT markets). Full membership (0.78 ≈ 4.12) clearly favourable market, infrastructure, transport, network and service conditions; crossover (0.48 ≈ 2.92) ambiguous; non-membership (0.18 ≈ 1.72) poor conditions. |
| GROWTH (outcome) | 20% growth | 10% growth | 0% growth | Annualised self-reported sales/revenue growth rate: 20% = clear high-growth membership, 10% = crossover between ordinary and high growth, 0% or lower = non-growth/contraction. Monthly revenue and page analytics enter the composite outcome as scale and market-traction checks. |


## Appendix B. Truth table


With five conditions there are $2^5 = 32$ logically possible configurations; the 12 configurations observed in the 67 cases are shown below (the remaining 20 are logical remainders with no cases). Outcome coded with a frequency cutoff of 1 and a raw-consistency cutoff of 0.80 (PRI cutoff 0.65). 1 = condition present, 0 = absent.

| BEASE | FIN | BPRAC | EPSY | ENVO | OUT | n | Consist. | PRI |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 0 | 0 | 0 | 1 | 0 | 0 | 9 | 0.26 | 0.07 |
| 0 | 0 | 1 | 1 | 0 | 0 | 9 | 0.19 | 0.05 |
| 0 | 0 | 1 | 1 | 1 | 0 | 9 | 0.20 | 0.05 |
| 0 | 1 | 0 | 0 | 1 | 0 | 10 | 0.39 | 0.12 |
| 0 | 1 | 1 | 1 | 0 | 0 | 1 | 0.61 | 0.25 |
| 1 | 0 | 1 | 0 | 0 | 0 | 7 | 0.48 | 0.16 |
| 1 | 1 | 0 | 0 | 0 | 0 | 4 | 0.74 | 0.54 |
| 1 | 1 | 0 | 0 | 1 | 1 | 1 | 0.88 | 0.72 |
| 1 | 1 | 0 | 1 | 0 | 1 | 2 | 0.90 | 0.80 |
| 1 | 1 | 1 | 0 | 0 | 1 | 4 | 0.85 | 0.76 |
| 1 | 1 | 1 | 0 | 1 | 1 | 7 | 0.92 | 0.87 |
| 1 | 1 | 1 | 1 | 1 | 1 | 4 | 0.84 | 0.74 |

*Note.* All five outcome-positive configurations (OUT = 1) contain BEASE and FIN. The configuration 1 1 0 0 0 (BEASE and FIN present, no further condition; 4 cases) has consistency 0.74, below the 0.80 cutoff, and is coded 0.


## Appendix C. Pooled robustness analysis (224 records)


As a robustness check, the analysis was repeated on the pooled set of the 67 interview cases and the 157 reconstructed Future of Business Survey records. The reconstructed records are simulated, not observed, so the pooled results are reported only as a robustness check and not as the primary analysis. The pooled results corroborate the 67-case findings: BEASE and FIN remain necessary and their conjunction is the common core of the sufficient paths.

**Table C1. Necessity (pooled, 224 records).**

| Condition | Consistency (inclN) | Relevance (RoN) | Coverage (covN) |
| :--- | :---: | :---: | :---: |
| BEASE | 0.92 | 0.75 | 0.74 |
| FIN | 0.93 | 0.69 | 0.71 |
| BPRAC | 0.74 | 0.55 | 0.53 |
| EPSY | 0.44 | 0.64 | 0.41 |
| ENVO | 0.56 | 0.66 | 0.50 |

**Table C2. Intermediate solution (pooled, 224 records).**

| Term | Consistency | PRI | Raw coverage | Unique coverage |
| :--- | :---: | :---: | :---: | :---: |
| BEASE | 0.904 | 0.834 | 0.756 | 0.107 |
| FIN | 0.937 | 0.885 | 0.654 | 0.029 |
| EPSY | 0.925 | 0.815 | 0.333 | 0.021 |

*Note.* Cutoffs as in the main analysis. The pooled intermediate solution retains BEASE \* FIN as the common core; ENVO does not form a separate path in the pooled set.


## Appendix D. Variable-to-factor accounting


The composite index aggregates 66 variables into five factors.

| Factor | # variables | Source instrument(s) |
| :--- | :---: | :--- |
| Business Practice (BPRAC) | 6 | Composite index |
| Formal Financial Access (FIN) | 14 | Composite index |
| Local Entrepreneurial Environment (ENVO) | 9 | Composite index / WB BEE |
| Entrepreneurial Psychology (EPSY) | 22 | Entrepreneurial Aptitude Test (Cubico et al. 2010) |
| Ease of Doing Business (BEASE) | 15 | WB Business Enabling Environment |
| **Total** | **66** |  |


## Reference and license

This annex supplements the manuscript *The Formal–Informal Paradox of Indigenous Entrepreneurship in Bangladesh*. Set-membership scores, the calibrated 67-case and pooled 224-record datasets, and the R pipeline that produces the truth table and solutions are in the companion repository: <https://github.com/ArefinAlter/EoT_Formal>.

Suggested citation:

> ArefinAlter (2026). *The Formal–Informal Paradox of Indigenous Entrepreneurship in Bangladesh* — Technical Annex. EoT_Formal repository. <https://github.com/ArefinAlter/EoT_Formal>

This annex is released under the [Creative Commons Attribution 4.0 International (CC BY 4.0)](LICENSE-DOCS) license, the same terms that cover the README files, figures, tables, and publication-cleared data in the repository. The accompanying R source code is released separately under the [MIT License](LICENSE).
