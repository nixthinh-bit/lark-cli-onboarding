# lark-cli-onboarding

[Tiếng Việt](./README.md) | **English**

> **Paste one sentence into Claude Code → answer a few questions → control Lark/Feishu by talking.**

![status](https://img.shields.io/badge/status-active-brightgreen)
![platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-blue)
![license](https://img.shields.io/badge/license-MIT-yellow)

This kit lets [Claude Code](https://claude.com/claude-code) drive your **Lark/Feishu** workspace — read mail, summarize meetings, manage tasks, send messages, create docs, work with Base — in natural language, right in your terminal. It bundles the setup + login + **automatic token refresh** so you never have to log in again every 2 hours.

> 🙋 **Not technical?** You **don't need to remember any commands**. Just paste one sentence at [Step 1](#-install--just-one-sentence), then answer Claude's questions and click **Allow once**. The [What happens](#-what-happens--step-by-step) section describes exactly what you'll see.

---

## ✅ Prepare first (5 minutes)

Only **2 things are truly required** — Claude handles the rest:

| # | You need | Notes |
|---|----------|-------|
| 1 | **Claude Pro (or higher) + Claude Code installed** | Claude Code is a terminal CLI — [install it here](https://claude.com/claude-code). Sign in with your Claude Pro account. |
| 2 | **A Feishu/Lark app** (make one in ~2 min) | Claude walks you through creating it at [Step 3](#-what-happens--step-by-step). Team already has an app? Ask an admin for the **App ID + App Secret**. |

*Optional:* **your phone signed into the Lark/Feishu app** so you can **scan a QR** to log in fast (no phone? just click the link on your computer).

**Node.js & python3:** no need to pre-install — Claude detects what's missing and installs it (via Homebrew on macOS, or apt/dnf on Linux). If your Mac has no Homebrew, see [📖 How to open a Terminal & which password](#-what-youll-see-during-setup).

> ⚠️ The App Secret is a password. Keep it on your machine only — never paste it into public chats or logs. Claude won't print it back or save it to memory.

---

## 🚀 Install — just one sentence

Open **Claude Code** and paste this, then hit Enter:

```
Clone https://github.com/nixthinh-bit/lark-cli-onboarding for me, then connect lark-cli by following its instructions.
```

That's all you need to type. From here Claude guides you — details below.

---

## 🧭 What happens — step by step

Each step spells out: **🗣️ what you provide**, **🤖 what Claude asks back**, **✅ what you get**, and **✂️ what to say if you don't need it**.

### Step 1 — Kick off
- 🗣️ **You paste** the sentence above.
- 🤖 **Claude asks:** Are you on **Lark (international)** or **Feishu (China)**? Do you already have a Lark app or need to create one?
- ✅ **You see:** Claude summarizes the upcoming steps, then asks to run commands → click **Allow once**.

### Step 2 — Prepare the machine *(automatic)*
- 🤖 Claude checks Node.js/python; if missing, asks to install them.
- ✅ **You see:** `✓ Prerequisites OK — node …`
- ✂️ **Already have them?** Claude skips this — nothing for you to do.

### Step 3 — Create the Lark app & get App ID/Secret *(manual)*
- 🤖 **Claude sends you a click-to-open console link** + step-by-step: click **Create custom app** → open **Credentials & Basic Info** → copy **App ID** (`cli_…`) and **App Secret** (click the eye to reveal) → enable **long-lived refresh_token**.
- 🗣️ **You paste back** the App ID + App Secret into the chat.
- ⏳ **If you're NOT an admin:** a self-created app usually must be **approved by your tenant admin** before login works. Claude will **pause** — get the admin to approve, then come back. That wait is out of your hands.

### Step 4 — Log in *(manual)*
- 🤖 Claude sends a **[👉 click-to-open login link]** plus a **crisp QR image (already opened)** to scan with your phone.
- 🗣️ **You:** click the link (or scan the QR) → approve in the Lark app → reply **"done"**.
- ✅ **You see:** `tokenStatus: valid`.

### Step 5 — Verify
- ✅ Claude runs a test and prints your own info → connection OK. It reminds you to **restart Claude Code** once to load the skill + hooks.

### Step 6 — *(Optional)* The official Lark skill pack
- 🤖 Claude asks: *"Want me to also install the ~27 official skills (Base / Docs / Mail / Calendar / IM…) so I can operate Lark? They go into your global Claude skills."*
- ✅ Say yes → you can now drive Base, Docs, Mail… by talking. (See [the skills section](#-the-official-lark-skill-pack-optional-recommended).)

---

### ✂️ "I don't need all of it" — where and when to say so

Just say it in plain language and Claude narrows things down:

| You want | When to say it | What to say (example) |
|---|---|---|
| Only a few features (e.g. mail only) | Step 1, or when Claude proposes a plan | *"I only need to read & summarize mail, not Base/Sheets"* |
| Not all 27 global skills | Step 6, when Claude asks | *"Skip the skill pack"* — or *"only install lark-mail, lark-calendar"* |
| No automatic update nagging | Anytime | *"Turn off the CLI update check for me"* (Claude removes the check-update hook) |
| Already have the app / Node | Step 1 | *"I already have Node; I also have the App ID/Secret"* |

---

## 👀 What you'll see during setup

- **Permission pop-ups** to run a command → click **Allow once**. These commands only install things — **nothing gets deleted, nothing costs money**.
- Claude creates a dedicated folder **`~/Downloads/Claude x Lark`** and works inside it to keep things tidy.
- **If a step asks for your machine password** (only when installing Homebrew/Node): type it **straight into the Terminal window**, **not** into the chat. The password stays local — Claude never sees it — and **nothing shows as you type** (not frozen; just type and Enter). You run password steps yourself (Claude's terminal can't enter passwords).

<details>
<summary>📖 How to open a Terminal & which password to type (click to expand)</summary>

**On macOS**
1. Press `Cmd (⌘)` + `Space` → type `Terminal` → Enter. (Or: Finder → Applications → Utilities → Terminal.)
2. **Paste** the command you were given (e.g. the Homebrew command copied from [brew.sh](https://brew.sh) — click the 📋 copy button in the *"Install Homebrew"* box) with `Cmd + V` → Enter.
3. When you see `Password:` → type your **Mac login password** (the one you use to unlock the machine / install apps). **Nothing shows as you type** — just type it and press Enter. If it says `Press RETURN to continue`, press Enter.

**On Windows**
> ⚠️ This kit runs on **WSL (Ubuntu)** — **not** native PowerShell/CMD (no bash/apt there). On Windows, install WSL first and do every step inside Ubuntu.
- Open **Start** → type `Ubuntu` (or `WSL`) → Enter. *(No WSL yet? Right-click **PowerShell** → "Run as administrator" → run `wsl --install` → reboot, and set an Ubuntu username + password when prompted.)*
- **Paste** the Linux command → Enter *(paste in a Windows terminal: right-click, or `Ctrl + Shift + V`)*.
- When you see `[sudo] password for <name>:` → type your **Ubuntu/WSL user password** (set the first time you opened Ubuntu) — **NOT** your Windows login password. Invisible as you type too.
- Windows has **no Homebrew** — everything is installed inside Ubuntu with `apt`.

> Mac or Windows: this password goes **straight into the Terminal**, never into the chat with Claude.

</details>

<details>
<summary>⌨️ Manual way (if you prefer running commands yourself)</summary>

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
- **Nudges CLI updates (every 30 days by default)** — `lark-cli-check-update --quiet` compares your installed version against the latest. Between checks it exits instantly with **no network call**, so it never slows a session down.

Tune it with environment variables (set in `~/.zshrc` or `~/.bashrc`):

| Variable | Default | Effect |
|----------|---------|--------|
| `LARK_CLI_AUTO_UPDATE` | `0` (notify only) | Set `1` to **auto-update** (runs `lark-cli update`, npm fallback) when a newer version exists, instead of only notifying. |
| `LARK_CLI_UPDATE_INTERVAL_DAYS` | `30` | Change the check interval (e.g. `7` = weekly). |

Update manually anytime: **`lark-cli update`** (built-in, install-method-agnostic) — or `npm i -g @larksuite/cli@latest`.

---

## 🧩 The official Lark skill pack (optional, recommended)

`@larksuite/cli` ships **~27 official agent skills** (`lark-base`, `lark-doc`, `lark-sheets`, `lark-mail`, `lark-calendar`, `lark-im`, `lark-drive`, `lark-task`, `lark-wiki`…) — these are what let Claude actually **operate** Lark, not just authenticate. This repo deliberately **doesn't install them for you** (they live in `~/.claude/skills` **globally**, affecting every project) — your call:

```bash
npx skills add larksuite/cli -g -y      # install, then restart Claude Code
lark-cli skills list                     # see what's installed
```

> These skills **already ship inside the `@larksuite/cli` package**; the command above just **copies them into `~/.claude/skills/`** so Claude auto-discovers them — **it downloads nothing new**. Claude Code will also **offer** this at [Step 6](#-what-happens--step-by-step).
>
> **Positioning:** this repo handles **auto prerequisites + token auto-refresh + no-code onboarding**; the official pack handles **operating Base/Docs/Mail…** — they complement each other.

---

## 🤝 Contributing & structure

Issues/PRs welcome. The repo is deliberately small and easy to fork.

```
lark-cli-onboarding/
├── install.sh          # idempotent bootstrap (prereqs + npm + copy skill/helper + merge hook)
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
