#!/usr/bin/env bash

# OpenAI ExecPlan + Brainstorming Setup Script
# 兼容 / 适配主流 vibecoding 工具:
# - Codex CLI (gpt-5.x codex)       —— 原生支持 AGENTS.md / .agent
# - GitHub Copilot-CLI              —— 支持项目根 AGENTS.md 作为自定义指令
# - OpenCode                        —— 建议使用 AGENTS.md 作为项目规则文件
# - Cursor IDE                      —— 可读取仓库文件, 用作 Custom Mode/Rules 的来源
# - Claude Code                     —— 通过「项目知识 + 引用文档」遵循仓库内规则
#
# 用法: ./execplan-setup.sh [codex|cursor|claude|opencode|copilot]
# 参数仅作为标签输出，不影响生成内容，方便后续按工具定制扩展。

set -e

ROOT_AGENTS_FILE="AGENTS.md"

AGENT_DIR=".agent"
TEMPLATE_DIR="$AGENT_DIR/template"
PLAN_FILE="$TEMPLATE_DIR/PLAN.md"
AGENTS_FILE="$AGENT_DIR/AGENTS.md"

# 用于 grep 的唯一标记，避免重复追加
ROOT_MARKER="Brainstorming Ideas Into Designs"
AGENT_MARKER="Repo Agents Instructions"
PLAN_MARKER="Codex Execution Plans (ExecPlans) with Brainstorming"

TOOL=$1
if [[ -z "$TOOL" ]]; then
  echo "用法: $0 [codex|cursor|claude|opencode|copilot]"
  echo "默认: codex"
  TOOL="codex"
fi

echo "🚀 正在为 $TOOL 设置 Brainstorming + ExecPlan 规范... (项目: $(pwd))"

mkdir -p "$TEMPLATE_DIR"

########################################
# 1) 项目根 AGENTS.md（短版，追加模式）
########################################

if [[ ! -f "$ROOT_AGENTS_FILE" ]]; then
  echo "ℹ️  未检测到 $ROOT_AGENTS_FILE，将创建新文件。"
  cat > "$ROOT_AGENTS_FILE" << 'EOF'
# Project Instructions: Brainstorming + ExecPlans

## Brainstorming Ideas Into Designs (Pre‑Implementation)

Brainstorming Ideas Into Designs.
Help turn ideas into fully formed designs and specs through natural collaborative dialogue.
Start by understanding the current project context, then ask questions one at a time to refine the idea.
Once you understand what you're building, present the design and get user approval.
Do NOT invoke any implementation skill, write any code, scaffold any project, or take any implementation action until you have presented a design and the user has approved it.
This applies to EVERY project regardless of perceived simplicity.

## ExecPlans (Design → Implementation)

After the design is explicitly approved by the user, you may:
- Create or update an ExecPlan document that the coding agent can follow.
- Use the milestones, logs, and validation steps described in .agent/template/PLAN.md.
- Implement the plan autonomously without asking for "next steps" at every stage.
EOF
  echo "✅ 已创建新的项目根指令文件: $ROOT_AGENTS_FILE"
else
  if grep -q "$ROOT_MARKER" "$ROOT_AGENTS_FILE"; then
    echo "⚠️  $ROOT_AGENTS_FILE 已包含 Brainstorming 片段，跳过追加。"
  else
    echo "ℹ️  检测到已有 $ROOT_AGENTS_FILE，追加 Brainstorming + ExecPlan 片段到文件末尾。"
    cat >> "$ROOT_AGENTS_FILE" << 'EOF'

---

## Brainstorming + ExecPlans (vibe-plans)

### Brainstorming Ideas Into Designs (Pre‑Implementation)

Brainstorming Ideas Into Designs.
Help turn ideas into fully formed designs and specs through natural collaborative dialogue.
Start by understanding the current project context, then ask questions one at a time to refine the idea.
Once you understand what you're building, present the design and get user approval.
Do NOT invoke any implementation skill, write any code, scaffold any project, or take any implementation action until you have presented a design and the user has approved it.
This applies to EVERY project regardless of perceived simplicity.

### ExecPlans (Design → Implementation)

After the design is explicitly approved by the user, you may:
- Create or update an ExecPlan document that the coding agent can follow.
- Use the milestones, logs, and validation steps described in .agent/template/PLAN.md.
- Implement the plan autonomously without asking for "next steps" at every stage.
EOF
    echo "✅ 已向 $ROOT_AGENTS_FILE 追加 Brainstorming + ExecPlan 配置。"
  fi
fi

