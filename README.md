# vibe-plans

## use

This script is idempotent: if AGENTS.md or .agent/PLANS.md already exist, they will be left unchanged.

**default (Codex)**
```sh
curl -fsSL https://raw.githubusercontent.com/section9-lab/vibe-plans/main/execplan-setup.sh | bash
```

**Claude Code**
```sh
curl -fsSL https://raw.githubusercontent.com/section9-lab/vibe-plans/main/execplan-setup.sh | bash -s -- claude
```

**Codex**
```sh
curl -fsSL https://raw.githubusercontent.com/section9-lab/vibe-plans/main/execplan-setup.sh | bash -s -- codex
```

**OpenCode**
```sh
curl -fsSL https://raw.githubusercontent.com/section9-lab/vibe-plans/main/execplan-setup.sh | bash -s -- opencode
```

**Copilot-CLI**
```sh
curl -fsSL https://raw.githubusercontent.com/section9-lab/vibe-plans/main/execplan-setup.sh | bash -s -- copilot
```

> **Note for Cursor users**: Cursor can use either Claude or Codex as the underlying engine. Choose the corresponding command above based on which engine you have selected in Cursor's settings.

---
## ref

[exec_plans](https://developers.openai.com/cookbook/articles/codex_exec_plans)

LICENSE:
MIT