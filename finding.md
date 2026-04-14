# Findings

## 1. High: Parallel trigger evals can invalidate each other

`run_single_query()` creates a temporary skill file under the shared project root at `.claude/commands/<unique>.md`, and `run_eval()` launches many of those workers concurrently by default. Because every `claude -p` subprocess sees the same shared commands directory, one run can trigger a sibling worker's temporary skill instead of its own. The detection logic only counts a hit when the current worker's `clean_name` appears in the tool input, so concurrent runs can be recorded as failures even when the description actually triggered.

Refs:
- `skills/skill-creator/scripts/run_eval.py:51-68`
- `skills/skill-creator/scripts/run_eval.py:147-168`
- `skills/skill-creator/scripts/run_eval.py:198-210`

Impact: trigger-rate measurements become nondeterministic and biased downward, especially with the default parallel settings.

## 2. High: The skill-creator eval loop is not actually Windows-compatible

The README advertises full Windows support, but `run_eval.py` reads the Claude subprocess stream with `select.select()` on `process.stdout`. That API does not work on regular subprocess pipes on Windows, so the trigger evaluator breaks there. Since `run_loop.py` depends on `run_eval()`, the optimization workflow behind the bundled `skill-creator` skill is not portable to the Windows platform the repo claims to support.

Refs:
- `README.md:57-59`
- `skills/skill-creator/scripts/run_eval.py:11`
- `skills/skill-creator/scripts/run_eval.py:85-113`

Impact: the main evaluation/optimization tooling fails on Windows despite the documented platform guarantee.

## 3. Medium: Small eval sets can produce an empty training split and a false success result

`split_eval_set()` forces at least one positive and one negative example into the holdout set whenever `holdout > 0`. If the user only has one example in a class, that class is removed entirely from training. With one positive and one negative example total, `train_set` becomes empty, `train_total` becomes `0`, and the loop exits via `train_summary["failed"] == 0` as though everything passed.

Refs:
- `skills/skill-creator/scripts/run_loop.py:26-46`
- `skills/skill-creator/scripts/run_loop.py:110-118`
- `skills/skill-creator/scripts/run_loop.py:180-184`

Impact: the optimizer can report `all_passed` without evaluating any training examples, which makes the selected description unreliable on small datasets.

## 4. Medium: Benchmark "tokens" can silently become character counts

When `timing.json` is missing, the benchmark aggregator falls back to `execution_metrics.output_chars` and stores that value under `tokens`. Character count is not a token count, so the generated benchmark can report materially wrong token means and deltas while still labeling them as tokens.

Refs:
- `skills/skill-creator/scripts/aggregate_benchmark.py:136-153`
- `skills/skill-creator/scripts/aggregate_benchmark.py:196-221`

Impact: benchmark summaries can mislead users about model cost/performance tradeoffs and invalidate token comparisons between configurations.

## 5. Medium: `package_skill.py` advertises a broken invocation path

The packager's own usage text tells users to run `python utils/package_skill.py ...`, but the file lives in `scripts/`, not `utils/`. Separately, the script imports `from scripts.quick_validate import validate_skill`, so direct execution from the repo root (`python3 skills/skill-creator/scripts/package_skill.py`) fails with `ModuleNotFoundError: No module named 'scripts'`. The bundled skill instructions use `python -m scripts.package_skill`, but the script's embedded CLI help points users at a path that cannot work.

Refs:
- `skills/skill-creator/scripts/package_skill.py:5-17`
- `skills/skill-creator/scripts/package_skill.py:111-117`

Impact: the self-documented packaging entrypoint is broken, which is likely to block users who follow the script's own help output instead of the skill docs.
