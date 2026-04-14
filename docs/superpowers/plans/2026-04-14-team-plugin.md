# Team Plugin Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a self-contained Claude Code + GitHub Copilot CLI plugin hosted on GitHub that bundles official skills/agents, four example hook scaffolds, and a team context template — installable via a single GitHub URL.

**Architecture:** A standard Claude Code plugin layout (`skills/`, `agents/`, `hooks/`, `.mcp.json`, `CLAUDE.md`) with all official content copied in verbatim with provenance headers. No runtime dependencies; everything ships in the repo.

**Tech Stack:** Markdown, JSON, Bash (hook scripts only)

---

## File Map

| File | Purpose |
|------|---------|
| `.claude-plugin/plugin.json` | Plugin manifest |
| `skills/skill-creator/SKILL.md` | Copied from `skill-creator@claude-plugins-official` |
| `agents/code-reviewer.md` | Copied from `superpowers@claude-plugins-official` v5.0.7 |
| `hooks/hooks.json` | Wires all 4 hook events to scripts or prompts |
| `hooks/scripts/session-start.sh` | SessionStart: prints team context banner |
| `hooks/scripts/pre-tool-use-bash.sh` | PreToolUse: guards dangerous Bash commands |
| `hooks/scripts/post-tool-use-write.sh` | PostToolUse: example auto-format placeholder |
| `.mcp.json` | Empty placeholder for future internal MCP |
| `CLAUDE.md` | Team context template with TODO sections |
| `README.md` | Install instructions + component overview |

---

## Task 1: Initialize repo and directory structure

**Files:**
- Create: `README.md` (empty placeholder)
- Create: `.claude-plugin/`
- Create: `skills/skill-creator/`
- Create: `agents/`
- Create: `hooks/scripts/`

- [ ] **Step 1: Initialize git repo**

```bash
cd /path/to/team-plugin
git init
git checkout -b main
```

Expected: `Initialized empty Git repository`

- [ ] **Step 2: Create directory structure**

```bash
mkdir -p .claude-plugin skills/skill-creator agents hooks/scripts
```

Expected: no output, directories created

- [ ] **Step 3: Create empty README placeholder**

Create `README.md` with content:
```markdown
# team-plugin
```

- [ ] **Step 4: Verify structure**

```bash
find . -type d | sort
```

Expected output includes:
```
./.claude-plugin
./agents
./hooks
./hooks/scripts
./skills
./skills/skill-creator
```

- [ ] **Step 5: Initial commit**

```bash
git add .claude-plugin skills agents hooks README.md
git commit -m "chore: initialize plugin repo structure"
```

---

## Task 2: Plugin manifest

**Files:**
- Create: `.claude-plugin/plugin.json`

- [ ] **Step 1: Create plugin.json**

Create `.claude-plugin/plugin.json`:
```json
{
  "name": "team-plugin",
  "version": "0.1.0",
  "description": "Team AI plugin — skills, agents, hooks, and context for Claude Code and GitHub Copilot CLI",
  "author": {
    "name": "Your Team Name",
    "url": "https://github.com/your-org/team-plugin"
  },
  "repository": "https://github.com/your-org/team-plugin",
  "license": "MIT",
  "keywords": ["team", "productivity", "skills", "workflow"]
}
```

- [ ] **Step 2: Verify JSON is valid**

```bash
python3 -m json.tool .claude-plugin/plugin.json
```

Expected: pretty-printed JSON with no errors

- [ ] **Step 3: Commit**

```bash
git add .claude-plugin/plugin.json
git commit -m "feat: add plugin manifest"
```

---

## Task 3: Copy in skill-creator skill

**Files:**
- Create: `skills/skill-creator/SKILL.md`

- [ ] **Step 1: Create SKILL.md with provenance header and full content**

Create `skills/skill-creator/SKILL.md`. The file must begin with this provenance header, then include the full skill content verbatim:

