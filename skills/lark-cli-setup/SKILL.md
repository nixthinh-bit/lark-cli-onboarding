---
name: lark-cli-setup
version: 1.0.0
description: "First-time Lark/Feishu CLI connection and token persistence. Guides from zero: install @larksuite/cli, initialize the Feishu/Lark app (appId/appSecret), OAuth login (user identity) or app identity (bot), and deploy a Device Flow token auto-refresh script. Trigger when the user wants to connect lark-cli for the first time, onboard a new teammate, troubleshoot an expired token, set up long-lived auto-refresh, or configure refresh_token."
---

# lark-cli connection & token persistence

This skill covers the full **lark-cli from zero to auto-refresh** flow in five steps: install → app credentials → auth → token-persistence script → verify.

> **Scope**: this skill is CLI-only. MCP integration is out of scope.

---

## Step 1: Install lark-cli

First confirm Node.js ≥ 18: `node --version`. If missing, install Node.js first.

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

## Step 2: Prepare the Feishu/Lark app credentials

You need an `appId` and `appSecret`. **As an AI agent, relay the steps below to the user and wait for them to paste back the App ID / App Secret before continuing.**

**How to get App ID / App Secret** (official FAQ: https://open.larkoffice.com/document/faq/trouble-shooting/how-to-obtain-app-id):

1. Open the developer console for your edition:
   - Feishu (China): https://open.feishu.cn/app
   - Lark (international): https://open.larksuite.com/app
2. **No app yet? Create one:** click **Create custom app**, set a name and icon → create.
3. Open the app → left sidebar → **Credentials & Basic Info**.
4. In **App Credentials**: copy the **App ID**, then reveal/copy the **App Secret**.
5. On the same page under **Security Settings**, **enable "long-lived refresh_token"** (otherwise durable auto-refresh is impossible).
6. Paste the **App ID** and **App Secret** into the chat; the agent supplies them during Step 3 `config init`, or guides the user to type them at the interactive prompt.

> ⚠️ The App Secret is a password: keep it only in `~/.lark-cli/config.json` on the local machine. **Do not** paste it into public channels, logs, or memory.
> If a team app already exists, ask the admin for the App ID/Secret and skip step 2.

---

## Step 3: Initialize configuration

Run:
```bash
lark-cli config init --new
```

**⚠️ Blocking command**: this blocks until the user completes browser authorization or it expires. When running it on the user's behalf as an AI agent, start it **in the background**, then extract the authorization link from stdout and send it to the user.

The interactive prompt asks for:
- `brand`: `feishu` (China) or `lark` (international)
- `appId` / `appSecret`
- `lang`: defaults to `zh` (use `en` if preferred)

The config is stored at `~/.lark-cli/config.json`. **Set file permissions immediately:**
```bash
chmod 600 ~/.lark-cli/config.json
```

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

**When acting as an AI agent**: start it in the background too, grab the authorization URL from the output, and send it to the user. Scopes from multiple logins accumulate (incremental authorization).

### QR-code authorization (recommended for non-terminal / remote users)

When you don't want the user logging in via a desktop browser, use Device Flow + a QR code so they **scan and approve with the Lark/Feishu app on their phone**:

```bash
# 1) Start Device Flow, get device_code + verification_url (non-blocking)
OUT=$(lark-cli auth login --recommend --no-wait --json)
URL=$(echo "$OUT" | python3 -c "import sys,json;d=json.load(sys.stdin);print(d.get('verification_url',d.get('verificationUrl','')))")
CODE=$(echo "$OUT" | python3 -c "import sys,json;d=json.load(sys.stdin);print(d.get('device_code',d.get('deviceCode','')))")

# 2) Generate the QR: ASCII to stdout, or PNG to a file to send to the user
lark-cli auth qrcode "$URL" --ascii              # shows in the terminal, scan directly
lark-cli auth qrcode "$URL" --output qr.png      # or save as an image for a remote user

# 3) User scans with the phone Lark app → approves, then poll to complete
lark-cli auth login --device-code "$CODE" --json
```

**AI agent**: send the ASCII QR (or PNG) as your final turn message and end the turn; after the user confirms they scanned it, complete with `--device-code`. `lark-cli-ensure-auth` (interactive mode) already does this: on expiry it prints the QR and opens the browser.

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
