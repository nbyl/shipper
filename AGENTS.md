# AGENTS.md

Shipper is a template repo of OpenCode slash commands and subagents — not an application. There is no build, test, typecheck, or lint pipeline. Most "work" here is editing Markdown.

## Source vs. generated

- Source of truth: `agents/*.md` and `command/*.md` at repo root.
- `.opencode/` and `.env.shipper` are **gitignored**. Treat `.opencode/agents/` and `.opencode/command/` as build artifacts — `install.sh` overwrites them. Never edit files there; edit the repo-root sources and re-run `install.sh`.
- The local `.opencode/` may be stale relative to current sources (it reflects whenever `install.sh` was last run). Do not infer behavior from it.

## install.sh

- Run from the directory that should receive `.opencode/` (`DEST_DIR="$PWD"`). For local dev on Shipper itself, run it from this repo root.
- Requires a `.env.shipper` in the working directory. Format is `KEY=value`, `#` comments allowed, optional surrounding quotes are stripped.
- Substitutes both `${KEY}` and `$KEY` forms in every file under `.opencode/agents/` and `.opencode/command/` via `sed`. Detects GNU vs BSD `sed` automatically.
- Current variables in use: `TICKET_TOOL`, `REPOSITORY_TOOL`, `RESEARCH_MODEL`, `RESEARCH_TOOL`. Add new ones to `.env.shipper` and reference them as `$VAR` in source markdown.

## File / command conventions

- Slash-command namespace uses a literal colon in the filename: `command/shipper:research.md` becomes `/shipper:research`. Keep the colon; do not rename to `shipper-research.md` or a subdirectory.
- Subagents live in `agents/`, slash commands in `command/`. They share filenames when paired.
- Frontmatter shape used here (see `agents/shipper:research.md`):
  - subagent: `mode: subagent`, `model: $RESEARCH_MODEL`, `temperature`, `permission:` block (`read`, `webfetch`, `websearch`).
  - command: `agent: build` plus `description`. Body uses `$1` for the first positional arg.

## Commits

- `.pre-commit-config.yaml` installs `commitizen` on the `commit-msg` stage. Commit messages must follow Conventional Commits (`feat:`, `docs:`, `fix:`, …). Existing history follows this.
- Other pre-commit hooks are generic hygiene (trailing whitespace, YAML/JSON checks, etc.). Several are Python-oriented (`double-quote-string-fixer`, `fix-encoding-pragma`) but harmless on this repo's content.

## Gotchas

- End-user docs live in `README.md` at repo root; the full vision, pipeline description, and roadmap live in `docs/overview.md`.
- All four commands in `command/` honor `$TICKET_TOOL`; `/shipper:merge-request` additionally uses `$REPOSITORY_TOOL` for the code-hosting platform. `/shipper:ship` and `/shipper:fix-review-issues` are mentioned in `docs/overview.md` but not implemented yet.
- `.opencode/package.json` pins `@opencode-ai/plugin` but no plugin source exists yet. Ignore unless adding one.
