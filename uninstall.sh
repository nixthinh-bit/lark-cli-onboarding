#!/bin/bash
# lark-cli-onboarding uninstaller — reverses install.sh.
# Leaves your Lark credentials (~/.lark-cli/) and the npm package untouched by default.

set -euo pipefail
SKILL_DST="$HOME/.claude/skills/lark-cli-setup"
ENSURE="$HOME/.local/bin/lark-cli-ensure-auth"
UPDATER="$HOME/.local/bin/lark-cli-check-update"
LIB="$HOME/.local/bin/_lark_cli_lib.sh"
SETTINGS="$HOME/.claude/settings.json"

echo "Removing skill…";   rm -rf "$SKILL_DST" && echo "  removed $SKILL_DST" || true
echo "Removing helper…";  rm -f  "$ENSURE"    && echo "  removed $ENSURE"    || true
echo "Removing updater…"; rm -f  "$UPDATER"   && echo "  removed $UPDATER"   || true
echo "Removing shared lib…"; rm -f "$LIB"     && echo "  removed $LIB"       || true

if [ -f "$SETTINGS" ]; then
  echo "Removing SessionStart hooks…"
  python3 - "$SETTINGS" <<'PY'
import json, sys
path = sys.argv[1]
with open(path) as f: data = json.load(f)
hooks = data.get("hooks")
if hooks:
    ss = hooks.get("SessionStart", [])
    markers = ("lark-cli-ensure-auth", "lark-cli-check-update")
    for grp in ss:
        grp["hooks"] = [h for h in grp.get("hooks", []) if not any(m in h.get("command", "") for m in markers)]
    ss = [g for g in ss if g.get("hooks")]
    if ss:
        hooks["SessionStart"] = ss
    else:
        hooks.pop("SessionStart", None)
    if not hooks:
        data.pop("hooks", None)
    with open(path, "w") as f:
        json.dump(data, f, indent=2, ensure_ascii=False); f.write("\n")
    print("  hooks removed")
else:
    print("  (no hooks found to remove)")
PY
fi

echo "Removing PATH export added by install.sh…"
PATH_LINE='export PATH="$HOME/.local/bin:$PATH"'
removed_path_line=0
for rc in "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.profile"; do
  if [ -f "$rc" ] && grep -qxF "$PATH_LINE" "$rc"; then
    tmp="$(mktemp)"
    grep -vxF "$PATH_LINE" "$rc" > "$tmp" && mv "$tmp" "$rc"
    echo "  removed PATH export from $rc"
    removed_path_line=1
  fi
done
[ "$removed_path_line" -eq 1 ] || echo "  (no PATH export found to remove)"

echo
echo "Kept: ~/.lark-cli/ (credentials) and the @larksuite/cli npm package."
echo "To remove those too:  rm -rf ~/.lark-cli  &&  npm uninstall -g @larksuite/cli"