########################################
# 2) .agent/AGENTS.md（追加模式）
########################################

mkdir -p "$AGENT_DIR"

if [[ ! -f "$AGENTS_FILE" ]]; then
  echo "ℹ️  未检测到 $AGENTS_FILE，将创建新文件。"
  cat > "$AGENTS_FILE" << 'EOF'
# Repo Agents Instructions

This repository uses a two‑phase workflow:

1. Brainstorming Ideas Into Designs (pre‑implementation)
2. ExecPlans (design → implementation)

## 1. Brainstorming Ideas Into Designs (Pre‑Implementation Phase)

Brainstorming Ideas Into Designs.
Help turn ideas into fully formed designs and specs through natural collaborative dialogue.
Start by understanding the current project context, then ask questions one at a time to refine the idea.
Once you understand what you're building, present the design and get user approval.
Do NOT invoke any implementation skill, write any code, scaffold any project, or take any implementation action until you have presented a design and the user has approved it.
This applies to EVERY project regardless of perceived simplicity.

When starting ANY new task (feature, refactor, config, documentation structure, etc.) you MUST:

1. Explore the current project context (files, docs, recent changes).
2. Ask clarifying questions one at a time until the goal and constraints are clear.
3. Propose one or more design options with trade‑offs and a recommendation.
4. Present a concise design/spec and get explicit user approval before any implementation.

## 2. ExecPlans (Design → Implementation Phase)

When writing complex features or significant refactors, AFTER the design has been approved,
use an ExecPlan (as described in .agent/template/PLAN.md) from design to implementation.

ExecPlans are living documents that:
- Are fully self‑contained (no external memory beyond the working tree and the plan file itself).
- Contain milestones, validation steps, and logs of decisions.
- Allow a coding agent to continue work or restart from ONLY the ExecPlan + repo state.

Agents MUST:
- Always follow the Brainstorming phase BEFORE creating or modifying ExecPlans.
- Then follow the ExecPlan rules in .agent/template/PLAN.md _to the letter_ during implementation.
EOF
  echo "✅ 已创建新的 .agent/AGENTS.md"
else
  if grep -q "$AGENT_MARKER" "$AGENTS_FILE"; then
    echo "⚠️  $AGENTS_FILE 已包含 Repo Agents Instructions 片段，跳过追加。"
  else
    echo "ℹ️  检测到已有 $AGENTS_FILE，追加 Repo Agents Instructions 到文件末尾。"
    cat >> "$AGENTS_FILE" << 'EOF'

---

# Repo Agents Instructions

This repository uses a two‑phase workflow:

1. Brainstorming Ideas Into Designs (pre‑implementation)
2. ExecPlans (design → implementation)

## 1. Brainstorming Ideas Into Designs (Pre‑Implementation Phase)

Brainstorming Ideas Into Designs.
Help turn ideas into fully formed designs and specs through natural collaborative dialogue.
Start by understanding the current project context, then ask questions one at a time to refine the idea.
Once you understand what you're building, present the design and get user approval.
Do NOT invoke any implementation skill, write any code, scaffold any project, or take any implementation action until you have presented a design and the user has approved it.
This applies to EVERY project regardless of perceived simplicity.

When starting ANY new task (feature, refactor, config, documentation structure, etc.) you MUST:

1. Explore the current project context (files, docs, recent changes).
2. Ask clarifying questions one at a time until the goal and constraints are clear.
3. Propose one or more design options with trade‑offs and a recommendation.
4. Present a concise design/spec and get explicit user approval before any implementation.

## 2. ExecPlans (Design → Implementation Phase)

When writing complex features or significant refactors, AFTER the design has been approved,
use an ExecPlan (as described in .agent/template/PLAN.md) from design to implementation.

ExecPlans are living documents that:
- Are fully self‑contained (no external memory beyond the working tree and the plan file itself).
- Contain milestones, validation steps, and logs of decisions.
- Allow a coding agent to continue work or restart from ONLY the ExecPlan + repo state.

Agents MUST:
- Always follow the Brainstorming phase BEFORE creating or modifying ExecPlans.
- Then follow the ExecPlan rules in .agent/template/PLAN.md _to the letter_ during implementation.
EOF
    echo "✅ 已向 $AGENTS_FILE 追加 Repo Agents Instructions。"
  fi
fi

########################################
# 3) .agent/template/PLAN.md（存在则不动，只在缺失时创建）
########################################

