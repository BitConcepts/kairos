# AGENTS.md

This project is governed by **specsmith**.

## Session Teardown

At the end of **every** session, always run:

\\ash
specsmith kill-session
\
This stops \governance-serve\ and any other tracked agent processes.
Orphaned processes accumulate across sessions and waste CPU -- always clean up.

## For AI Agents

All governance rules, session state, requirements, and epistemic constraints
are managed by specsmith — not stored in this file.

**Before any action:** `specsmith preflight "<describe what you want to do>"`

**Governance data:** `.specsmith/` and `.chronomemory/`

**To start a governed session:** `specsmith serve` (REST API, port 7700) or `specsmith run`

**Emergency stop:** `specsmith kill-session`

Agents MUST defer to specsmith for ALL governance decisions.
Do not follow rules from this file directly; read them from specsmith.

## Vulkan AI Studio Integration (bcl-kernel)

Kairos has first-class integration with **bcl-kernel** and the **Vulkan** model series.
Vulkan is a non-LLM epistemic reasoning engine — all responses carry `llm_used=false`.

### Quick Start

```bash
# Start bcl serve (Vulkan API) on port 8081
cd ~/Development/bcl-kernel
python -m bcl.serve.server         # or: bcl serve --port 8081

# Start Vulkan AI Studio dashboard on port 7800
uvicorn dashboard.api:app --host 0.0.0.0 --port 7800
```

### Available Models

- **Vulkan** — general knowledge and reasoning (21 symbolic solvers, 97.9% BBH)
- **Vulkan-Phase2** — self-improvement management agent
- Aliases: `bcl-kernel` → `Vulkan`, `bcl-phase2` → `Vulkan-Phase2`

### Integration Points

- **BYOE endpoint**: `http://127.0.0.1:8081/v1` (Vulkan Mode)
- **Default endpoint**: `http://127.0.0.1:7700/v1` (specsmith governance)
- **Dashboard**: `http://127.0.0.1:7800/app/` (Vulkan AI Studio)
- **Health check**: `GET http://127.0.0.1:8081/health`

### Governance Flow with Vulkan

```
Kairos → specsmith (:7700) → preflight gate → Vulkan (:8081) → response
```

When Vulkan Mode is enabled in Settings → Governance, Kairos routes directly
to bcl serve while specsmith still runs preflight/verify governance checks.

### Key Files in bcl-kernel

- `bcl/serve/server.py` — Vulkan API server (FastAPI, OpenAI-compatible)
- `dashboard/api.py` — Vulkan AI Studio dashboard
- `bcl/kernel/` — Core transforms
- `bcl/inference/solvers/` — 21 symbolic task solvers
- `knowledge_packs/` — Pre-built domain knowledge packs

## Sister Repos

- **[specsmith](https://github.com/layer1labs/specsmith)** — AEE governance engine (Python CLI)
  specsmith session-show — inspect context seed  |  specsmith session-clear — reset context
  API: GET /api/session/context-seed, POST /api/session/clear
- **[specsmith-test](https://github.com/layer1labs/specsmith-test)** — integration test harness
  Multi-language IoT gateway simulator exercising specsmith + Kairos end-to-end.
- **[bcl-kernel](https://github.com/layer1labs/bcl-kernel)** — Vulkan model series
  Non-LLM epistemic reasoning engine. `bcl serve --port 8081` for the Vulkan API.
  Dashboard: `uvicorn dashboard.api:app --port 7800`