```markdown
<!-- SOURCE: copied from skill-creator@claude-plugins-official -->
<!-- To update: replace everything below the provenance header with the latest SKILL.md from the official plugin -->

---
name: skill-creator
description: Create new skills, modify and improve existing skills, and measure skill performance. Use when users want to create a skill from scratch, update or optimize an existing skill, run evals to test a skill, benchmark skill performance with variance analysis, or optimize a skill's description for better triggering accuracy.
---

# Skill Creator

A skill for creating new skills and iteratively improving them.

At a high level, the process of creating a skill goes like this:

- Decide what you want the skill to do and roughly how it should do it
- Write a draft of the skill
- Create a few test prompts and run claude-with-access-to-the-skill on them
- Help the user evaluate the results both qualitatively and quantitatively
  - While the runs happen in the background, draft some quantitative evals if there aren't any (if there are some, you can either use as is or modify if you feel something needs to change about them). Then explain them to the user (or if they already existed, explain the ones that already exist)
  - Use the `eval-viewer/generate_review.py` script to show the user the results for them to look at, and also let them look at the quantitative metrics
- Rewrite the skill based on feedback from the user's evaluation of the results (and also if there are any glaring flaws that become apparent from the quantitative benchmarks)
- Repeat until you're satisfied
- Expand the test set and try again at larger scale

Your job when using this skill is to figure out where the user is in this process and then jump in and help them progress through these stages. So for instance, maybe they're like "I want to make a skill for X". You can help narrow down what they mean, write a draft, write the test cases, figure out how they want to evaluate, run all the prompts, and repeat.

On the other hand, maybe they already have a draft of the skill. In this case you can go straight to the eval/iterate part of the loop.

Of course, you should always be flexible and if the user is like "I don't need to run a bunch of evaluations, just vibe with me", you can do that instead.

Then after the skill is done (but again, the order is flexible), you can also run the skill description improver, which we have a whole separate script for, to optimize the triggering of the skill.

Cool? Cool.

## Communicating with the user

The skill creator is liable to be used by people across a wide range of familiarity with coding jargon. If you haven't heard (and how could you, it's only very recently that it started), there's a trend now where the power of Claude is inspiring plumbers to open up their terminals, parents and grandparents to google "how to install npm". On the other hand, the bulk of users are probably fairly computer-literate.

So please pay attention to context cues to understand how to phrase your communication! In the default case, just to give you some idea:

- "evaluation" and "benchmark" are borderline, but OK
- for "JSON" and "assertion" you want to see serious cues from the user that they know what those things are before using them without explaining them

It's OK to briefly explain terms if you're in doubt, and feel free to clarify terms with a short definition if you're unsure if the user will get it.

---

## Creating a skill

### Capture Intent

Start by understanding the user's intent. The current conversation might already contain a workflow the user wants to capture (e.g., they say "turn this into a skill"). If so, extract answers from the conversation history first — the tools used, the sequence of steps, corrections the user made, input/output formats observed. The user may need to fill the gaps, and should confirm before proceeding to the next step.

1. What should this skill enable Claude to do?
2. When should this skill trigger? (what user phrases/contexts)
3. What's the expected output format?
4. Should we set up test cases to verify the skill works? Skills with objectively verifiable outputs (file transforms, data extraction, code generation, fixed workflow steps) benefit from test cases. Skills with subjective outputs (writing style, art) often don't need them. Suggest the appropriate default based on the skill type, but let the user decide.

### Interview and Research

Proactively ask questions about edge cases, input/output formats, example files, success criteria, and dependencies. Wait to write test prompts until you've got this part ironed out.

Check available MCPs - if useful for research (searching docs, finding similar skills, looking up best practices), research in parallel via subagents if available, otherwise inline. Come prepared with context to reduce burden on the user.

### Write the SKILL.md

Based on the user interview, fill in these components:

- **name**: Skill identifier
- **description**: When to trigger, what it does. This is the primary triggering mechanism - include both what the skill does AND specific contexts for when to use it. All "when to use" info goes here, not in the body. Note: currently Claude has a tendency to "undertrigger" skills -- to not use them when they'd be useful. To combat this, please make the skill descriptions a little bit "pushy". So for instance, instead of "How to build a simple fast dashboard to display internal Anthropic data.", you might write "How to build a simple fast dashboard to display internal Anthropic data. Make sure to use this skill whenever the user mentions dashboards, data visualization, internal metrics, or wants to display any kind of company data, even if they don't explicitly ask for a 'dashboard.'"
- **compatibility**: Required tools, dependencies (optional, rarely needed)
- **the rest of the skill :)**

### Skill Writing Guide

#### Anatomy of a Skill

```
skill-name/
├── SKILL.md (required)
│   ├── YAML frontmatter (name, description required)
│   └── Markdown instructions
└── Bundled Resources (optional)
    ├── scripts/    - Executable code for deterministic/repetitive tasks
    ├── references/ - Docs loaded into context as needed
    └── assets/     - Files used in output (templates, icons, fonts)
