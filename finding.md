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

## 4. Medium: VS Code install docs present agent plugins as generally available, but the feature is still preview and can be org-disabled

The repo’s VS Code setup text presents `Chat: Install Plugin From Source` as a normal install path without warning that VS Code agent plugins are still in preview and that plugin support is controlled by the `chat.plugins.enabled` organization setting. In environments where that setting is off, teammates can follow the documented steps and still be unable to install or use the plugin.

Refs:
- `README.md:17-27`
- `CLAUDE.md:5`

Evidence:
- VS Code’s agent plugin docs state “Agent plugins in VS Code (Preview)” and note that support is managed by the `chat.plugins.enabled` org setting.
- Official docs: `https://code.visualstudio.com/docs/copilot/customization/agent-plugins`

Impact: the install instructions overstate availability and can send users into a dead-end setup path if their org has not enabled agent plugins.

## 5. Medium: `.github/copilot-instructions.md` is documented as affecting inline suggestions, but VS Code says custom instructions are chat-only

The repo repeatedly tells users to copy `.github/copilot-instructions.md` to influence “inline suggestions”. Current VS Code docs say custom instructions are not taken into account for inline suggestions as you type; `.github/copilot-instructions.md` applies automatically to chat requests in the workspace.

Refs:
- `README.md:65`
- `README.md:96-107`
- `.github/copilot-instructions.md:7-9`
- `CLAUDE.md:5`

Evidence:
- VS Code custom instructions docs explicitly say custom instructions “are not taken into account for inline suggestions”.
- The same docs describe `.github/copilot-instructions.md` as an always-on file for chat requests.
- Official docs: `https://code.visualstudio.com/docs/copilot/customization/custom-instructions`

Impact: teams can invest effort curating `copilot-instructions.md` expecting better completions in the editor, but the documented benefit does not exist in current VS Code behavior.

## 6. Medium: hook documentation implies matcher-specific behavior that VS Code currently does not honor

The README describes the plugin hooks as if VS Code respects Claude-style matcher scoping such as `Bash`, `Write`, and `Edit|Write`. However, current VS Code plugin docs say it parses Claude hook configuration but presently ignores matcher values. That means the README’s per-hook trigger descriptions are not reliable for VS Code users.

Refs:
- `README.md:117-130`
- `hooks/hooks.json:15-92`

Evidence:
- VS Code’s agent plugin docs state: “Currently, VS Code ignores matcher values, so hooks run on every matching event.”
- Official docs: `https://code.visualstudio.com/docs/copilot/customization/agent-plugins`

Impact: VS Code users can get materially different hook execution than the docs promise, including extra hook invocations and misleading expectations during rollout or debugging.
