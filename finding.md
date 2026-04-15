# Findings

## 1. Medium: `aggregate_benchmark.py` fabricates a second comparison column when only one configuration exists

`generate_markdown()` always renders a four-column comparison table and falls back to the synthetic key `config_b` when there is only one real configuration. The result is a benchmark report that shows a fake "Config B" column filled with zero values even though no second configuration was executed.

Refs:
- `skills/skill-creator/scripts/aggregate_benchmark.py:290-327`

Evidence:
- Running the script against a benchmark containing only `with_skill/run-1/grading.json` produces `benchmark.md` with:
  - `| Metric | With Skill | Config B | Delta |`
  - zeroed metrics for the nonexistent second configuration

Impact: the generated markdown report claims a comparison exists when it does not, which can mislead readers reviewing single-configuration benchmark output.

## 2. Medium: benchmark metadata overstates run counts for uneven configurations

`generate_benchmark()` sets `metadata.runs_per_configuration` to the maximum number of runs seen in any configuration. When configurations have different run counts, the generated markdown still says "`N` runs each per configuration", even though some configurations have fewer runs than others.

Refs:
- `skills/skill-creator/scripts/aggregate_benchmark.py:267-276`
- `skills/skill-creator/scripts/aggregate_benchmark.py:297-303`

Evidence:
- With synthetic input containing three `with_skill` runs and one `without_skill` run, the script emits `"runs_per_configuration": 3`.
- The generated markdown says `Evals: 1 (3 runs each per configuration)` even though `without_skill` only has one run.

Impact: readers can overestimate the sample size behind one side of the benchmark and put too much confidence in the reported deltas.