```

#### Progressive Disclosure

Skills use a three-level loading system:
1. **Metadata** (name + description) - Always in context (~100 words)
2. **SKILL.md body** - In context whenever skill triggers (<500 lines ideal)
3. **Bundled resources** - As needed (unlimited, scripts can execute without loading)

These word counts are approximate and you can feel free to go longer if needed.

**Key patterns:**
- Keep SKILL.md under 500 lines; if you're approaching this limit, add an additional layer of hierarchy along with clear pointers about where the model using the skill should go next to follow up.
- Reference files clearly from SKILL.md with guidance on when to read them
- For large reference files (>300 lines), include a table of contents

**Domain organization**: When a skill supports multiple domains/frameworks, organize by variant:
```
cloud-deploy/
├── SKILL.md (workflow + selection)
└── references/
    ├── aws.md
    ├── gcp.md
    └── azure.md
```
Claude reads only the relevant reference file.

#### Principle of Lack of Surprise

This goes without saying, but skills must not contain malware, exploit code, or any content that could compromise system security. A skill's contents should not surprise the user in their intent if described. Don't go along with requests to create misleading skills or skills designed to facilitate unauthorized access, data exfiltration, or other malicious activities. Things like a "roleplay as an XYZ" are OK though.

#### Writing Patterns

Prefer using the imperative form in instructions.

**Defining output formats** - You can do it like this:
```markdown
## Report structure
ALWAYS use this exact template:
# [Title]
## Executive summary
## Key findings
## Recommendations
```

**Examples pattern** - It's useful to include examples. You can format them like this:
```markdown
## Commit message format
**Example 1:**
Input: Added user authentication with JWT tokens
Output: feat(auth): implement JWT-based authentication
```

### Writing Style

Try to explain to the model why things are important in lieu of heavy-handed musty MUSTs. Use theory of mind and try to make the skill general and not super-narrow to specific examples. Start by writing a draft and then look at it with fresh eyes and improve it.

### Test Cases

After writing the skill draft, come up with 2-3 realistic test prompts — the kind of thing a real user would actually say. Share them with the user: "Here are a few test cases I'd like to try. Do these look right, or do you want to add more?" Then run them.

Save test cases to `evals/evals.json`. Don't write assertions yet — just the prompts. You'll draft assertions in the next step while the runs are in progress.

```json
{
  "skill_name": "example-skill",
  "evals": [
    {
      "id": 1,
      "prompt": "User's task prompt",
      "expected_output": "Description of expected result",
      "files": []
    }
  ]
}
```

See `references/schemas.md` for the full schema (including the `assertions` field, which you'll add later).

## Running and evaluating test cases

This section is one continuous sequence — don't stop partway through. Do NOT use `/skill-test` or any other testing skill.

Put results in `<skill-name>-workspace/` as a sibling to the skill directory. Within the workspace, organize results by iteration (`iteration-1/`, `iteration-2/`, etc.) and within that, each test case gets a directory (`eval-0/`, `eval-1/`, etc.). Don't create all of this upfront — just create directories as you go.

### Step 1: Spawn all runs (with-skill AND baseline) in the same turn

For each test case, spawn two subagents in the same turn — one with the skill, one without. This is important: don't spawn the with-skill runs first and then come back for baselines later. Launch everything at once so it all finishes around the same time.

**With-skill run:**

```
Execute this task:
- Skill path: <path-to-skill>
- Task: <eval prompt>
- Input files: <eval files if any, or "none">
- Save outputs to: <workspace>/iteration-<N>/eval-<ID>/with_skill/outputs/
- Outputs to save: <what the user cares about>
```

**Baseline run** (same prompt, but the baseline depends on context):
- **Creating a new skill**: no skill at all. Same prompt, no skill path, save to `without_skill/outputs/`.
- **Improving an existing skill**: the old version. Before editing, snapshot the skill (`cp -r <skill-path> <workspace>/skill-snapshot/`), then point the baseline subagent at the snapshot. Save to `old_skill/outputs/`.

Write an `eval_metadata.json` for each test case (assertions can be empty for now).

### Step 2: While runs are in progress, draft assertions

Don't just wait for the runs to finish — draft quantitative assertions for each test case and explain them to the user. Good assertions are objectively verifiable and have descriptive names.

### Step 3: As runs complete, capture timing data

When each subagent task completes, save timing data immediately to `timing.json` in the run directory:

```json
{
  "total_tokens": 84852,
  "duration_ms": 23332,
  "total_duration_seconds": 23.3
}
```

### Step 4: Grade, aggregate, and launch the viewer

Once all runs are done:

1. **Grade each run** — spawn a grader subagent that evaluates each assertion against the outputs. Save results to `grading.json`.

2. **Aggregate into benchmark** — run:
   ```bash
   python -m scripts.aggregate_benchmark <workspace>/iteration-N --skill-name <name>
   ```

3. **Do an analyst pass** — read the benchmark data and surface patterns the aggregate stats might hide.

4. **Launch the viewer**:
   ```bash
   nohup python <skill-creator-path>/eval-viewer/generate_review.py \
     <workspace>/iteration-N \
     --skill-name "my-skill" \
     --benchmark <workspace>/iteration-N/benchmark.json \
     > /dev/null 2>&1 &
   ```

5. Tell the user: "I've opened the results in your browser. There are two tabs — 'Outputs' and 'Benchmark'. When you're done, let me know."

### Step 5: Read the feedback

When the user is done, read `feedback.json` and focus improvements on test cases where the user had specific complaints.

---

## Improving the skill

After improving the skill: apply changes, rerun all test cases into a new `iteration-<N+1>/` directory, launch the reviewer with `--previous-workspace` pointing at the previous iteration, wait for user review. Keep going until the user is happy or feedback is all empty.

---

## Advanced: Blind comparison

For rigorous comparison between two skill versions, read `agents/comparator.md` and `agents/analyzer.md`. Optional — most users won't need it.

---

## Description Optimization

After creating or improving a skill, offer to optimize the description for better triggering accuracy using the optimization loop:

```bash
python -m scripts.run_loop \
  --eval-set <path-to-trigger-eval.json> \
  --skill-path <path-to-skill> \
  --model <model-id-powering-this-session> \
  --max-iterations 5 \
  --verbose
