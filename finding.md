# Findings

## 1. Medium: `aggregate_benchmark.py` drops real token counts when `grading.json` already contains duration data

`load_run_results()` only reads sibling `timing.json` when `grading.json` reports `timing.total_duration_seconds == 0`. If the grader writes duration into `grading.json` but leaves tokens only in `timing.json`, the script skips `timing.json` entirely and falls back to `execution_metrics.output_chars` as a fake token count.

Refs:
- `skills/skill-creator/scripts/aggregate_benchmark.py:136-161`

Evidence:
- Repro with synthetic input:
  - `grading.json` contained `timing.total_duration_seconds: 12.5`
  - `timing.json` contained `total_tokens: 999`
  - Generated `benchmark.json` reported `run_summary.with_skill.tokens.mean = 321` and `runs[0].result.tokens = 321`, taken from `output_chars` instead of `timing.json`

Impact: benchmark token totals can be materially wrong even when authoritative token data exists on disk, which distorts cost comparisons in the review output.

## 2. Medium: benchmark markdown silently ignores any configuration after the first two

The loader and aggregator dynamically accept arbitrary configuration directories, but both `aggregate_results()` and `generate_markdown()` reduce the report to the first two config names and a single delta. Any third or later configuration is omitted from the markdown summary without warning.

Refs:
- `skills/skill-creator/scripts/aggregate_benchmark.py:214-226`
- `skills/skill-creator/scripts/aggregate_benchmark.py:297-345`

Evidence:
- Repro with synthetic input containing `control`, `with_skill`, and `without_skill` configurations generated:
  - `| Metric | Control | With Skill | Delta |`
- The `Without Skill` configuration was present in the input data but absent from `benchmark.md`

Impact: multi-configuration benchmark runs produce incomplete summaries, so reviewers can miss one side of the experiment entirely.

## 3. Medium: `pre-commit-quality` only validates commit messages for inline `-m` usage

Both the bash and PowerShell hook implementations extract the commit message exclusively from `git commit -m "..."`. Commits created with `-F`, `--file`, `--template`, or the default editor path skip the Conventional Commits validation completely, even though the hook documentation says it blocks bad commit message formats.

Refs:
- `hooks/scripts/pre-commit-quality:39-53`
- `hooks/scripts/pre-commit-quality.ps1:37-45`

Evidence:
- In a temporary git repository, piping `{"tool_input":{"command":"git commit -F msg.txt"}}` into the bash hook produced no block response, even when `msg.txt` contained an invalid commit subject.

Impact: teams relying on this hook can still create non-conforming commit messages through common git workflows, so the documented enforcement is weaker than advertised.
