# lark-cli-onboarding

[Tiếng Việt](./README.md) | **English**

> **Share one link — the recipient runs one command — Claude Code can drive Lark/Feishu.**

![status](https://img.shields.io/badge/status-active-brightgreen)
![platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-blue)
![license](https://img.shields.io/badge/license-MIT-yellow)

## Overview

`lark-cli-onboarding` is a **one-command** installer that lets [Claude Code](https://claude.com/claude-code) operate your **Lark/Feishu** workspace — read mail, summarize meetings, manage tasks, send messages, create docs, work with Base — in plain language, right in your terminal.

**The problem it solves:** the official [`@larksuite/cli`](https://github.com/larksuite/cli) is powerful (200+ commands), but getting a newcomer productive means installing it correctly, creating an app for credentials, doing the OAuth login, and dealing with a user token that expires every ~2 hours. `lark-cli-onboarding` packages that whole setup — **clone → `./install.sh` → done** — plus a **token auto-refresh** mechanism so you don't keep logging back in.

Unlike the MCP approach, this repo lets Claude Code **run `lark-cli` directly via Bash** (no MCP server needed), so you always get the CLI's **full** command surface and the latest CLI version.

## Features

- 🚀 **One-command install** — `install.sh` handles everything: CLI, skill, helper, hook.
- 🔄 **Token auto-refresh** — a Claude Code `SessionStart` hook silently refreshes the token each session and **never opens a browser on its own**.
- 📱 **QR-code login** — scan with the Lark/Feishu app on your phone; no desktop login required.
- 🧠 **Guided skill** — type *"help me connect lark-cli"* in Claude Code and the `lark-cli-setup` skill walks you through it.
- 🆕 **Always up to date** — installs `@larksuite/cli@latest` from npm; updating is just `npm update`.
- 🔐 **Safe by default** — credentials stay local (`chmod 600`), writes prefer `--dry-run`, the repo ships no secrets.
- ♻️ **Idempotent** — re-running `install.sh` never duplicates hooks or config.

## Installation

### Requirements
- macOS or Linux (use WSL on Windows)
- [Node.js](https://nodejs.org) ≥ 18, `npm`, `python3`
- A Feishu/Lark app (App ID + App Secret) — see [step 2](#2-get-your-app-id--app-secret-one-time)

### 1. Run the installer

```bash
git clone https://github.com/nixthinh-bit/lark-cli-onboarding.git
cd lark-cli-onboarding
./install.sh
```

Or as a one-liner:

```bash
curl -fsSL https://raw.githubusercontent.com/nixthinh-bit/lark-cli-onboarding/main/install.sh | bash
```

> 💡 Read `install.sh` before running it (especially with `curl | bash`) — it's short and transparent.

`install.sh` will: install `@larksuite/cli@latest` → install the skill into `~/.claude/skills` → install the helper into `~/.local/bin` → wire the auto-refresh hook into `~/.claude/settings.json`. Remove anytime with `./uninstall.sh`.

### 2. Get your App ID / App Secret (one-time)

> Official FAQ: <https://open.larkoffice.com/document/faq/trouble-shooting/how-to-obtain-app-id>

1. Open the developer console for your edition:
   - Feishu (China): <https://open.feishu.cn/app>
   - Lark (international): <https://open.larksuite.com/app>
2. No app yet? Click **Create custom app** → name it, add an icon → create.
3. Open the app → left menu → **Credentials & Basic Info**.
4. Copy the **App ID**, then reveal/copy the **App Secret**.
5. On the same page, under **Security Settings**, **enable "long-lived refresh_token"** (required for durable auto-refresh).

> ⚠️ The App Secret is a password. Keep it only in `~/.lark-cli/config.json` on your machine; **never** paste it into public channels or logs.

### 3. Log in once

```bash
lark-cli config init --new         # enter brand + App ID/Secret
lark-cli auth login --recommend    # approve OAuth (browser or QR — see Usage)
```

Not comfortable with the terminal? Open Claude Code and say *"help me connect lark-cli"* — the skill guides all three steps. Then **restart Claude Code**.

## Usage

### Inside Claude Code
After installing, just talk naturally — Claude Code runs `lark-cli` for you:

> *"What's on my plate today?"*
> *"Summarize my unread mail."*
> *"Create a doc called 'Weekly plan' with three bullet points."*

### Directly via the CLI

```bash
lark-cli contact +get-user --as user        # your own profile
lark-cli calendar +agenda --as user         # today's agenda
lark-cli im send --to "<chat_id>" --text "hello" --as bot
```

> Syntax note: shortcuts use a `+` prefix (e.g. `contact +get-user`), not `contact get-user`.

### QR-code login (handy for remote users)

```bash
OUT=$(lark-cli auth login --recommend --no-wait --json)
URL=$(echo "$OUT" | python3 -c "import sys,json;print(json.load(sys.stdin).get('verification_url',''))")
CODE=$(echo "$OUT" | python3 -c "import sys,json;print(json.load(sys.stdin).get('device_code',''))")

lark-cli auth qrcode "$URL" --ascii          # print QR in the terminal to scan
# or: lark-cli auth qrcode "$URL" --output qr.png

# open the Lark/Feishu app on your phone → scan → approve, then finish:
lark-cli auth login --device-code "$CODE" --json
```

In Claude Code, just say *"log in to lark with QR"*.

### Token & auto-refresh

- The `SessionStart` hook runs `lark-cli-ensure-auth --quiet` each session → silent refresh via the refresh_token, no browser.
- Run it manually anytime: `lark-cli-ensure-auth` (no flags) → if needed, shows a QR + opens the browser to re-login.
- The **Lark** token (free, ~2h) is completely separate from your **Claude** usage limit (Pro plan, 5-hour window) — this hook only manages the Lark token.

## Contributing

Issues and PRs are welcome. The repo is intentionally small and readable so anyone can fork and adapt it.

### Structure

```
lark-cli-onboarding/
├── install.sh          # idempotent bootstrap (npm + copy skill/helper + merge hook)
├── uninstall.sh        # clean removal, keeps your credentials
└── skills/lark-cli-setup/
    ├── SKILL.md        # what Claude Code reads to guide setup & login
    ├── INSTALL.md
    └── scripts/lark-cli-ensure-auth   # auto-refresh helper (reads .identities.user.tokenStatus)
```

### Development tips
- **Changing install behavior** → edit `install.sh`; keep it idempotent (merge, don't blindly append).
- **Editing the token helper** → note that CLI ≥ 1.0.5x puts status at `.identities.user.tokenStatus` (no longer a top-level `.tokenStatus`); `--quiet` must never open a browser.
- **Running on Codex CLI** → Codex also supports Skills + a `SessionStart` hook, but under `~/.codex/` (TOML config), not `~/.claude/`. Adding a branch in `install.sh` that detects `~/.codex` and copies to the right place is a very welcome PR.
- After changes, syntax-check: `bash -n install.sh uninstall.sh skills/lark-cli-setup/scripts/lark-cli-ensure-auth`.

### Reporting bugs / sending PRs
1. Open an [issue](https://github.com/nixthinh-bit/lark-cli-onboarding/issues) with your environment (OS, `node -v`, `lark-cli --version`) and repro steps.
2. Fork → feature branch → clear commits → open a Pull Request.
3. **Never** commit credentials, App Secrets, tokens, or internal infrastructure URLs.

## License

[MIT](./LICENSE) © 2026 nixthinh-bit