```

---

## Reference files

- `agents/grader.md` — How to evaluate assertions against outputs
- `agents/comparator.md` — How to do blind A/B comparison
- `agents/analyzer.md` — How to analyze benchmark results
- `references/schemas.md` — JSON structures for evals.json, grading.json, etc.
```

- [ ] **Step 2: Verify file was created and has correct YAML frontmatter**

```bash
head -10 skills/skill-creator/SKILL.md
```

Expected: HTML comment lines followed by `---`, `name: skill-creator`, `description:` line

- [ ] **Step 3: Commit**

```bash
git add skills/skill-creator/SKILL.md
git commit -m "feat: add skill-creator skill (copied from skill-creator@claude-plugins-official)"
```

---

## Task 4: Copy in code-reviewer agent

**Files:**
- Create: `agents/code-reviewer.md`

- [ ] **Step 1: Create code-reviewer.md with provenance header and full content**

Create `agents/code-reviewer.md`:

```markdown
<!-- SOURCE: copied from superpowers@claude-plugins-official v5.0.7 -->
<!-- To update: replace everything below the provenance header with the latest code-reviewer.md from the superpowers plugin -->

---
name: code-reviewer
description: |
  Use this agent when a major project step has been completed and needs to be reviewed against the original plan and coding standards. Examples: <example>Context: The user is creating a code-review agent that should be called after a logical chunk of code is written. user: "I've finished implementing the user authentication system as outlined in step 3 of our plan" assistant: "Great work! Now let me use the code-reviewer agent to review the implementation against our plan and coding standards" <commentary>Since a major project step has been completed, use the code-reviewer agent to validate the work against the plan and identify any issues.</commentary></example> <example>Context: User has completed a significant feature implementation. user: "The API endpoints for the task management system are now complete - that covers step 2 from our architecture document" assistant: "Excellent! Let me have the code-reviewer agent examine this implementation to ensure it aligns with our plan and follows best practices" <commentary>A numbered step from the planning document has been completed, so the code-reviewer agent should review the work.</commentary></example>
model: inherit
---

You are a Senior Code Reviewer with expertise in software architecture, design patterns, and best practices. Your role is to review completed project steps against original plans and ensure code quality standards are met.

When reviewing completed work, you will:

1. **Plan Alignment Analysis**:
   - Compare the implementation against the original planning document or step description
   - Identify any deviations from the planned approach, architecture, or requirements
   - Assess whether deviations are justified improvements or problematic departures
   - Verify that all planned functionality has been implemented

2. **Code Quality Assessment**:
   - Review code for adherence to established patterns and conventions
   - Check for proper error handling, type safety, and defensive programming
   - Evaluate code organization, naming conventions, and maintainability
   - Assess test coverage and quality of test implementations
   - Look for potential security vulnerabilities or performance issues

3. **Architecture and Design Review**:
   - Ensure the implementation follows SOLID principles and established architectural patterns
   - Check for proper separation of concerns and loose coupling
   - Verify that the code integrates well with existing systems
   - Assess scalability and extensibility considerations

4. **Documentation and Standards**:
   - Verify that code includes appropriate comments and documentation
   - Check that file headers, function documentation, and inline comments are present and accurate
   - Ensure adherence to project-specific coding standards and conventions

5. **Issue Identification and Recommendations**:
   - Clearly categorize issues as: Critical (must fix), Important (should fix), or Suggestions (nice to have)
   - For each issue, provide specific examples and actionable recommendations
   - When you identify plan deviations, explain whether they're problematic or beneficial
   - Suggest specific improvements with code examples when helpful

6. **Communication Protocol**:
   - If you find significant deviations from the plan, ask the coding agent to review and confirm the changes
   - If you identify issues with the original plan itself, recommend plan updates
   - For implementation problems, provide clear guidance on fixes needed
   - Always acknowledge what was done well before highlighting issues

Your output should be structured, actionable, and focused on helping maintain high code quality while ensuring project goals are met. Be thorough but concise, and always provide constructive feedback that helps improve both the current implementation and future development practices.
```

