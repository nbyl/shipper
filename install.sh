#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST_DIR="$PWD"

ENV_FILE="$DEST_DIR/.env.shipper"
SRC_AGENTS="$SCRIPT_DIR/agents"
SRC_COMMANDS="$SCRIPT_DIR/command"
DEST_ROOT="$DEST_DIR/.opencode"
DEST_AGENTS="$DEST_ROOT/agents"
DEST_COMMANDS="$DEST_ROOT/command"

# --- Validate inputs ----------------------------------------------------------
if [[ ! -f "$ENV_FILE" ]]; then
    echo "error: $ENV_FILE not found" >&2
    exit 1
fi
if [[ ! -d "$SRC_AGENTS" ]]; then
    echo "error: source directory '$SRC_AGENTS' not found" >&2
    exit 1
fi
if [[ ! -d "$SRC_COMMANDS" ]]; then
    echo "error: source directory '$SRC_COMMANDS' not found" >&2
    exit 1
fi

# --- Copy (overlay) -----------------------------------------------------------
mkdir -p "$DEST_AGENTS" "$DEST_COMMANDS"
cp -R "$SRC_AGENTS/." "$DEST_AGENTS/"
cp -R "$SRC_COMMANDS/." "$DEST_COMMANDS/"

# --- Parse .env.shipper -------------------------------------------------------
KEYS=()
VALUES=()
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
done < "$ENV_FILE"

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

echo "Installed ${#TARGET_FILES[@]} file(s) into $DEST_ROOT; substituted ${#KEYS[@]} variable(s)."
