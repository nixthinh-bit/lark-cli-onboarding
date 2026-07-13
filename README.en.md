# lark-cli-onboarding

[Tiếng Việt](./README.md) | **English**

> **Paste one sentence into Claude Code → follow the prompts → control Lark/Feishu by talking.**

![status](https://img.shields.io/badge/status-active-brightgreen)
![platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-blue)
![license](https://img.shields.io/badge/license-MIT-yellow)

This kit lets [Claude Code](https://claude.com/claude-code) drive your **Lark/Feishu** workspace — read mail, summarize meetings, manage tasks, send messages, create docs, work with Base — in natural language, right in your terminal. It bundles the setup + login + **automatic token refresh** so you never have to log in again every 2 hours.

---

## ✅ Prepare first (5 minutes)

Only **2 things are truly required** — Claude installs the rest (Node.js, python3) for you, right in the terminal:

| # | You need | Notes |
|---|----------|-------|
| 1 | **Claude Pro (or higher) + Claude Code installed** | Claude Code is a terminal CLI — [install it here](https://claude.com/claude-code). Sign in with your Claude Pro account. |
| 2 | **A Feishu/Lark app** (you can make one in ~2 min) | Click straight into the console — Lark (intl): **[→ Create custom app (open.larksuite.com)](https://open.larksuite.com/app)** · Feishu (CN): **[→ Create custom app (open.feishu.cn)](https://open.feishu.cn/app)** → **Create custom app** → copy **App ID + App Secret** → enable **"long-lived refresh_token"**. Claude walks you through **exactly what to click**. ⚠️ **Not an admin?** A self-created app usually must be **approved/enabled by your tenant admin** (scopes too) before login works — get the admin to approve first; that wait is out of your hands. Team already has an app? Ask an admin for the App ID/Secret. |
| 3 | *(recommended)* **Your phone signed into the Lark/Feishu app** | So you can **scan a QR** to approve login in ~10s. No phone? Fine — just click the login link on your computer. |

**Node.js ≥ 18 & python3:** no need to pre-install. `install.sh` detects what's missing and installs it via Homebrew (macOS) / apt / dnf. **No Homebrew on your Mac?** Go to **[brew.sh](https://brew.sh)** → click the copy button (📋) on the *"Install Homebrew"* command box → paste it into the terminal and press Enter → type your **Mac password** (nothing shows as you type — that's normal) → then re-run. Claude can do this step for you too.

> ⚠️ The App Secret is a password. Keep it on your machine only — never paste it into public chats or logs. Claude won't print it back or save it to memory.

### What you'll see during setup (for non-technical users)

- **Permission pop-ups** to run a command → click **Allow once**. These commands only install things — nothing gets deleted, nothing costs money.
- Claude creates a dedicated folder **`~/Downloads/Claude x Lark`** and works inside it to keep things tidy.
- **If a step asks for your Mac password** (only when installing Homebrew): type it **directly into your own Terminal window** — **never** paste it into the chat with Claude. It stays on your machine; Claude never sees it. Note: **the password is invisible as you type** (no dots/asterisks) — it's not frozen, just type and press Enter. Password steps you **run yourself in Terminal**; Claude can't do them for you (its terminal can't receive the password prompt).
- Near the end there's **one manual step**: click the login link (or scan the QR with your phone) to approve access. Then you're live.

<details>
<summary>📖 How to open a Terminal & which password to type (click to expand)</summary>

**On macOS**
1. Press `Cmd (⌘)` + `Space` → type `Terminal` → Enter. (Or: Finder → Applications → Utilities → Terminal.)
2. **Paste** the command you were given (e.g. the Homebrew command copied from [brew.sh](https://brew.sh)) with `Cmd + V` → Enter.
3. When you see `Password:` → type your **Mac login password** (the one you use to unlock the machine / install apps). **Nothing shows as you type** — just type it and press Enter. If it says `Press RETURN to continue`, press Enter.

**On Windows**
> ⚠️ This kit runs on **WSL (Ubuntu)** — **not** native PowerShell/CMD (no bash/apt there). On Windows, install WSL first and do every step inside Ubuntu.
- Claude Code runs under **WSL (Ubuntu)**. Open **Start** → type `Ubuntu` (or `WSL`) → Enter. *(No WSL yet? Right-click **PowerShell** → "Run as administrator" → run `wsl --install` → reboot, and set an Ubuntu username + password when prompted.)*
- **Paste** the Linux command (e.g. `sudo apt-get update && sudo apt-get install -y nodejs npm python3`) → Enter. *(Paste in a Windows terminal: right-click, or `Ctrl + Shift + V`.)*
- When you see `[sudo] password for <name>:` → type your **Ubuntu/WSL user password** (the one you set the first time you opened Ubuntu) — **NOT** your Windows login password. It's invisible as you type too.
- Windows has **no Homebrew** — everything is installed inside Ubuntu with `apt` as above.

> Mac or Windows: this password goes **straight into the Terminal**, never into the chat with Claude.

</details>

---

## 🚀 Install — just one sentence

Open **Claude Code** and paste this, then hit Enter:

```
Clone https://github.com/nixthinh-bit/lark-cli-onboarding for me, then connect lark-cli by following its instructions.
```

Claude Code will: install anything missing (Node.js/python via Homebrew/apt) → clone the repo → run `install.sh` (installs the CLI + skill + auto-refresh) → then **guide you step by step**: how to create a custom app + copy the App ID/Secret, show a **click-to-open login link** plus a **crisp QR image to scan with your phone**, and verify the connection. You just **follow** its prompts and click **Allow once** when asked.

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

Update manually anytime: **`lark-cli update`** (built-in, install-method-agnostic) — or `npm i -g @larksuite/cli@latest`.

---

## 🧩 The official Lark skill pack (optional, recommended)

`@larksuite/cli` ships **~27 official agent skills** (`lark-base`, `lark-doc`, `lark-sheets`, `lark-mail`, `lark-calendar`, `lark-im`, `lark-drive`, `lark-task`, `lark-wiki`…) — these are what let Claude actually **operate** Lark, not just authenticate. This repo deliberately **doesn't install them for you** (they live in `~/.claude/skills` **globally**, affecting every project) — your call:

```bash
npx skills add larksuite/cli -g -y      # install, then restart Claude Code
lark-cli skills list                     # see what's installed
```

> Claude Code will also **offer** this during onboarding. Positioning: this repo handles **auto prerequisites + token auto-refresh + no-code onboarding**; the official pack handles **operating Base/Docs/Mail…** — they complement each other.

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