- [ ] **Step 2: Verify frontmatter is present**

```bash
head -15 agents/code-reviewer.md
```

Expected: provenance comment, then `---`, `name: code-reviewer`, `description:` block, `model: inherit`

- [ ] **Step 3: Commit**

```bash
git add agents/code-reviewer.md
git commit -m "feat: add code-reviewer agent (copied from superpowers@claude-plugins-official v5.0.7)"
```

---

## Task 5: Hook scripts

**Files:**
- Create: `hooks/scripts/session-start.sh`
- Create: `hooks/scripts/pre-tool-use-bash.sh`
- Create: `hooks/scripts/post-tool-use-write.sh`

- [ ] **Step 1: Create session-start.sh**

Create `hooks/scripts/session-start.sh`:

```bash
#!/bin/bash
# SESSION START HOOK
# Runs at the beginning of each Claude Code session.
# Customize this script to load team context, print reminders, etc.
#
# TODO: Replace the banner text below with your team's content.

cat << 'EOF'
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Team Plugin loaded
 • Team conventions → see CLAUDE.md
 • Code review      → superpowers:code-reviewer agent
 • Skill creator    → skill-creator skill
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
```

- [ ] **Step 2: Create pre-tool-use-bash.sh**

Create `hooks/scripts/pre-tool-use-bash.sh`:

