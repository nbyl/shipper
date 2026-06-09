#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST_DIR="$PWD"

ENV_FILE="$DEST_DIR/.env.shipper"
SRC_AGENTS_STABLE="$SCRIPT_DIR/agents/stable"
SRC_AGENTS_BETA="$SCRIPT_DIR/agents/beta"
SRC_COMMANDS_STABLE="$SCRIPT_DIR/command/stable"
SRC_COMMANDS_BETA="$SCRIPT_DIR/command/beta"
DEST_ROOT="$DEST_DIR/.opencode"
DEST_AGENTS="$DEST_ROOT/agents"
DEST_COMMANDS="$DEST_ROOT/command"

# --- Validate inputs ----------------------------------------------------------
if [[ ! -f "$ENV_FILE" ]]; then
    echo "error: $ENV_FILE not found" >&2
    exit 1
fi
for d in "$SRC_AGENTS_STABLE" "$SRC_AGENTS_BETA" "$SRC_COMMANDS_STABLE" "$SRC_COMMANDS_BETA"; do
    if [[ ! -d "$d" ]]; then
        echo "error: source directory '$d' not found" >&2
        exit 1
    fi
done

# --- Parse .env.shipper -------------------------------------------------------
KEYS=()
VALUES=()
INCLUDE_BETA=0
while IFS= read -r line || [[ -n "$line" ]]; do
    # strip leading/trailing whitespace
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    [[ -z "$line" ]] && continue
    [[ "$line" == \#* ]] && continue
    if [[ "$line" != *=* ]]; then
        echo "warning: skipping malformed line in $ENV_FILE: $line" >&2
        continue
    fi
    key="${line%%=*}"
    value="${line#*=}"
    # strip surrounding quotes from value if present
    if [[ "$value" == \"*\" || "$value" == \'*\' ]]; then
        value="${value:1:${#value}-2}"
    fi
    KEYS+=("$key")
    VALUES+=("$value")
    # Detect beta opt-in (case-insensitive: 1, true, yes, on)
    if [[ "$key" == "SHIPPER_INCLUDE_BETA" ]]; then
        case "$(printf '%s' "$value" | tr '[:upper:]' '[:lower:]')" in
            1|true|yes|on) INCLUDE_BETA=1 ;;
            *) INCLUDE_BETA=0 ;;
        esac
    fi
done < "$ENV_FILE"

# --- Copy (overlay) -----------------------------------------------------------
# install.sh overlays on each run: it never wipes .opencode/agents/ or
# .opencode/command/ before copying. Toggling SHIPPER_INCLUDE_BETA off after a
# beta install will NOT remove previously installed beta files; remove
# .opencode/ manually or re-run after deleting stale files.
mkdir -p "$DEST_AGENTS" "$DEST_COMMANDS"

cp -R "$SRC_AGENTS_STABLE/." "$DEST_AGENTS/"
cp -R "$SRC_COMMANDS_STABLE/." "$DEST_COMMANDS/"

if [[ "$INCLUDE_BETA" -eq 1 ]]; then
    cp -R "$SRC_AGENTS_BETA/." "$DEST_AGENTS/"
    cp -R "$SRC_COMMANDS_BETA/." "$DEST_COMMANDS/"
fi

# Remove any .gitkeep placeholders carried over from empty source dirs.
find "$DEST_AGENTS" "$DEST_COMMANDS" -name '.gitkeep' -type f -delete

# Count installed files (post-cleanup) for the summary message.
STABLE_COUNT=$(find "$SRC_AGENTS_STABLE" "$SRC_COMMANDS_STABLE" -type f ! -name '.gitkeep' | wc -l | tr -d ' ')
BETA_COUNT=0
if [[ "$INCLUDE_BETA" -eq 1 ]]; then
    BETA_COUNT=$(find "$SRC_AGENTS_BETA" "$SRC_COMMANDS_BETA" -type f ! -name '.gitkeep' | wc -l | tr -d ' ')
fi

# --- Detect sed flavor --------------------------------------------------------
if sed --version >/dev/null 2>&1; then
    SED_INPLACE=(sed -i)
else
    SED_INPLACE=(sed -i '')
fi

# Escape replacement string for sed (escapes \, |, &)
sed_escape_replacement() {
    local s="$1"
    s="${s//\\/\\\\}"
    s="${s//|/\\|}"
    s="${s//&/\\&}"
    printf '%s' "$s"
}

# --- Collect target files -----------------------------------------------------
TARGET_FILES=()
while IFS= read -r -d '' f; do
    TARGET_FILES+=("$f")
done < <(find "$DEST_AGENTS" "$DEST_COMMANDS" -type f -print0)

# --- Substitute variables -----------------------------------------------------
for ((i = 0; i < ${#KEYS[@]}; i++)); do
    key="${KEYS[$i]}"
    value="${VALUES[$i]}"
    repl="$(sed_escape_replacement "$value")"
    for f in "${TARGET_FILES[@]}"; do
        "${SED_INPLACE[@]}" -e "s|\${${key}}|${repl}|g" -e "s|\$${key}|${repl}|g" "$f"
    done
done

if [[ "$INCLUDE_BETA" -eq 1 ]]; then
    echo "Installed ${#TARGET_FILES[@]} file(s) into $DEST_ROOT (stable: $STABLE_COUNT, beta: $BETA_COUNT); substituted ${#KEYS[@]} variable(s)."
else
    echo "Installed ${#TARGET_FILES[@]} file(s) into $DEST_ROOT (stable only); substituted ${#KEYS[@]} variable(s). Set SHIPPER_INCLUDE_BETA=true in .env.shipper to include beta items."
fi
