#!/bin/bash
# Shared helpers for lark-cli-onboarding — sourced by install.sh,
# lark-cli-ensure-auth, and lark-cli-check-update so PATH resolution and
# tokenStatus parsing live in exactly one place.

# Add every known lark-cli/npm install location to PATH if not already there.
lark_cli_resolve_path() {
  local d
  for d in \
    "$HOME/.npm-global/bin" \
    "$(npm config get prefix 2>/dev/null)/bin" \
    /opt/homebrew/bin \
    /usr/local/bin \
    "$HOME/.local/bin"; do
    # Written as if/fi (not `cond && cmd`) so a missing directory can never
    # leave a non-zero exit status behind — this is sourced by install.sh,
    # which runs under `set -e`, and a bare `&&` there would abort the whole
    # installer the moment one candidate directory doesn't exist.
    case ":$PATH:" in
      *":$d:"*) continue ;;
    esac
    if [ -d "$d" ]; then
      PATH="$d:$PATH"
    fi
  done
  export PATH
}

# Print the user's tokenStatus ("valid" / "needs_refresh" / "expired" /
# "unknown"). Reads the new nested shape (lark-cli >= 1.0.5x:
# .identities.user.tokenStatus) and falls back to the old top-level
# .tokenStatus shape for older CLI builds.
lark_cli_token_status() {
  lark-cli auth status 2>/dev/null | python3 -c '
import sys, json
try:
    d = json.load(sys.stdin)
except Exception:
    print("unknown"); sys.exit(0)
u = (d.get("identities", {}) or {}).get("user", {}) or {}
print(u.get("tokenStatus") or d.get("tokenStatus") or "unknown")
' 2>/dev/null
}