```bash
#!/bin/bash
# PRE TOOL USE HOOK — Bash tool guard
# Reads the tool input JSON from stdin.
# Output {"decision":"block","reason":"..."} to prevent the command.
# Exit 0 (or output {"decision":"approve"}) to allow it.
#
# TODO: Customize DANGEROUS_PATTERNS for your team's safety requirements.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(data.get('command', ''))
except Exception:
    print('')
" 2>/dev/null)

DANGEROUS_PATTERNS=(
  "rm -rf /"
  "git push --force"
  "git push -f"
  "DROP TABLE"
  "drop table"
)

for pattern in "${DANGEROUS_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qF "$pattern"; then
    printf '{"decision":"block","reason":"Potentially destructive command detected: %s. Please confirm this is intentional."}\n' "$pattern"
    exit 0
  fi
done

exit 0
```

- [ ] **Step 3: Create post-tool-use-write.sh**

Create `hooks/scripts/post-tool-use-write.sh`:

```bash
#!/bin/bash
# POST TOOL USE HOOK — Write tool
# Runs after every Write tool call.
# Receives JSON with tool_name, tool_input, tool_response via stdin.
#
# TODO: Uncomment one of the examples below to enable auto-formatting.

# INPUT=$(cat)
# FILE_PATH=$(echo "$INPUT" | python3 -c "
# import sys, json
# try:
#     data = json.load(sys.stdin)
#     print(data.get('tool_input', {}).get('file_path', ''))
# except Exception:
#     print('')
# " 2>/dev/null)

# --- Example 1: Auto-format Python files ---
# if echo "$FILE_PATH" | grep -q '\.py$'; then
#   black "$FILE_PATH" 2>/dev/null || true
# fi

# --- Example 2: Auto-format JS/TS files ---
# if echo "$FILE_PATH" | grep -qE '\.(js|ts|jsx|tsx)$'; then
#   npx prettier --write "$FILE_PATH" 2>/dev/null || true
# fi

# --- Example 3: Run ESLint after write ---
# if echo "$FILE_PATH" | grep -qE '\.(js|ts)$'; then
#   npx eslint --fix "$FILE_PATH" 2>/dev/null || true
# fi

exit 0
```

- [ ] **Step 4: Make scripts executable**

```bash
chmod +x hooks/scripts/session-start.sh hooks/scripts/pre-tool-use-bash.sh hooks/scripts/post-tool-use-write.sh
```

- [ ] **Step 5: Verify scripts run without errors**

```bash
bash hooks/scripts/session-start.sh
```

Expected: prints the banner with `Team Plugin loaded` text

```bash
echo '{"command":"echo hello"}' | bash hooks/scripts/pre-tool-use-bash.sh
echo $?
```

Expected: exit code `0` (no output — command is safe)

```bash
echo '{"command":"rm -rf /"}' | bash hooks/scripts/pre-tool-use-bash.sh
```

Expected: `{"decision":"block","reason":"Potentially destructive command detected: rm -rf /..."}`

- [ ] **Step 6: Commit**

```bash
git add hooks/scripts/
git commit -m "feat: add hook scripts (session-start, pre-tool-use-bash, post-tool-use-write)"
```

---

## Task 6: hooks.json

**Files:**
- Create: `hooks/hooks.json`

- [ ] **Step 1: Create hooks.json**

Create `hooks/hooks.json`:

