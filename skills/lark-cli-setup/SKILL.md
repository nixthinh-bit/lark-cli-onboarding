---
name: lark-cli-setup
version: 1.0.0
description: "First-time Lark/Feishu CLI connection and token persistence. Guides from zero: install @larksuite/cli, initialize the Feishu/Lark app (appId/appSecret), OAuth login (user identity) or app identity (bot), and deploy a Device Flow token auto-refresh script. Trigger when the user wants to connect lark-cli for the first time, onboard a new teammate, troubleshoot an expired token, set up long-lived auto-refresh, or configure refresh_token."
---

# lark-cli connection & token persistence

This skill covers the full **lark-cli from zero to auto-refresh** flow: prepare the machine → install → app credentials → auth → token-persistence script → verify.

> **Scope**: this skill is CLI-only. MCP integration is out of scope.

---

## For the human (read this to the user first)

Most people running this are **non-coders**. Before touching any command, tell the user what to expect, in their language, roughly:

> "I'll set up the Lark CLI for you. A few things you'll see:
> 1. **Permission pop-ups** — when I run a command, Claude Code asks you to approve it. For the setup commands here, click **Allow once** (or **Yes**). Nothing here deletes data or spends money.
> 2. **A dedicated folder** — I'll make a folder `~/Downloads/Claude x Lark` and work inside it, so nothing clutters the rest of your machine.
> 3. **One browser/QR login** — near the end you'll either click a link or scan a QR with your phone's Lark app to approve access. That's the only truly manual step.
> 4. **If a step asks for your Mac password** (only when installing Homebrew), you type it into your **own Terminal window**, not into this chat. I never see or handle your device password.
> Ready? I'll start."

Do **not** dump raw commands on a non-coder. Run them yourself, explain each in one line, and pause at the human steps (App ID/Secret, the login approval).

