---
name: lark-cli-setup
version: 1.0.0
description: "飞书/Lark CLI 首次连接与 Token 持久化。从零引导：安装 @larksuite/cli、初始化飞书应用（appId/appSecret）、OAuth 授权登录（user 身份）或应用身份（bot）、部署 Device Flow Token 自动刷新脚本。当用户要第一次接入 lark-cli、给新同事做 onboarding、排查 token 过期、想搭建长期自动刷新、配置 refresh_token 时触发。"
---

# lark-cli 连接与 Token 持久化

本技能覆盖 **lark-cli 从零到自动刷新** 的完整流程。分五步：安装 → 应用凭据 → 认证 → Token 持久化脚本 → 验证。

> **范围限定**：本技能只讲 CLI。MCP 接入方式不在范围内。

---

## Step 1: 安装 lark-cli

先确认 Node.js ≥ 18：`node --version`。若无，需先安装 Node.js。

```bash
# 公网 registry
npm install -g @larksuite/cli

# 若所在组织有私有 npm registry，可自行指定 --registry <your-registry-url>
```

验证：
```bash
lark-cli --version   # 预期: lark-cli version 1.x.x
```

---

## Step 2: 准备飞书应用凭据

需要拿到 `appId` 和 `appSecret`：

- **已有团队应用**：可直接复用团队已建好的自建应用（向管理员索取 App ID/Secret）
- **新建应用**：https://open.feishu.cn → 开发者后台 → 创建"企业自建应用" → 凭证与基础信息页拿 App ID / App Secret

**应用必须在后台开启"长期 refresh_token"**（凭证与基础信息 → 安全设置），否则 Token 持久化无从谈起。

---

## Step 3: 初始化配置

运行：
```bash
lark-cli config init --new
```

**⚠️ 阻塞命令**：该命令会阻塞直到用户完成浏览器授权或过期。作为 AI agent 代为执行时，必须 **以 background 方式启动**，然后从 stdout 提取授权链接发给用户。

交互式提示会要求输入：
- `brand`: `feishu`（中国版）或 `lark`（国际版）
- `appId` / `appSecret`
- `lang`: 默认 `zh`

配置文件存于 `~/.lark-cli/config.json`。**立即设置文件权限**：
```bash
chmod 600 ~/.lark-cli/config.json
```

---

## Step 4: 认证登录

### 身份模型

两种身份，通过 `--as` 切换：

| 身份 | 获取方式 | 适用 |
|------|---------|------|
| `--as user` | 走 `auth login`，需浏览器授权 | 访问用户自己的日历、云空间、IM、邮箱 |
| `--as bot` | 无需 login，仅 appId + appSecret | 应用级操作，访问 bot 自己的资源 |

**关键差异**：
- Bot 看不到用户资源（查日程返回 bot 自己的空日历）
- Bot 无法代表用户操作（发消息以应用名义，创建文档归属 bot）
- User scope 需后台开通 + 用户 `auth login` 双重满足
- **禁止对 bot 执行 `auth login`**

### User 授权（三选一）

推荐 scope（一次授权常用集合）：
```bash
lark-cli auth login --recommend
```

具体 scope（最小权限）：
```bash
lark-cli auth login --scope "calendar:calendar:readonly docx:document:readonly"
```

整个业务域：
```bash
lark-cli auth login --domain calendar
```

**AI agent 代为操作**：同样 background 方式启动，从输出抓授权 URL 发给用户。多次 login 的 scope 会累积（增量授权）。

### 查看状态

```bash
lark-cli auth status
```

返回 JSON，关注 `tokenStatus`（`valid` / `expired` / `invalid`）和 `expiresAt`。

---

## Step 5: 部署 Token 自动刷新脚本

User token 有效期约 2 小时。定时任务/后台 agent 场景需自动刷新。本 skill 附带 `lark-cli-ensure-auth`，基于 Device Flow 实现无人值守刷新。

### 安装

```bash
# 1. 创建目录（如不存在）
mkdir -p ~/.local/bin

# 2. 从 skill 拷贝脚本（路径按 skill 安装位置替换）
cp ~/.claude/skills/lark-cli-setup/scripts/lark-cli-ensure-auth ~/.local/bin/
chmod +x ~/.local/bin/lark-cli-ensure-auth

# 3. 确保 PATH 包含 ~/.local/bin
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc  # bash 用户改 ~/.bashrc
source ~/.zshrc
```

### 使用

```bash
# 每次飞书操作前调用，保证 token 可用
lark-cli-ensure-auth           # 详细输出
lark-cli-ensure-auth --quiet   # 静默模式，仅失败时报

# 也可作为 cron / 定时任务的 pre-hook
```

### 脚本逻辑

1. 调用 `lark-cli auth status` 检查 token
2. `valid` → 立即退出 0
3. 过期 → `lark-cli auth login --recommend --no-wait --json` 拿 `deviceCode` + `verificationUrl`
4. `open "$VERIFY_URL"` 自动打开浏览器
5. 每 3 秒轮询 `lark-cli auth login --device-code ... --json`，最多 90 秒
6. 成功 0 / 超时 1

前提：应用已开启 refresh_token（见 Step 2）。

---

## 验证连接

```bash
# User 身份：读自己的信息
lark-cli contact get-user --as user

# User 身份：列日历
lark-cli calendar +agenda --as user

# Bot 身份：发消息
lark-cli im send --to "<chat_id>" --text "hello" --as bot
```

每条命令输出开头会打印 `[identity: bot/user]`，用以确认当前身份。

---

## 权限不足排查

错误响应会带关键字段：

| 字段 | 含义 |
|------|------|
| `permission_violations` | 缺失的 scope 列表（N 选 1 即可满足） |
| `console_url` | 飞书开放平台对应应用的权限配置页 |
| `hint` | 建议的修复命令 |

**Bot 身份报错**：把 `console_url` 发给用户，引导在开放平台开通 scope。不要跑 `auth login`。

**User 身份报错**：
```bash
lark-cli auth login --scope "<missing_scope>"
```

---

## 安全规则

- **禁止**在终端、日志、memory 中明文输出 `appSecret` / `accessToken` / `refreshToken`
- **写入/删除**操作前必须二次确认用户意图
- 危险请求先用 `--dry-run` 预览
- `~/.lark-cli/config.json` 含明文 secret → 务必 `chmod 600`
- 不要把 `~/.lark-cli/` 提交到 Git

---

## 完成度自检

安装成功的三个信号：
1. `lark-cli --version` 有输出
2. `lark-cli auth status` 返回 `tokenStatus: valid`
3. `lark-cli-ensure-auth` 在 token 有效时秒退，过期时能无人值守刷新

三点都通过，CLI 连接就 ready 了。