```json
{
  "description": "Team plugin hooks. Each section is a working example — customize or extend for your team.",
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash \"${CLAUDE_PLUGIN_ROOT}/hooks/scripts/session-start.sh\"",
            "timeout": 10
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"${CLAUDE_PLUGIN_ROOT}/hooks/scripts/pre-tool-use-bash.sh\"",
            "timeout": 10
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"${CLAUDE_PLUGIN_ROOT}/hooks/scripts/post-tool-use-write.sh\"",
            "timeout": 30
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Before completing, reflect: have the changes been tested or verified? If there are untested or unverified changes, remind the user to check them before signing off. If everything looks confirmed, proceed normally.",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

- [ ] **Step 2: Verify JSON is valid**

```bash
python3 -m json.tool hooks/hooks.json > /dev/null && echo "valid JSON"
```

Expected: `valid JSON`

- [ ] **Step 3: Commit**

```bash
git add hooks/hooks.json
git commit -m "feat: add hooks.json with SessionStart, PreToolUse, PostToolUse, and Stop scaffolds"
```

---

## Task 7: MCP placeholder

**Files:**
- Create: `.mcp.json`

- [ ] **Step 1: Create .mcp.json**

Create `.mcp.json`:

```json
{}
```

- [ ] **Step 2: Verify JSON is valid**

```bash
python3 -m json.tool .mcp.json > /dev/null && echo "valid JSON"
```

Expected: `valid JSON`

- [ ] **Step 3: Commit**

```bash
git add .mcp.json
git commit -m "chore: add empty .mcp.json placeholder for future internal MCP"
```

---

## Task 8: Team context template (CLAUDE.md)

**Files:**
- Create: `CLAUDE.md`

- [ ] **Step 1: Create CLAUDE.md**

Create `CLAUDE.md`:

```markdown
# Team Context

This file is loaded by the SessionStart hook and gives Claude Code context about your team's conventions and resources. Replace every `TODO` section before sharing with teammates.

