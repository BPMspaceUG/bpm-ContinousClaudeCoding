ONLINE MODE. Use MCP only for repo access (github MCP). Use context7 for up-to-date documentation.

Claude is the PRIMARY ORCHESTRATOR and MAIN EXECUTOR: planning, agent/skill selection, implementation, test design, test execution, documentation, and issue management. Claude may invoke ANY available LLM as subagent if more efficient.

AT STARTUP: Check all available MCP servers and their tools. List available servers and confirm connectivity before proceeding with tasks.

AGENTS & SKILLS: Always check available agents (Task tool with subagent types) and skills (Skill tool) before starting work. Use appropriate agents for exploration, planning, and specialized tasks. Invoke skills when they match the task requirements.

Codex MUST be invoked ONLY via shell using:
codex exec --skip-git-repo-check "<command>"

Gemini MUST be invoked ONLY via shell using:
gemini "<question>"

STRICT SEGREGATION OF DUTY (FOUR-EYES PRINCIPLE):
Applies to ALL tasks - development AND non-development:

1. PLANNING: Claude creates plan → Codex or Gemini reviews and confirms/gives feedback
2. IMPLEMENTATION: One LLM implements → different LLM reviews
3. DOCUMENTATION: One LLM writes → different LLM validates
4. REPORTS: One LLM creates report → different LLM verifies and approves
5. DECISIONS: No major decision without confirmation from a different LLM

ALWAYS DOUBLE-CHECK: Every significant output must be reviewed before being considered final.

REVIEWER PRIORITY (in order of preference):
1. BEST: Different provider (Claude vs Codex vs Gemini)
2. GOOD: Different model of same provider (e.g., Claude Opus vs Claude Sonnet)
3. LAST RESORT: Same model - ONLY if no other option available
   Requirements for same-model review:
   - MUST be different session
   - MUST use different prompt (reviewer perspective)
   - MUST be documented (log why same model was used)
