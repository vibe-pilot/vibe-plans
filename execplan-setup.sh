#!/usr/bin/env bash

# ============================================================
# VibePlans: ExecPlan + Brainstorming Setup Script
# ============================================================
# 兼容工具及配置文件:
# - Codex CLI    → AGENTS.md, .agent/AGENTS.md
# - Claude Code  → CLAUDE.md
# - Copilot-CLI  → AGENTS.md
# - OpenCode     → AGENTS.md
#
# 用法: ./execplan-setup.sh [codex|claude|copilot|opencode]
#        默认: codex
# ============================================================

set -euo pipefail

# --- 常量 ---
MARKER="Brainstorming Ideas Into Designs"
PLAN_MARKER="Codex Execution Plans (ExecPlans) with Brainstorming"

AGENT_DIR=".agent"
PLAN_FILE="$AGENT_DIR/PLANS.md"

# 各工具的配置文件（按优先级排序）
# 使用关联数组，兼容 bash 4+
get_tool_files() {
  local tool="$1"
  case "$tool" in
    codex)    echo "AGENTS.md .agent/AGENTS.md" ;;
    claude)  echo "CLAUDE.md" ;;
    copilot) echo "AGENTS.md" ;;
    opencode) echo "AGENTS.md" ;;
    *)       echo "AGENTS.md" ;;
  esac
}

# 核心内容片段（所有工具共用）
INTRO_CONTENT='Brainstorming Ideas Into Designs.
Help turn ideas into fully formed designs and specs through natural collaborative dialogue.
Start by understanding the current project context, then ask questions one at a time to refine the idea.
Once you understand what you are building, present the design and get user approval.
Do NOT invoke any implementation skill, write any code, scaffold any project, or take any implementation action until you have presented a design and the user has approved it.
This applies to EVERY project regardless of perceived simplicity.'

EXECPLAN_CONTENT="After the design is explicitly approved by the user, you may:
- Create or update an ExecPlan document that the coding agent can follow.
- Use the milestones, logs, and validation steps described in .agent/PLANS.md.
- Implement the plan autonomously without asking for \"next steps\" at every stage."

# --- 函数 ---
usage() {
  cat << EOF
用法: $0 [选项]

选项:
  --tool <codex|claude|copilot|opencode>  指定目标工具 (默认: codex)
  -h, --help                                    显示帮助

示例:
  $0 --tool claude
  $0 codex
EOF
  exit 0
}

log() {
  echo "[$(date '+%H:%M:%S')] $*"
}

has_marker() {
  local file="$1"
  grep -q "$MARKER" "$file" 2>/dev/null
}

# 检查是否应该替换文件（文件被覆盖/简化的情况）
should_replace() {
  local file="$1"
  # 如果文件为空，或只有空行/简单标题，认为是被覆盖了
  local lines
  lines=$(wc -l < "$file" 2>/dev/null || echo "0")
  [[ "$lines" -le 3 ]]
}

ensure_dir() {
  mkdir -p "$1"
}

# 追加内容到文件（检测重复）
append_if_missing() {
  local file="$1"
  local section="$2"
  local marker="$3"

  if [[ ! -f "$file" ]]; then
    cat > "$file"
    log "创建: $file"
    return
  fi

  if has_marker "$file"; then
    log "跳过: $file (已包含 Brainstorming)"
    return
  fi

  cat >> "$file" << 'SECTION'

---

SECTION
  echo "$section" >> "$file"
  log "追加: $file"
}