## Team
<!-- TODO: Fill in your team details -->
- **Team name:** [Your Team Name]
- **Primary repo:** [https://github.com/your-org/your-repo]
- **Internal docs:** [https://your-internal-docs-url]

## Coding Conventions
<!-- TODO: Add your team's standards. Examples below — replace with your actual rules. -->
- Branch naming: `feature/<ticket>-description`, `fix/<ticket>-description`
- Commit format: Conventional Commits (`feat:`, `fix:`, `chore:`, `docs:`, etc.)
- PR policy: at least 1 review required before merge; no direct pushes to `main`
- [Add more conventions here]

## Key Links
<!-- TODO: Replace with real URLs -->
- CI/CD dashboard: [URL]
- On-call runbook: [URL]
- Architecture docs: [URL]

## Internal MCP
The internal MCP server will be configured in `.mcp.json` when available.
Format for a stdio server:
```json
{
  "server-name": {
    "command": "/path/to/server",
    "args": ["--flag"],
    "env": { "API_KEY": "${API_KEY}" }
  }
}
```

## Installed Components
| Component | Type | Purpose |
|-----------|------|---------|
| `skill-creator` | Skill | Create and improve agent skills |
| `code-reviewer` | Agent | Review completed implementation steps |
| `session-start` hook | Hook | Prints team banner on session start |
| `pre-tool-use-bash` hook | Hook | Guards dangerous Bash commands |
| `post-tool-use-write` hook | Hook | Placeholder for auto-format on file write |
| `Stop` hook | Hook | Prompt-based quality gate before completion |
```

- [ ] **Step 2: Verify file has no literal `[placeholder]` text left in required fields**

```bash
grep -n "TODO" CLAUDE.md
```

Expected: lines with `<!-- TODO:` comments are present (intentional — they're instructions for the team to fill in)

- [ ] **Step 3: Commit**

```bash
git add CLAUDE.md
git commit -m "feat: add CLAUDE.md team context template"
```

---

## Task 9: README

**Files:**
- Modify: `README.md` (replace placeholder from Task 1)

- [ ] **Step 1: Write README.md**

Create `README.md` (replaces the placeholder):

```markdown
# team-plugin

A self-contained Claude Code + GitHub Copilot CLI plugin for teams. Install via a single GitHub URL to get a curated set of official skills, a code review agent, four hook scaffolds, and a team context template.

## Install

**Claude Code:**
```bash
/plugin install https://github.com/your-org/team-plugin
```

**GitHub Copilot CLI:**
```bash
copilot plugin marketplace add https://github.com/your-org/team-plugin
copilot plugin install team-plugin@your-org
```

## What's Included

| Component | Type | Source |
|-----------|------|--------|
| `skill-creator` | Skill | Copied from `skill-creator@claude-plugins-official` |
| `code-reviewer` | Agent | Copied from `superpowers@claude-plugins-official` v5.0.7 |
| `SessionStart` hook | Hook | Example — prints team banner |
| `PreToolUse` hook | Hook | Example — guards dangerous Bash commands |
| `PostToolUse` hook | Hook | Example — placeholder for auto-format |
| `Stop` hook | Hook | Example — prompt-based quality gate |

## Setup After Install

1. **Fill in `CLAUDE.md`** — replace the `TODO` sections with your team name, doc links, and coding conventions.
2. **Customize hooks** (optional) — edit `hooks/scripts/` to match your team's policies:
   - `session-start.sh` — update the banner text
   - `pre-tool-use-bash.sh` — add or remove dangerous patterns
   - `post-tool-use-write.sh` — uncomment the auto-format example for your stack
3. **Add internal MCP** (when ready) — drop your server config into `.mcp.json`. See `CLAUDE.md` for the expected format.

## Updating Official Content

Both `skills/skill-creator/SKILL.md` and `agents/code-reviewer.md` carry a `<!-- SOURCE: -->` header comment. To update them to a newer upstream version:

1. Find the latest file in the official plugin's GitHub repo
2. Replace the file content (keep the provenance header at the top)
3. Commit with `chore: update <component> from upstream`

## License

MIT
```

- [ ] **Step 2: Commit**

```bash
git add README.md
git commit -m "docs: add README with install instructions and component overview"
```

---

## Task 10: Final verification

- [ ] **Step 1: Verify complete file structure**

```bash
find . -not -path './.git/*' | sort
```

Expected output:
```
.
./.claude-plugin
./.claude-plugin/plugin.json
./.mcp.json
./CLAUDE.md
./README.md
./agents
./agents/code-reviewer.md
./docs
./docs/superpowers
./docs/superpowers/plans
./docs/superpowers/plans/2026-04-14-team-plugin.md
./docs/superpowers/specs
./docs/superpowers/specs/2026-04-14-team-plugin-design.md
./hooks
./hooks/hooks.json
./hooks/scripts
./hooks/scripts/post-tool-use-write.sh
./hooks/scripts/pre-tool-use-bash.sh
./hooks/scripts/session-start.sh
./skills
./skills/skill-creator
./skills/skill-creator/SKILL.md
```

- [ ] **Step 2: Verify all JSON files are valid**

```bash
for f in .claude-plugin/plugin.json hooks/hooks.json .mcp.json; do
  python3 -m json.tool "$f" > /dev/null && echo "OK: $f" || echo "INVALID: $f"
done
```

Expected:
```
OK: .claude-plugin/plugin.json
OK: hooks/hooks.json
OK: .mcp.json
```

- [ ] **Step 3: Verify all scripts are executable and run without error**

```bash
for s in hooks/scripts/*.sh; do
  test -x "$s" && echo "executable: $s" || echo "NOT executable: $s"
done
bash hooks/scripts/session-start.sh
```

Expected: all scripts listed as executable; banner prints cleanly

- [ ] **Step 4: Verify provenance headers are present in both copied files**

```bash
head -2 skills/skill-creator/SKILL.md
head -2 agents/code-reviewer.md
```

Expected: both start with `<!-- SOURCE: copied from ...`

- [ ] **Step 5: Final commit**

```bash
git log --oneline
```

Expected: 8–9 commits, each covering one logical component

