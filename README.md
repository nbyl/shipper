# Shipper

> OpenCode slash commands and subagents that wire AI into your ticket → merge-request loop.

## What is Shipper?

Shipper is a collection of Markdown-defined [OpenCode](https://opencode.ai) slash commands and subagents that automate parts of the ticket → research → plan → implement → merge-request flow. You configure which MCP tools it should talk to (your ticket system, your docs source, your model) in a single `.env.shipper` file; an install script copies the command/agent sources into the local `.opencode/` and substitutes those values in.

For the longer vision, the conceptual pipeline, and roadmap items, see [`docs/overview.md`](docs/overview.md).

## Prerequisites

- [OpenCode](https://opencode.ai) installed locally.
- Bash, `sed`, and standard POSIX tooling (the install script supports both GNU and BSD `sed`).
- An MCP server for your ticket system (e.g. GitHub).
- For `/shipper:merge-request`: an MCP server for your code-hosting platform (set via `REPOSITORY_TOOL`, e.g. `github`, `gitlab`).
- If you opt into beta commands: an MCP-accessible documentation tool such as `context7` for `/shipper:research`.

## Installation

1. Clone this repository.
2. Copy the example environment file and fill in your values:
   ```bash
   cp .env.shipper.example .env.shipper
   ```
   Set at least:
   - `TICKET_TOOL` — MCP tool name for your ticket system (e.g. `github`).
   - `REPOSITORY_TOOL` — MCP tool name for your code-hosting platform (e.g. `github`).

   If you want to install beta commands and agents, also set:
   - `SHIPPER_INCLUDE_BETA=true` — opt in to beta items (default: stable only). Truthy values: `1`, `true`, `yes`, `on` (case-insensitive).
   - `RESEARCH_MODEL` — model identifier used by the research subagent (beta).
   - `RESEARCH_TOOL` — MCP tool name for documentation lookup, e.g. `context7` (beta).
3. From the directory that should receive the generated `.opencode/` folder, run:
   ```bash
   ./install.sh
   ```
   The script copies stable commands and agents from `command/stable/` and `agents/stable/` into `.opencode/command/` and `.opencode/agents/` (flattened, so OpenCode resolves slash-command names correctly), and substitutes every `${VAR}` / `$VAR` reference using the values in `.env.shipper`. Beta items from `command/beta/` and `agents/beta/` are included only when `SHIPPER_INCLUDE_BETA` is truthy.

> **Note:** `install.sh` overwrites stable files in `.opencode/agents/` and `.opencode/command/` on each run. Treat those as build artifacts; edit the source Markdown at the repo root and re-run the script. Toggling `SHIPPER_INCLUDE_BETA` from on to off does **not** remove previously installed beta files — delete `.opencode/agents/` and `.opencode/command/` manually and re-run if you want a clean stable-only install.

## Available commands

The commands below are present on `main` today. Stable commands install by default; beta commands install only when `SHIPPER_INCLUDE_BETA=true` is set in `.env.shipper`.

### Stable

| Command | What it does | Caveats |
|---|---|---|
| `/shipper:refine <ticket-id>` | Refines a ticket into a Description + Acceptance Criteria user story, then saves it back to the ticket system after your approval. | Uses `TICKET_TOOL`. |
| `/shipper:plan <ticket-id>` | Checks out `main`, pulls, creates a feature branch from the ticket, and sets the ticket to "In Progress" before planning. | Uses `TICKET_TOOL`. |
| `/shipper:merge-request` | Runs local verification, commits, pushes, opens or updates a merge request, and moves the ticket to "In Review". | Uses `TICKET_TOOL`, `REPOSITORY_TOOL`. |

### Beta — opt in via `SHIPPER_INCLUDE_BETA=true`

| Command | What it does | Caveats |
|---|---|---|
| `/shipper:research <ticket-id>` | Loads the ticket, has a research subagent collect relevant documentation, and posts a summary back as a ticket comment. | Uses `TICKET_TOOL`, `RESEARCH_TOOL`, `RESEARCH_MODEL`. |

Additional commands are planned — see [`docs/overview.md`](docs/overview.md) for the full vision and roadmap.

## Configuration reference

All variables live in `.env.shipper` (gitignored) in `KEY=value` format. `#` comments and optional surrounding quotes are supported.

| Variable | Used by | Description |
|---|---|---|
| `TICKET_TOOL` | All commands | MCP tool name for the ticket system. |
| `REPOSITORY_TOOL` | `/shipper:merge-request` | MCP tool name for the code-hosting platform. |
| `SHIPPER_INCLUDE_BETA` | `install.sh` | Truthy value (`1`, `true`, `yes`, `on`, case-insensitive) installs beta commands/agents. Default: stable only. |
| `RESEARCH_MODEL` | `/shipper:research` (beta) | Model identifier the research subagent runs against. |
| `RESEARCH_TOOL` | `/shipper:research` (beta) | MCP tool name used to look up documentation. |

Add new variables to `.env.shipper` and reference them as `$VAR` (or `${VAR}`) anywhere in `agents/{stable,beta}/*.md` or `command/{stable,beta}/*.md` — `install.sh` will substitute them on the next run.

## Further reading

- [`docs/overview.md`](docs/overview.md) — project vision, pipeline description, and roadmap.
- [`AGENTS.md`](AGENTS.md) — repo conventions for contributors.

## License

Apache License 2.0. See [`LICENSE`](LICENSE).
