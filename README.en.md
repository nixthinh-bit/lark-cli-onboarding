# lark-cli-onboarding

[Tiếng Việt](./README.md) | **English**

> **Paste one sentence into Claude Code → follow the prompts → control Lark/Feishu by talking.**

![status](https://img.shields.io/badge/status-active-brightgreen)
![platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-blue)
![license](https://img.shields.io/badge/license-MIT-yellow)

This kit lets [Claude Code](https://claude.com/claude-code) drive your **Lark/Feishu** workspace — read mail, summarize meetings, manage tasks, send messages, create docs, work with Base — in natural language, right in your terminal. It bundles the setup + login + **automatic token refresh** so you never have to log in again every 2 hours.

---

## ✅ Prepare first (5 minutes)

Get these 4 things ready and installing is just pasting one sentence and following along:

| # | You need | Notes |
|---|----------|-------|
| 1 | **Claude Pro (or higher) + Claude Code installed** | Claude Code is a terminal CLI — [install it here](https://claude.com/claude-code). Sign in with your Claude Pro account. |
| 2 | **Node.js ≥ 18** (with `npm`) | Check: `node -v`. Missing? Grab the **LTS** build at [nodejs.org](https://nodejs.org). macOS/Linux; Windows via WSL. |
| 3 | **A Feishu/Lark app approved by your admin** | You (or an admin) create an app in the console, copy its **App ID + App Secret**, and **enable "long-lived refresh_token"**. Not an admin? Ask your admin to create/approve it and grant scopes. Claude walks you through it. |
| 4 | **Your phone already signed into the Lark/Feishu app** | So you can **scan a QR code** to approve login in ~10 seconds instead of wrestling with a desktop browser. |

> ⚠️ The App Secret is a password. Keep it on your machine only — never paste it into public chats or logs.

---

## 🚀 Install — just one sentence

Open **Claude Code** and paste this, then hit Enter:

```
Clone https://github.com/nixthinh-bit/lark-cli-onboarding for me, then connect lark-cli by following its instructions.
```

Claude Code will: clone the repo → run `install.sh` (installs the CLI + skill + auto-refresh) → then **guide you step by step**: enter your App ID/Secret, show a **QR code to scan with your phone**, and verify the connection. You just **follow** its prompts.

When it's done, **restart Claude Code** once to load the new skill + hooks.

<details>
<summary>Manual way (if you prefer running commands yourself)</summary>

```bash
curl -fsSL https://raw.githubusercontent.com/nixthinh-bit/lark-cli-onboarding/main/install.sh | bash
```

Then log in once:
```bash
lark-cli config init --new         # enter brand + App ID/Secret
lark-cli auth login --recommend    # approve OAuth (browser or QR)
```
Uninstall anytime: `./uninstall.sh` (keeps your credentials).
</details>

---

## 💬 Try it

After setup, just talk naturally in Claude Code — it types `lark-cli` for you:

> *"What do I have to do today?"*
> *"Summarize my unread emails."*
> *"Create a doc called 'Weekly Plan' with 3 bullet points."*
> *"Log into Lark with a QR code."* (when you need to re-auth)

Prefer the raw CLI:
```bash
lark-cli contact +get-user --as user     # your own info
lark-cli calendar +agenda  --as user      # today's agenda
```
> Syntax: shortcuts use a `+` prefix (e.g. `contact +get-user`).

---

## 🔄 Token & auto-update

The installer wires two `SessionStart` hooks into `~/.claude/settings.json` (they run each time Claude Code starts):

- **Keeps the token fresh** — `lark-cli-ensure-auth --quiet` silently refreshes via the refresh_token and **never opens a browser**. The Lark token (~2h) is fully separate from your Claude quota.
- **Nudges CLI updates (every 30 days by default)** — `lark-cli-check-update --quiet` compares your installed version against the latest on npm. Between checks it exits instantly with **no network call**, so it never slows a session down.

Tune it with environment variables (set in `~/.zshrc` or `~/.bashrc`):

| Variable | Default | Effect |
|----------|---------|--------|
| `LARK_CLI_AUTO_UPDATE` | `0` (notify only) | Set `1` to **auto-run** `npm i -g @larksuite/cli@latest` when a newer version exists, instead of only notifying. |
| `LARK_CLI_UPDATE_INTERVAL_DAYS` | `30` | Change the check interval (e.g. `7` = weekly). |

Update manually anytime: `npm i -g @larksuite/cli@latest`.

---

## 🤝 Contributing & structure

Issues/PRs welcome. The repo is deliberately small and easy to fork.

```
lark-cli-onboarding/
├── install.sh          # idempotent bootstrap (npm + copy skill/helper + merge hook)
├── uninstall.sh        # clean removal, keeps credentials
└── skills/lark-cli-setup/
    ├── SKILL.md        # Claude Code reads this to guide setup & login
    └── scripts/
        ├── lark-cli-ensure-auth    # token auto-refresh (reads .identities.user.tokenStatus)
        └── lark-cli-check-update   # periodic CLI update notifier / auto-updater
```

**Never** commit credentials, App Secrets, tokens, or internal infra paths. After editing, syntax-check:
```bash
bash -n install.sh uninstall.sh skills/lark-cli-setup/scripts/*
```

## License

[MIT](./LICENSE) © 2026 nixthinh-bit
