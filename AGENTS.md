# AGENTS.md

Shipper is a template repo of OpenCode slash commands and subagents — not an application. There is no build, test, typecheck, or lint pipeline. Most "work" here is editing Markdown.

## Source vs. generated

- Source of truth: `agents/{stable,beta}/*.md` and `command/{stable,beta}/*.md` at repo root. The `stable/` and `beta/` subdirs encode each item's release tier; `install.sh` always installs stable items, and optionally installs beta items when `SHIPPER_INCLUDE_BETA` is truthy.
- `install.sh` flattens stable and beta into `.opencode/agents/` and `.opencode/command/` (no `stable/`/`beta/` subdirs in the destination) so OpenCode resolves slash-command names normally.
- `agents/stable/.gitkeep` keeps the empty stable-agents directory tracked. `install.sh` strips any `.gitkeep` from the destination after copying.
- `.opencode/` and `.env.shipper` are **gitignored**. Treat `.opencode/agents/` and `.opencode/command/` as build artifacts — `install.sh` overwrites them. Never edit files there; edit the repo-root sources and re-run `install.sh`.
- The local `.opencode/` may be stale relative to current sources (it reflects whenever `install.sh` was last run). Do not infer behavior from it.

## install.sh

- Run from the directory that should receive `.opencode/` (`DEST_DIR="$PWD"`). For local dev on Shipper itself, run it from this repo root.
- Requires a `.env.shipper` in the working directory. Format is `KEY=value`, `#` comments allowed, optional surrounding quotes are stripped.
- Parses `.env.shipper` first, copies stable items unconditionally, copies beta items only when `SHIPPER_INCLUDE_BETA` is truthy (case-insensitive match against `1|true|yes|on`).
- Overlays on each run — it does **not** wipe `.opencode/agents/` or `.opencode/command/` before copying. Toggling `SHIPPER_INCLUDE_BETA` from on to off therefore leaves previously installed beta files behind; remove them manually if you want a clean stable-only install.
- Substitutes both `${KEY}` and `$KEY` forms in every file under `.opencode/agents/` and `.opencode/command/` via `sed`. Detects GNU vs BSD `sed` automatically.
- Current variables in use: `TICKET_TOOL`, `REPOSITORY_TOOL`, `RESEARCH_MODEL`, `RESEARCH_TOOL`, `SHIPPER_INCLUDE_BETA`. Add new ones to `.env.shipper` and reference them as `$VAR` in source markdown.

## File / command conventions

- Slash-command namespace uses a literal colon in the filename: `command/stable/shipper:research.md` becomes `/shipper:research`. Keep the colon; do not rename to `shipper-research.md` or a subdirectory.
- Subagents live in `agents/{stable,beta}/`, slash commands in `command/{stable,beta}/`. They share filenames when paired, and a command and its matching subagent should always live in the same tier.
- Frontmatter shape used here (see `agents/beta/shipper:research.md`):
  - subagent: `mode: subagent`, `model: $RESEARCH_MODEL`, `temperature`, `permission:` block (`read`, `webfetch`, `websearch`).
  - command: `agent: build` plus `description`. Body uses `$1` for the first positional arg.

## Stable vs. beta tiers

- Place new commands and agents under `*/stable/` only when they are reliable enough to install by default; otherwise put them in `*/beta/`.
- Promote a beta item to stable with `git mv command/beta/<file>.md command/stable/<file>.md` (and matching subagent in `agents/`). Use a `feat:` commit since the change makes the item part of the default install surface.
- When a stable command needs to ship its own subagent, drop the `.gitkeep` from `agents/stable/` only when there is at least one real file alongside it.

## Commits

- Conventional Commits are enforced via a GitHub Action on PR title (`.github/workflows/pr-title.yml`), not on individual commit messages. This lets contributors commit freely while keeping PR history clean.
- Other pre-commit hooks are generic hygiene (trailing whitespace, YAML/JSON checks, etc.). Several are Python-oriented (`double-quote-string-fixer`, `fix-encoding-pragma`) but harmless on this repo's content.

## Gotchas

- End-user docs live in `README.md` at repo root; the full vision, pipeline description, and roadmap live in `docs/overview.md`.
- Stable commands (`/shipper:refine`, `/shipper:plan`, `/shipper:merge-request`) install by default and all honor `$TICKET_TOOL`; `/shipper:merge-request` additionally uses `$REPOSITORY_TOOL`. The beta command `/shipper:research` (and its subagent) install only when `SHIPPER_INCLUDE_BETA` is truthy in `.env.shipper`. `/shipper:ship` and `/shipper:fix-review-issues` are mentioned in `docs/overview.md` but not implemented yet.
- `.opencode/package.json` pins `@opencode-ai/plugin` but no plugin source exists yet. Ignore unless adding one.