# 创建 PLANS.md 模板
create_plan_template() {
  ensure_dir "$AGENT_DIR"

  cat > "$PLAN_FILE" << 'PLANEOF'
# Codex Execution Plans (ExecPlans) with Brainstorming

This document describes the requirements for an execution plan ("ExecPlan"), a design document that a coding agent can follow to deliver a working feature or system change. Treat the reader as a complete beginner to this repository: they have only the current working tree and the single ExecPlan file you provide. There is no memory of prior plans and no external context.

## 0. Brainstorming Ideas Into Designs (Required Pre‑ExecPlan Phase)

Brainstorming Ideas Into Designs.
Help turn ideas into fully formed designs and specs through natural collaborative dialogue.
Start by understanding the current project context, then ask questions one at a time to refine the idea.
Once you understand what you are building, present the design and get user approval.
Do NOT invoke any implementation skill, write any code, scaffold any project, or take any implementation action until you have presented a design and the user has approved it.
This applies to EVERY project regardless of perceived simplicity.

Before you create or modify an ExecPlan, you MUST:

1. Explore the current project context (files, docs, recent changes).
2. Ask clarifying questions one at a time until the goal and constraints are clear.
3. Propose one or more design options and get explicit user approval of the chosen design.
4. Only after approval, proceed to author or update the ExecPlan described below.

## 1. How to Use ExecPlans and This PLANS.md

This ExecPlan is a **living document**. The sections `Progress`, `Surprises & Discoveries`, `Decision Log`, and `Outcomes & Retrospective` must be kept up to date as work proceeds.

When authoring an executable specification (ExecPlan), follow this PLANS.md _to the letter_. If it is not in your context, refresh your memory by reading the entire PLANS.md file. Be thorough in reading (and re‑reading) source material to produce an accurate specification. When creating a spec, start from the skeleton and flesh it out as you do your research.

When implementing an executable specification (ExecPlan), do not prompt the user for "next steps"; simply proceed to the next milestone. Keep all sections up to date, add or split entries in the list at every stopping point to affirmatively state the progress made and next steps. Resolve ambiguities autonomously, and commit frequently.

When discussing an executable specification (ExecPlan), record decisions in a log in the spec for posterity; it should be unambiguously clear why any change to the specification was made. ExecPlans are living documents, and it should always be possible to restart from _only_ the ExecPlan and no other work.

When researching a design with challenging requirements or significant unknowns, use milestones to implement proof of concepts, "toy implementations", etc., that allow validating whether the user's proposal is feasible. Read the source code of libraries by finding or acquiring them, research deeply, and include prototypes to guide a fuller implementation.

## 2. Non‑Negotiable Requirements

Every ExecPlan MUST satisfy all of the following:

1. **Self‑contained**: Contains everything a novice needs to succeed. Do not point to external blogs or docs; embed knowledge directly in the plan.
2. **Living document**: Must be revised as progress is made, discoveries occur, and design decisions are made.
3. **Novice‑guiding**: A complete newcomer to the codebase must be able to implement the feature end‑to‑end.
4. **Outcome‑focused**: Must produce demonstrably valid behavior, not just code changes that satisfy definitions.
5. **Defined terms**: Every non‑obvious term must be defined in plain language.

**Format rules**:
- The entire ExecPlan must be enclosed in a single ```md code block.
- No nested triple backticks inside.
- Use indentation for commands, diffs, and code snippets.
- Two blank lines after headings.
- Prefer sentences over bullet points. Bullet lists are only allowed in the Progress section.
- Use specific and minimal descriptions.

## 3. ExecPlan Skeleton

Fill in every section completely. Follow the format and examples exactly.

### Purpose / Big Picture

Explain what the user gets after this change and how they can see it working. State the user‑visible behaviors that will be enabled.

### Progress

Use checkbox lists to summarize granular steps. Record every stopping point here. Use timestamps to measure progress.

```
- [x] (2025-10-01 13:00Z) Completed example step.
- [ ] Incomplete example step.
- [ ] Partially done (completed: X; remaining: Y).
```

### Surprises & Discoveries

Record unexpected behaviors, bugs, optimizations, or insights discovered during implementation. Provide brief evidence.

```
- Observation: …
- Evidence: …
```

### Decision Log

Record every decision made during the work:

```
- Decision: …
- Rationale: …
- Date/Author: …
```

### Outcomes & Retrospective

At major milestones or upon completion, summarize results, gaps, and lessons learned. Compare outcomes against the original Purpose.

### Context and Orientation

Describe the current state relevant to the task, as if the reader knows nothing. Name key files and modules with full paths. Define any non‑obvious terms you will use. Do not reference prior plans.

### Plan of Work

Describe in prose the order in which sections will be edited and added. For each edit, name the file and location (function, module) and what will be inserted or changed. Keep it specific and minimal.

### Concrete Steps

State the exact commands to run and where (working directory). When commands generate output, show brief expected transcriptions for comparison. Update this section as work progresses.

### Validation and Acceptance

Describe how to start or use the system and what to observe. Express acceptance criteria as behaviors with specific inputs and outputs. If tests are involved, state "run and expect to pass; new tests fail before the change and pass after."

### Idempotence and Recovery

If steps can be safely repeated, state so. If steps have risks, provide safe retry or rollback paths. Keep the environment clean after completion.

### Artifacts and Notes

Include the most important transcriptions, diffs, or snippets as indented examples. Keep it concise and focused on evidence of success.

### Interfaces and Dependencies

Be specific. Name the libraries, modules, and services to use and why. Specify the types, traits/interfaces, and function signatures that must exist.

Example:
In `crates/foo/planner.rs`, define:

```rust
pub trait Planner {
    fn plan(&self, observed: &Observed) -> Vec<PlanStep>;
}
```

### Prototyping Milestones (Optional)

When reducing risk for larger changes, prototyping milestones are allowed. Keep prototypes additive and testable. Clearly mark the scope as "prototyping". Describe how to run and observe results. State criteria for promoting or abandoning the prototype.

PLANEOF

  log "创建: $PLAN_FILE"
}

# --- 主逻辑 ---
main() {
  local tool="codex"

  # 解析参数
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --tool|-t)
        tool="${2:-codex}"
        shift 2
        ;;
      --help|-h)
        usage
        ;;
      codex|claude|copilot|opencode)
        tool="$1"
        shift
        ;;
      *)
        echo "未知选项: $1"
        usage
        ;;
    esac
  done

  log "开始为 $tool 设置 Brainstorming + ExecPlan..."

  # 1. 处理项目根目录的配置文件
  local tool_files
  tool_files=$(get_tool_files "$tool")
  local files=($tool_files)
  for file in "${files[@]}"; do
    local dir
    dir=$(dirname "$file")
    [[ -n "$dir" && "$dir" != "." ]] && ensure_dir "$dir"

    if [[ ! -f "$file" ]]; then
      cat > "$file" << HEADER
# Project Instructions

## Brainstorming Ideas Into Designs (Pre‑Implementation)

$INTRO_CONTENT

## ExecPlans (Design → Implementation)

$EXECPLAN_CONTENT
HEADER
      log "创建: $file"
    elif has_marker "$file"; then
      log "跳过: $file (已包含 Brainstorming)"
    elif should_replace "$file"; then
      cat > "$file" << HEADER
# Project Instructions

## Brainstorming Ideas Into Designs (Pre‑Implementation)

$INTRO_CONTENT

## ExecPlans (Design → Implementation)

$EXECPLAN_CONTENT
HEADER
      log "替换: $file (检测到文件被覆盖，已恢复)"
    else
      cat >> "$file" << APPEND

---

## Brainstorming Ideas Into Designs (Pre‑Implementation)

$INTRO_CONTENT

## ExecPlans (Design → Implementation)

$EXECPLAN_CONTENT
APPEND
      log "追加: $file"
    fi
  done

  # 2. 创建 .agent/AGENTS.md (仅 Codex 需要)
  if [[ "$tool" == "codex" ]]; then
    ensure_dir "$AGENT_DIR"
    local agent_file="$AGENT_DIR/AGENTS.md"

    if [[ ! -f "$agent_file" ]]; then
      cat > "$agent_file" << AGENTS
# Repo Agents Instructions

This repository uses a two‑phase workflow:

1. Brainstorming Ideas Into Designs (pre‑implementation)
2. ExecPlans (design → implementation)

## 1. Brainstorming Ideas Into Designs (Pre‑Implementation Phase)

$INTRO_CONTENT

When starting ANY new task (feature, refactor, config, documentation structure, etc.) you MUST:

1. Explore the current project context (files, docs, recent changes).
2. Ask clarifying questions one at a time until the goal and constraints are clear.
3. Propose one or more design options with trade‑offs and a recommendation.
4. Present a concise design/spec and get explicit user approval before any implementation.

## 2. ExecPlans (Design → Implementation Phase)

When writing complex features or significant refactors, AFTER the design has been approved,
use an ExecPlan (as described in .agent/PLANS.md) from design to implementation.

ExecPlans are living documents that:
- Are fully self‑contained (no external memory beyond the working tree and the plan file itself).
- Contain milestones, validation steps, and logs of decisions.
- Allow a coding agent to continue work or restart from ONLY the ExecPlan + repo state.

Agents MUST:
- Always follow the Brainstorming phase BEFORE creating or modifying ExecPlans.
- Then follow the ExecPlan rules in .agent/PLANS.md _to the letter_ during implementation.
AGENTS
      log "创建: $agent_file"
    elif has_marker "$agent_file"; then
      log "跳过: $agent_file (已包含 Brainstorming)"
    elif should_replace "$agent_file"; then
      cat > "$agent_file" << AGENTS
# Repo Agents Instructions

This repository uses a two‑phase workflow:

1. Brainstorming Ideas Into Designs (pre‑implementation)
2. ExecPlans (design → implementation)

## 1. Brainstorming Ideas Into Designs (Pre‑Implementation Phase)

$INTRO_CONTENT

When starting ANY new task (feature, refactor, config, documentation structure, etc.) you MUST:

1. Explore the current project context (files, docs, recent changes).
2. Ask clarifying questions one at a time until the goal and constraints are clear.
3. Propose one or more design options with trade‑offs and a recommendation.
4. Present a concise design/spec and get explicit user approval before any implementation.

## 2. ExecPlans (Design → Implementation Phase)

When writing complex features or significant refactors, AFTER the design has been approved,
use an ExecPlan (as described in .agent/PLANS.md) from design to implementation.

ExecPlans are living documents that:
- Are fully self‑contained (no external memory beyond the working tree and the plan file itself).
- Contain milestones, validation steps, and logs of decisions.
- Allow a coding agent to continue work or restart from ONLY the ExecPlan + repo state.

Agents MUST:
- Always follow the Brainstorming phase BEFORE creating or modifying ExecPlans.
- Then follow the ExecPlan rules in .agent/PLANS.md _to the letter_ during implementation.
AGENTS
      log "替换: $agent_file (检测到文件被覆盖，已恢复)"
    else
      cat >> "$agent_file" << AGENTS

---

# Repo Agents Instructions

This repository uses a two‑phase workflow:

1. Brainstorming Ideas Into Designs (pre‑implementation)
2. ExecPlans (design → implementation)

## 1. Brainstorming Ideas Into Designs (Pre‑Implementation Phase)

$INTRO_CONTENT

When starting ANY new task (feature, refactor, config, documentation structure, etc.) you MUST:

1. Explore the current project context (files, docs, recent changes).
2. Ask clarifying questions one at a time until the goal and constraints are clear.
3. Propose one or more design options with trade‑offs and a recommendation.
4. Present a concise design/spec and get explicit user approval before any implementation.

## 2. ExecPlans (Design → Implementation Phase)

When writing complex features or significant refactors, AFTER the design has been approved,
use an ExecPlan (as described in .agent/PLANS.md) from design to implementation.

ExecPlans are living documents that:
- Are fully self‑contained (no external memory beyond the working tree and the plan file itself).
- Contain milestones, validation steps, and logs of decisions.
- Allow a coding agent to continue work or restart from ONLY the ExecPlan + repo state.

Agents MUST:
- Always follow the Brainstorming phase BEFORE creating or modifying ExecPlans.
- Then follow the ExecPlan rules in .agent/PLANS.md _to the letter_ during implementation.
AGENTS
      log "追加: $agent_file"
    fi
  fi

  # 3. 创建/更新 PLANS.md 模板
  if [[ -f "$PLAN_FILE" ]] && grep -q "$PLAN_MARKER" "$PLAN_FILE"; then
    log "跳过: $PLAN_FILE (已是最新版模板)"
  else
    create_plan_template
  fi

  echo ""
  log "完成！已为 $tool 配置 Brainstorming + ExecPlan"
  echo ""
  echo "创建/更新的文件:"
  echo "  - ${files[*]}"
  [[ "$tool" == "codex" ]] && echo "  - $AGENT_DIR/AGENTS.md"
  echo "  - $PLAN_FILE"
}

main "$@"
