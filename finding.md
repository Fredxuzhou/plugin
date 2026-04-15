# Findings
## 1. High: The PreToolUse Bash hooks are wired to the wrong JSON field, so the safety checks never see the command

All three `PreToolUse` Bash hooks read `data.get('command', '')` / `$data.command`, but the hook payload shape used elsewhere in the repo and in Claude Code's hook docs is nested under `tool_input.command`. As written, `pre-tool-use-bash`, `pre-commit-quality`, and `git-push-reminder` all treat real Bash invocations as an empty string, so the force-push guard, commit blocker, and push reminder can silently fail on both bash and PowerShell paths.

Refs:
- `hooks/scripts/pre-tool-use-bash:10-30`
- `hooks/scripts/pre-commit-quality:11-23`
- `hooks/scripts/git-push-reminder:8-19`
- `hooks/scripts/pre-tool-use-bash.ps1:8-29`
- `hooks/scripts/pre-commit-quality.ps1:8-20`
- `hooks/scripts/git-push-reminder.ps1:6-17`

Evidence:
- A local reproduction with `{"command":"git push --force"}` makes `pre-tool-use-bash` emit a block decision.
- The same reproduction with `{"tool_input":{"command":"git push --force"}}` produces no output, which means the guard never fires for the nested payload.

Impact: the repo advertises blocking dangerous shell commands and intercepting bad commits, but those protections are currently easy to bypass because the hooks are reading the wrong field.

## 2. Medium: `run_eval.py` records false negatives whenever Claude uses any other tool before `Read` or `Skill`

`run_single_query()` returns `False` immediately on the first non-`Skill`/`Read` `tool_use` event. That means a trace like `LS -> Read skill file` is scored as a miss even though the skill was read successfully a moment later. This makes trigger-rate measurements depend on tool ordering rather than on whether the skill actually triggered.

Refs:
- `skills/skill-creator/scripts/run_eval.py:175-196`
- `skills/skill-creator/scripts/run_eval.py:198-213`

Evidence:
- With a stubbed `claude` executable that emits only `Read`, `run_single_query()` returns `True`.
- With a stubbed `claude` executable that emits `LS` first and then the same `Read` event, `run_single_query()` returns `False`.

Impact: the bundled evaluator can under-report trigger rates and steer `run_loop.py` toward "fixing" descriptions that are already correct.

## 3. Medium: `aggregate_benchmark.py` fabricates comparison metadata for benchmark shapes it did not actually run

The aggregator always writes `"runs_per_configuration": 3` even when the input contains a different number of runs, and it still computes a `"delta"` section when there is only one configuration by subtracting against an empty baseline. In a one-run, one-configuration benchmark, the generated output claims `runs_per_configuration` is `3` and reports a non-empty delta such as `+1.00`.

Refs:
- `skills/skill-creator/scripts/aggregate_benchmark.py:214-230`
- `skills/skill-creator/scripts/aggregate_benchmark.py:271-280`
- `skills/skill-creator/scripts/aggregate_benchmark.py:301-306`

Evidence:
- Running the script against a synthetic benchmark containing exactly one `with_skill/run-1/grading.json` produced `benchmark.json` with `"runs_per_configuration": 3` and `"delta": {"pass_rate": "+1.00", ...}`.

Impact: the generated `benchmark.json` / `benchmark.md` can mislead readers about both the amount of data collected and whether a real comparison between configurations exists.
