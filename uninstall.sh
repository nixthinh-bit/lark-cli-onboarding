#!/bin/bash
# lark-cli-onboarding uninstaller — reverses install.sh.
# Leaves your Lark credentials (~/.lark-cli/) and the npm package untouched by default.

set -euo pipefail
SKILL_DST="$HOME/.claude/skills/lark-cli-setup"
ENSURE="$HOME/.local/bin/lark-cli-ensure-auth"
SETTINGS="$HOME/.claude/settings.json"

echo "Removing skill…";   rm -rf "$SKILL_DST" && echo "  removed $SKILL_DST" || true
echo "Removing helper…";  rm -f  "$ENSURE"    && echo "  removed $ENSURE"    || true

if [ -f "$SETTINGS" ]; then
  echo "Removing SessionStart hook…"
  python3 - "$SETTINGS" <<'PY'
import json, sys
path = sys.argv[1]
with open(path) as f: data = json.load(f)
ss = data.get("hooks", {}).get("SessionStart", [])
for grp in ss:
    grp["hooks"] = [h for h in grp.get("hooks", []) if "lark-cli-ensure-auth" not in h.get("command","")]
data.get("hooks", {})["SessionStart"] = [g for g in ss if g.get("hooks")]
if not data["hooks"]["SessionStart"]:
    data["hooks"].pop("SessionStart", None)
with open(path, "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False); f.write("\n")
print("  hook removed")
PY
fi

echo
echo "Kept: ~/.lark-cli/ (credentials) and the @larksuite/cli npm package."
echo "To remove those too:  rm -rf ~/.lark-cli  &&  npm uninstall -g @larksuite/cli"
