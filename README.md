# Shipper

> OpenCode slash commands and subagents that wire AI into your ticket → merge-request loop.

## What is Shipper?

Shipper is a collection of Markdown-defined [OpenCode](https://opencode.ai) slash commands and subagents that automate parts of the ticket → research → plan → implement → merge-request flow. You configure which MCP tools it should talk to (your ticket system, your docs source, your model) in a single `.env.shipper` file; an install script copies the command/agent sources into the local `.opencode/` and substitutes those values in.

For the longer vision, the conceptual pipeline, and roadmap items, see [`docs/overview.md`](docs/overview.md).

## Prerequisites

- [OpenCode](https://opencode.ai) installed locally.
- Bash, `sed`, and standard POSIX tooling (the install script supports both GNU and BSD `sed`).
- An MCP server for your ticket system (e.g. GitHub).
- For `/shipper:research`: an MCP-accessible documentation tool such as `context7`.
- For `/shipper:plan`: a Linear MCP server (this command is currently hardcoded to Linear — see [Available commands](#available-commands)).
- For `/shipper:merge-request`: a GitLab remote and a Linear MCP server (also currently hardcoded — see below).

## Installation

1. Clone this repository.
2. Copy the example environment file and fill in your values:
   ```bash
   cp .env.shipper.example .env.shipper
   ```
   Set at least:
   - `TICKET_TOOL` — MCP tool name for your ticket system (e.g. `github`).
   - `RESEARCH_MODEL` — model identifier used by the research subagent.
   - `RESEARCH_TOOL` — MCP tool name for documentation lookup (e.g. `context7`).
3. From the directory that should receive the generated `.opencode/` folder, run:
   ```bash
   ./install.sh
   ```
   The script copies `agents/` and `command/` into `.opencode/agents/` and `.opencode/command/` and substitutes every `${VAR}` / `$VAR` reference using the values in `.env.shipper`.

> **Note:** `install.sh` overwrites `.opencode/agents/` and `.opencode/command/` each run. Treat those as build artifacts; edit the source Markdown at the repo root and re-run the script.

## Available commands

The four commands below are present on `main` today. `/shipper:plan` and `/shipper:merge-request` still reference specific tools rather than honoring `TICKET_TOOL`; adapting them to be tool-agnostic is on the roadmap.

| Command | What it does | Caveats |
|---|---|---|
| `/shipper:research <ticket-id>` | Loads the ticket, has a research subagent collect relevant documentation, and posts a summary back as a ticket comment. | Uses `TICKET_TOOL`, `RESEARCH_TOOL`, `RESEARCH_MODEL`. |
| `/shipper:refine <ticket-id>` | Refines a ticket into a Description + Acceptance Criteria user story, then saves it back to the ticket system after your approval. | Uses `TICKET_TOOL`. |
| `/shipper:plan <ticket-id>` | Checks out `main`, pulls, creates a feature branch from the ticket, and sets the ticket to "In Progress" before planning. | **Currently hardcoded to Linear** — does not honor `TICKET_TOOL`. |
| `/shipper:merge-request` | Runs local verification, commits, pushes, opens or updates a merge request, and moves the ticket to "In Review". | **Currently hardcoded to GitLab and Linear** — does not honor `TICKET_TOOL`. |

Additional commands are planned — see [`docs/overview.md`](docs/overview.md) for the full vision and roadmap.

## Configuration reference

All variables live in `.env.shipper` (gitignored) in `KEY=value` format. `#` comments and optional surrounding quotes are supported.

| Variable | Used by | Description |
|---|---|---|
| `TICKET_TOOL` | `/shipper:research`, `/shipper:refine` | MCP tool name for the ticket system. |
| `RESEARCH_MODEL` | `/shipper:research` (subagent) | Model identifier the research subagent runs against. |
| `RESEARCH_TOOL` | `/shipper:research` (subagent) | MCP tool name used to look up documentation. |

Add new variables to `.env.shipper` and reference them as `$VAR` (or `${VAR}`) anywhere in `agents/*.md` or `command/*.md` — `install.sh` will substitute them on the next run.

## Further reading

- [`docs/overview.md`](docs/overview.md) — project vision, pipeline description, and roadmap.
- [`AGENTS.md`](AGENTS.md) — repo conventions for contributors.

## License

Apache License 2.0. See [`LICENSE`](LICENSE).
