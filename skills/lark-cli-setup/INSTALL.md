# lark-cli-setup Skill — install guide

A Claude Code skill that sets up the Lark/Feishu CLI (`@larksuite/cli`) from zero and enables long-lived token auto-refresh.

> In this repo, `./install.sh` does everything below for you. These manual steps are only if you want to install the skill by hand.

## Install (macOS / Linux)

```bash
# 1. copy the skill into Claude Code's user-level skills directory
mkdir -p ~/.claude/skills
cp -r skills/lark-cli-setup ~/.claude/skills/lark-cli-setup

# 2. make the scripts executable
chmod +x ~/.claude/skills/lark-cli-setup/scripts/lark-cli-ensure-auth \
         ~/.claude/skills/lark-cli-setup/scripts/lark-cli-check-update

# 3. restart Claude Code (or start a new session) so the skill loads
```

This only installs the skill files. The token-refresh and update-check
scripts still need to land in `~/.local/bin` and get wired as Claude Code
SessionStart hooks — either let `install.sh` do all of that for you, or
follow SKILL.md's Step 5 to do it by hand.

## How to use

Once installed, just tell Claude something like:

- "help me connect the Lark CLI"
- "my token expired again, set up auto-refresh for me"
- "onboard me onto lark-cli"

Claude recognizes the trigger and walks you through the 6 steps in the skill:

1. Install `@larksuite/cli`
2. Prepare the Feishu/Lark app credentials (appId / appSecret)
3. `lark-cli config init --new`
4. `lark-cli auth login --recommend`
5. Deploy `lark-cli-ensure-auth` (token auto-refresh) and `lark-cli-check-update`
   (30-day version check) as Claude Code SessionStart hooks
6. (optional) install the official Lark skill pack

## Directory structure

```
lark-cli-setup/
├── SKILL.md                        # main skill file (read by Claude)
├── INSTALL.md                      # this file (read by humans)
└── scripts/
    ├── lark-cli-ensure-auth        # token auto-refresh script (Device Flow)
    ├── lark-cli-check-update       # throttled npm-version check
    └── _lark_cli_lib.sh            # shared helpers sourced by both scripts above
```

## Prerequisites

- macOS or Linux
- Node.js ≥ 18
- Feishu/Lark app credentials (App ID + App Secret)
  - Existing team app: ask an admin, or reuse a custom app the team already built
  - New app: create a custom app at https://open.feishu.cn (or https://open.larksuite.com)
- The app must have **"long-lived refresh_token" enabled** (otherwise durable auto-refresh is impossible)

## Troubleshooting

- Token keeps expiring → confirm the app has refresh_token enabled
- `permission denied` → follow the "Troubleshooting insufficient permissions" section in SKILL.md
- `lark-cli` not found → check `which lark-cli`; if needed, add the relevant bin directory (`~/.npm-global/bin`, `$(npm config get prefix)/bin`, `/opt/homebrew/bin`, or `~/.local/bin`) to PATH