> 🔐 **Password steps must NOT run through your Bash tool.** Anything that triggers a `sudo` / login-password prompt — installing **Homebrew**, `sudo apt-get`, `sudo dnf` — needs a real interactive terminal (a TTY). Your Bash tool has no TTY, so the prompt appears but the user **cannot type into it** and it hangs. For those commands: give the user the exact line and ask them to run it in **their own Terminal app**, warn that the password is **invisible while typing** (no dots/asterisks — that's normal, just type and press Enter), and wait for them to say it finished. Never ask the user to paste their device password into the chat, and never try to pipe it in — the OS `sudo` prompt is the only place it belongs, and it stays local.

**When you have to send a non-coder to their own terminal, relay this exactly:**
- **macOS** — Press `Cmd (⌘)`+`Space`, type `Terminal`, Enter. Paste the command (`Cmd+V`), Enter. At `Password:` type the **Mac login password** (nothing shows as you type — normal); at `Press RETURN to continue` press Enter.
- **Windows** — this kit runs on **WSL (Ubuntu)**, **not** native PowerShell/CMD (no bash/apt/brew there, so `install.sh` won't run). If the user is on native Windows, have them install WSL first (`wsl --install` in an admin PowerShell, reboot), then do everything inside Ubuntu. Open Start → type `Ubuntu` → Enter. Paste the command (right-click or `Ctrl+Shift+V`), Enter. At `[sudo] password for <name>:` type the **Ubuntu/WSL user password** (set when WSL was first installed), **not** the Windows login password. No Homebrew on Windows — use `sudo apt-get …` inside Ubuntu.

---

## Step 0: Prepare the machine & workspace

**0a. Create a dedicated working folder** (keeps everything tidy, gives the login QR a place to live):
```bash
mkdir -p ~/Downloads/"Claude x Lark" && cd ~/Downloads/"Claude x Lark"
```

**0b. Check prerequisites and install what's missing.** Needed: **Node.js ≥ 18** (with `npm`) and **python3**.
```bash
node -v ; npm -v ; python3 --version
```
If any are missing, install them. **Homebrew install and any `sudo` line need the user's device password → the user runs those in their own Terminal, not through your Bash tool** (see the 🔐 note above). `brew install …` / `npm …` after Homebrew exists need no password and are fine to run for them.

- **macOS with Homebrew:** `brew install node python`
- **macOS without Homebrew — install it first (walk the user through the browser):**
  1. Open **[brew.sh](https://brew.sh)** — the official Homebrew site.
  2. Under **"Install Homebrew"** there's a command box with a **copy button** (📋) on the right. Click it to copy the one line.
  3. Paste it into the terminal and press Enter. It will ask for your **Mac login password** (typing shows nothing — that's normal) and may say *"Press RETURN to continue"* — press Enter.
  4. When it finishes, it prints two `echo ... >> ~/.zprofile` lines under *"Next steps"* — run those so `brew` is on your PATH (or just open a new terminal).
  5. Then: `brew install node python`

  The exact command shown on brew.sh is:
  ```bash
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  ```
- **Debian/Ubuntu:** `sudo apt-get update && sudo apt-get install -y nodejs npm python3`
- **Fedora:** `sudo dnf install -y nodejs python3`

> `install.sh` in this repo does 0b automatically (it auto-installs via brew/apt/dnf, or prints the Homebrew one-liner if that's missing). Prefer running it; do the manual steps above only if the user asked to go step by step.

---

## Step 1: Install lark-cli

```bash
# public registry
npm install -g @larksuite/cli

# if your organization has a private npm registry, add --registry <your-registry-url>
```

Verify:
```bash
lark-cli --version   # expected: lark-cli version 1.x.x
```

---

## Step 2: Create a custom app & get the App ID / App Secret

This is the **first human step**. The App ID/Secret are the "username/password" that lets the CLI talk to Lark. Walk the user through it slowly — a non-coder has never seen the developer console.

> If the team **already has an app**, skip creating one: ask the admin for the **App ID + App Secret** (and to enable long-lived refresh_token), then jump to Step 3.

**Tell the user to do this in their browser.** Send the console link as a clickable hyperlink so one click lands them on the create-app page (pick the edition):

1. Open the developer console and log in with your normal Lark/Feishu account:
   - Lark (international): **[→ Create a custom app (open.larksuite.com)](https://open.larksuite.com/app)**
   - Feishu (China): **[→ Tạo ứng dụng tùy chỉnh (open.feishu.cn)](https://open.feishu.cn/app)**
2. On that page click the **Create custom app** button (Tạo ứng dụng tùy chỉnh). Give it a name like `My Claude CLI` and any icon → **Create**.
3. You're now inside the app. On the left sidebar open **Credentials & Basic Info** (Thông tin cơ bản).
4. Under **App Credentials** you'll see two values:
   - **App ID** — starts with `cli_...`, safe-ish to share.
   - **App Secret** — click the eye/**Reveal** to show it. **This is a password.**
5. Still on that page, find **Security Settings** and **turn ON "long-lived refresh_token"** (bật refresh_token dài hạn). Without this, the CLI would ask you to log in again every couple of hours.
6. **Copy both values and paste them into this chat.** I'll load them into the CLI for you.

> ⚠️ The App Secret is a password. It's stored only in `~/.lark-cli/config.json` on this machine and `chmod 600`. I will **never** print it back to you, put it in logs, or save it to memory. If you accidentally paste it somewhere public, rotate it in the console.

> 🏢 **Not a workspace admin? There's a wait here.** A self-created custom app usually can't be used until the **tenant admin approves/enables it** for the workspace, and sensitive scopes may need admin approval too. Depending on the org's settings, `auth login` (Step 4) can **fail until that approval lands**. If the user isn't the admin:
> - Tell them to **request approval / release** in the console (there's usually a *"Request release"* / *"Version management"* action) and **ping their Lark admin** to approve it.
> - This is an **out-of-your-hands wait** — a human on the admin side must click approve. Set that expectation; don't loop retrying `auth login`. Pause setup and have the user come back once the admin confirms.
> - If Step 4 or a later command errors with a permissions problem, the CLI prints a **`console_url`** — hand that to the admin to enable the missing scope. (If the user *is* the admin, they can self-approve and continue immediately.)

**As the AI agent:** wait for the user to paste App ID + App Secret before running Step 3. Do not proceed with placeholders.

---

## Step 3: Load the credentials (no ugly interactive prompt)

Store the App ID/Secret **non-interactively** — this avoids the clunky prompt and keeps the secret off the process list (it's read from stdin):

```bash
# brand: `lark` (international) or `feishu` (China)
printf '%s' "<APP_SECRET>" | lark-cli config init \
  --app-id "<APP_ID>" --app-secret-stdin --brand lark --lang en
chmod 600 ~/.lark-cli/config.json
```

- Substitute the values the user pasted. Read the secret from a shell variable if you prefer, but **never echo it back**.
- Fallback (older CLI or if the above balks): run `lark-cli config init --new` and guide the user through the interactive prompts (`brand`, `appId`, `appSecret`, `lang`).

The config lives at `~/.lark-cli/config.json`; the `chmod 600` locks it to the current user.

---

## Step 4: Authenticate

### Identity model

Two identities, switched via `--as`:

| Identity | How to obtain | Use for |
|----------|---------------|---------|
| `--as user` | via `auth login`, requires browser approval | the user's own calendar, drive, IM, mailbox |
| `--as bot` | no login needed, just appId + appSecret | app-level operations, the bot's own resources |

**Key differences:**
- A bot cannot see user resources (querying the agenda returns the bot's own empty calendar).
- A bot cannot act on behalf of the user (messages are sent as the app; docs it creates belong to the bot).
- A user scope needs both console approval **and** the user's `auth login`.
- **Never run `auth login` for a bot.**

### User authorization (pick one)

Recommended scopes (a common set, one approval):
```bash
lark-cli auth login --recommend
```

Specific scopes (least privilege):
```bash
lark-cli auth login --scope "calendar:calendar:readonly docx:document:readonly"
```

A whole business domain:
```bash
lark-cli auth login --domain calendar
```

**When acting as an AI agent**, use `--no-wait --json`, then **present the authorization URL to the user as a clickable markdown hyperlink** in your chat message — Claude Code renders it, so one click opens their browser. Don't just paste the raw URL. Example of what to send:

> **[👉 Click here to authorize Lark](PASTE_THE_VERIFICATION_URL)** — approve in the browser, then tell me "done".

Scopes from multiple logins accumulate (incremental authorization).

### QR-code authorization (recommended for non-terminal / remote users)

When the user would rather scan with their phone than log in on this computer, use Device Flow + a QR code. **Generate a PNG image and open it** — it's far cleaner than the ASCII block QR, which looks garbled in most terminals.

```bash
# 1) Start Device Flow, get device_code + verification_url (non-blocking)
OUT=$(lark-cli auth login --recommend --no-wait --json)
URL=$(echo "$OUT" | python3 -c "import sys,json;d=json.load(sys.stdin);print(d.get('verification_url',d.get('verificationUrl','')))")
CODE=$(echo "$OUT" | python3 -c "import sys,json;d=json.load(sys.stdin);print(d.get('device_code',d.get('deviceCode','')))")

# 2) Make a crisp QR PNG and open it in the image viewer (nice, scannable).
#    --output must be a RELATIVE path inside the current dir, so cd there first.
cd ~/Downloads/"Claude x Lark"
lark-cli auth qrcode "$URL" --output lark-login-qr.png --size 512
open lark-login-qr.png            # macOS (Linux: xdg-open)
# ASCII fallback only if PNG fails:  lark-cli auth qrcode "$URL" --ascii

# 3) User scans with the phone Lark app → approves, then poll to complete
lark-cli auth login --device-code "$CODE" --json
```

**AI agent**: in your turn message, give the user BOTH — the clickable hyperlink (above) **and** a line telling them the QR image just opened (`~/Downloads/Claude x Lark/lark-login-qr.png`) to scan with their phone. Then end the turn; after they confirm, complete with `--device-code`. `lark-cli-ensure-auth` (interactive mode) already does this: on expiry it prints the clickable URL, opens a PNG QR, and opens the browser.

### Check status

```bash
lark-cli auth status
```

Returns JSON; the user token status is at **`.identities.user.tokenStatus`** (`valid` / `needs_refresh` / `expired`).
> ⚠️ Since CLI >= 1.0.5x this field is **nested** under `.identities.user`, no longer a top-level `.tokenStatus`.

---

## Step 5: Deploy the token auto-refresh script

A user token lasts ~2 hours. Cron jobs / background agents need automatic refresh. This skill ships `lark-cli-ensure-auth` for unattended refresh.

### Install

```bash
# 1. create the directory if missing
mkdir -p ~/.local/bin

# 2. copy the script from the skill (adjust the path to your skill location)
cp ~/.claude/skills/lark-cli-setup/scripts/lark-cli-ensure-auth ~/.local/bin/
chmod +x ~/.local/bin/lark-cli-ensure-auth

# 3. make sure PATH includes ~/.local/bin
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc  # bash users: ~/.bashrc
source ~/.zshrc
```

### Usage

```bash
# call before Lark operations to ensure the token is usable
lark-cli-ensure-auth           # verbose
lark-cli-ensure-auth --quiet   # silent; also never opens a browser (safe for hooks/cron)
```

### Script logic

1. Read `lark-cli auth status` and parse `.identities.user.tokenStatus`.
2. `valid` → exit 0 immediately.
3. Otherwise attempt a silent refresh via a light user API call (uses the stored refresh_token, no browser).
4. Still not valid + `--quiet`/`--no-browser` → warn and exit 1 (do not open a browser).
5. Interactive → Device Flow: print a QR, open the browser, poll `--device-code` for up to 90s.

Prerequisite: the app has refresh_token enabled (see Step 2).

---

## Verify the connection

```bash
# User identity: read your own info
lark-cli contact +get-user --as user

# User identity: list the agenda
lark-cli calendar +agenda --as user

# Bot identity: send a message
lark-cli im send --to "<chat_id>" --text "hello" --as bot
```

> Note: shortcuts use a `+` prefix (e.g. `contact +get-user`). Each command prints `[identity: bot/user]` at the start of its output so you can confirm the active identity.

---

## Step 6 (optional but recommended): install the official Lark skill pack

`@larksuite/cli` ships ~27 official **agent skills** that let Claude actually *drive* Lark by talking — `lark-base`, `lark-doc`, `lark-sheets`, `lark-mail`, `lark-calendar`, `lark-im`, `lark-drive`, `lark-task`, `lark-wiki`, and more. Without them, this skill only gets the user *connected*; with them, "summarize my unread mail" or "add a row to that Base" actually work.

**This is opt-in — ask first, don't install silently.** The pack lands in `~/.claude/skills/` **globally** (affects every Claude Code project, not just Lark work), so let the user decide. Say something like: *"Want me to also install Lark's official skill pack (~27 skills) so I can work with your Base, Docs, Mail, Calendar, etc.? It adds them to your global Claude skills."*

If the user says yes:
```bash
npx skills add larksuite/cli -g -y
```

Then tell them to **restart Claude Code** so the new skills load. Check what's installed anytime with `lark-cli skills list`. (This only adds skills; it doesn't touch auth or the refresh hook.)

> Note: one of these, `lark-shared`, also covers auth/setup — it overlaps with this `lark-cli-setup` skill. They coexist fine: `lark-cli-setup` owns first-time onboarding + prerequisites + the unattended token-refresh hook (which the official pack does **not** provide); `lark-shared` is for day-to-day auth commands.

---

## Troubleshooting insufficient permissions

Error responses include useful fields:

| Field | Meaning |
|-------|---------|
| `permission_violations` | list of missing scopes (satisfying any one of N is enough) |
| `console_url` | the app's scope-configuration page on the open platform |
| `hint` | a suggested fix command |

**Bot identity error**: send the `console_url` to the user and guide them to enable the scope on the open platform. Do not run `auth login`.

**User identity error**:
```bash
lark-cli auth login --scope "<missing_scope>"
```

---

## Security rules

- **Never** print `appSecret` / `accessToken` / `refreshToken` in plaintext to the terminal, logs, or memory.
- **Confirm intent** before any write/delete operation.
- Preview risky requests with `--dry-run` first.
- `~/.lark-cli/config.json` holds a plaintext secret → always `chmod 600`.
- Never commit `~/.lark-cli/` to Git.

---

## Completion self-check

Three signals of a successful setup:
1. `lark-cli --version` produces output.
2. `lark-cli auth status` shows `.identities.user.tokenStatus: valid`.
3. `lark-cli-ensure-auth` exits instantly when the token is valid, and refreshes unattended when it needs it.

All three passing means the CLI connection is ready.