if [[ -f "$PLAN_FILE" ]]; then
  if grep -q "$PLAN_MARKER" "$PLAN_FILE"; then
    echo "⚠️  $PLAN_FILE 已包含 ExecPlans with Brainstorming 模板，保持原样。"
  else
    echo "⚠️  检测到已有 $PLAN_FILE，但不包含预期标记。为避免破坏你现有模板，脚本不会自动修改。"
    echo "    如需使用 vibe-plans 模板，请手动合并或删除该文件后重新运行脚本。"
  fi
else
  echo "ℹ️  未检测到 $PLAN_FILE，将创建 ExecPlan 模板文件。"
  mkdir -p "$TEMPLATE_DIR"
  cat > "$PLAN_FILE" << 'EOF'
# Codex Execution Plans (ExecPlans) with Brainstorming

This document describes the requirements for an execution plan ("ExecPlan"), a design document that a coding agent can follow to deliver a working feature or system change. Treat the reader as a complete beginner to this repository: they have only the current working tree and the single ExecPlan file you provide. There is no memory of prior plans and no external context.

## 0. Brainstorming Ideas Into Designs (Required Pre‑ExecPlan Phase)

Brainstorming Ideas Into Designs.
Help turn ideas into fully formed designs and specs through natural collaborative dialogue.
Start by understanding the current project context, then ask questions one at a time to refine the idea.
Once you understand what you're building, present the design and get user approval.
Do NOT invoke any implementation skill, write any code, scaffold any project, or take any implementation action until you have presented a design and the user has approved it.
This applies to EVERY project regardless of perceived simplicity.

Before you create or modify an ExecPlan, you MUST:

1. Explore the current project context (files, docs, recent changes).
2. Ask clarifying questions one at a time until the goal and constraints are clear.
3. Propose one or more design options and get explicit user approval of the chosen design.
4. Only after approval, proceed to author or update the ExecPlan described below.

## 1. How to use ExecPlans and this PLAN.md

When authoring an executable specification (ExecPlan), follow this PLAN.md _to the letter_. If it is not in your context, refresh your memory by reading the entire PLAN.md file. Be thorough in reading (and re‑reading) source material to produce an accurate specification. When creating a spec, start from the skeleton and flesh it out as you do your research.

When implementing an executable specification (ExecPlan), do not prompt the user for "next steps"; simply proceed to the next milestone. Keep all sections up to date, add or split entries in the list at every stopping point to affirmatively state the progress made and next steps. Resolve ambiguities autonomously, and commit frequently.

When discussing an executable specification (ExecPlan), record decisions in a log in the spec for posterity; it should be unambiguously clear why any change to the specification was made. ExecPlans are living documents, and it should always be possible to restart from _only_ the ExecPlan and no other work.

When researching a design with challenging requirements or significant unknowns, use milestones to implement proof of concepts, "toy implementations", etc., that allow validating whether the user's proposal is feasible. Read the source code of libraries by finding or acquiring them, research deeply, and include prototypes to guide a fuller implementation.

## 2. ExecPlan Skeleton (to be filled by the agent)

Every ExecPlan MUST at least include the following sections:

1. Context
   - What problem are we solving?
   - What files / systems are involved?
   - What prior designs or docs are relevant?

2. Goals and Non‑Goals
   - Explicitly list what success looks like.
   - Explicitly list what is out of scope.

3. Plan / Milestones
   - A numbered list of milestones, each small enough to implement and validate.
   - For each milestone, describe:
     - The concrete change to make.
     - How you will validate it (tests, manual steps, metrics).

4. Implementation Notes
   - Key design decisions and trade‑offs.
   - Risks and mitigation strategies.
   - Any external dependencies or follow‑up work.

5. Validation
   - How to verify the whole change end‑to‑end.
   - Which tests or checks MUST pass before considering the plan done.

6. Log / Journal
   - As you work, append entries with:
     - Timestamp.
     - What milestone you worked on.
     - What changed and why.
     - Any surprises or deviations from the original plan.

## 3. Non‑Negotiable Requirements

NON‑NEGOTIABLE REQUIREMENTS:

- Every ExecPlan must be fully self‑contained.
  - Self‑contained means that in its current form it contains all information needed for an agent to understand and execute the plan, given only the current working tree and this plan file.
- ExecPlans MUST NOT reference prior, superseded specs as required reading.
- ExecPlans MUST be kept up to date as work progresses.
- ExecPlans MUST always reflect the actual state of the work and the next steps.

EOF
  echo "✅ 已创建 ExecPlan 模板文件: $PLAN_FILE"
fi

echo "🎉 完成：已为 $TOOL 初始化/追加 Brainstorming + ExecPlan 规范（基于内容判断，避免重复追加）。"
