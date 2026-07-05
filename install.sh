#!/bin/bash
# lark-cli-onboarding installer
# One command to give Claude Code the ability to drive Lark/Feishu via the CLI.
#
#   git clone <this-repo> && cd lark-cli-onboarding && ./install.sh
#   # or:  curl -fsSL <raw-url>/install.sh | bash
#
# What it AUTOMATES:
#   1. Installs the official @larksuite/cli (latest) from npm
#   2. Installs the `lark-cli-setup` skill so Claude Code can guide/run the setup
#   3. Installs the token auto-refresh helper (lark-cli-ensure-auth)
#   4. Wires a Claude Code SessionStart hook so the USER token stays fresh (no browser pop)
#
# What it CANNOT automate (these need a human — same as any Lark tool):
#   - Getting a Feishu App ID / App Secret (open.feishu.cn) and enabling long-lived refresh_token
#   - The first browser OAuth approval:  lark-cli config init --new  &&  lark-cli auth login --recommend

set -euo pipefail

# When run via `curl | bash`, BASH_SOURCE[0] points at nothing on disk, so we
# can't resolve our own directory to grab the skill files. Detect that case
# and fetch the repo into a temp dir instead.
if [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "${BASH_SOURCE[0]}" ]; then
  SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
  command -v git >/dev/null 2>&1 || { echo "git is required to install via curl | bash" >&2; exit 1; }
  SRC_DIR="$(mktemp -d)"
  trap 'rm -rf "$SRC_DIR"' EXIT
  printf '\033[1;36m▶\033[0m %s\n' "Fetching lark-cli-onboarding sources …"
  git clone --depth 1 -q https://github.com/nixthinh-bit/lark-cli-onboarding.git "$SRC_DIR"
fi
SKILL_SRC="$SRC_DIR/skills/lark-cli-setup"
SKILL_DST="$HOME/.claude/skills/lark-cli-setup"
BIN_DST="$HOME/.local/bin"
ENSURE="$BIN_DST/lark-cli-ensure-auth"
SETTINGS="$HOME/.claude/settings.json"

say()  { printf '\033[1;36m▶\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32m✓\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!\033[0m %s\n' "$*"; }

# --- 0. prerequisites ----------------------------------------------------------
command -v node >/dev/null 2>&1 || { warn "Node.js is required (>=18). Install it first: https://nodejs.org"; exit 1; }
NODE_MAJOR="$(node -p 'process.versions.node.split(".")[0]')"
[ "$NODE_MAJOR" -ge 18 ] || { warn "Node.js >= 18 required (found $(node -v))."; exit 1; }
command -v npm >/dev/null 2>&1  || { warn "npm not found."; exit 1; }
command -v python3 >/dev/null 2>&1 || { warn "python3 is required (used to merge settings + parse JSON)."; exit 1; }

# --- 1. install / update the official CLI --------------------------------------
say "Installing @larksuite/cli (latest) …"
npm install -g @larksuite/cli@latest >/dev/null 2>&1 || npm install -g @larksuite/cli@latest
# resolve where npm put the binary
CLI="$(command -v lark-cli || echo "$(npm config get prefix)/bin/lark-cli")"
ok "lark-cli: $("$CLI" --version 2>/dev/null || echo 'installed')"

# --- 2. install the skill ------------------------------------------------------
say "Installing the lark-cli-setup skill …"
mkdir -p "$SKILL_DST"
cp -R "$SKILL_SRC/." "$SKILL_DST/"
ok "Skill → $SKILL_DST"

# --- 3. install the token auto-refresh helper ----------------------------------
say "Installing token auto-refresh helper …"
mkdir -p "$BIN_DST"
cp "$SKILL_SRC/scripts/lark-cli-ensure-auth" "$ENSURE"
chmod +x "$ENSURE"
ok "Helper → $ENSURE"

# make sure ~/.local/bin is on PATH for future shells
case ":$PATH:" in
  *":$BIN_DST:"*) : ;;
  *)
    RC="$HOME/.zshrc"; [ -n "${BASH_VERSION:-}" ] && RC="$HOME/.bashrc"
    if ! grep -qs '.local/bin' "$RC" 2>/dev/null; then
      printf '\nexport PATH="$HOME/.local/bin:$PATH"\n' >> "$RC"
      warn "Added ~/.local/bin to PATH in $RC — open a new terminal (or 'source $RC')."
    fi ;;
esac

# --- 4. wire the SessionStart hook (idempotent, uses absolute path) -------------
say "Wiring the Claude Code SessionStart auto-refresh hook …"
mkdir -p "$(dirname "$SETTINGS")"
[ -f "$SETTINGS" ] || echo '{}' > "$SETTINGS"
ENSURE="$ENSURE" python3 - "$SETTINGS" <<'PY'
import json, os, sys
path = sys.argv[1]
ensure = os.environ["ENSURE"]
cmd = f'"{ensure}" --quiet'
with open(path) as f:
    try: data = json.load(f)
    except Exception: data = {}
hooks = data.setdefault("hooks", {})
ss = hooks.setdefault("SessionStart", [])
# already present? (match on our command)
present = any(
    h.get("type") == "command" and "lark-cli-ensure-auth" in h.get("command", "")
    for grp in ss for h in grp.get("hooks", [])
)
if not present:
    ss.append({"hooks": [{"type": "command", "command": cmd}]})
with open(path, "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write("\n")
print("hook added" if not present else "hook already present")
PY
ok "SessionStart hook ready (runs '$ENSURE --quiet' — silent, never opens a browser)."

# --- 5. status + honest next steps ---------------------------------------------
echo
if "$CLI" auth status >/dev/null 2>&1 && \
   "$CLI" auth status 2>/dev/null | python3 -c 'import sys,json;u=json.load(sys.stdin).get("identities",{}).get("user",{});exit(0 if u.get("tokenStatus") else 1)' 2>/dev/null; then
  ok "Existing Lark auth detected — you're ready. Try: lark-cli contact +get-user --as user"
else
  warn "No Lark auth yet. Finish the 2 human steps (once):"
  echo  "    1) Create a Feishu app + App ID/Secret at https://open.feishu.cn (enable long-lived refresh_token)"
  echo  "    2) lark-cli config init --new   &&   lark-cli auth login --recommend"
  echo  "    …or just open Claude Code and say: \"kết nối giúp tôi lark-cli\" (the skill will walk you through it)."
fi
echo
ok "Done. Restart Claude Code so it picks up the new skill + hook."
