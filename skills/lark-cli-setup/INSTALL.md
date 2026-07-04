# lark-cli-setup Skill — 安装指南

这是一个 Claude Code skill，帮你从零把飞书 CLI（`@larksuite/cli`）配好并实现 Token 长期自动刷新。

## 安装（macOS / Linux）

```bash
# 1. 拷贝 skill 到 Claude Code 用户级 skills 目录
mkdir -p ~/.claude/skills
cp -r lark-cli-skill ~/.claude/skills/lark-cli-setup

# 2. 确保脚本可执行
chmod +x ~/.claude/skills/lark-cli-setup/scripts/lark-cli-ensure-auth

# 3. 重启 Claude Code（或在新 session 中）让 skill 被加载
```

## 怎么用

装好之后，直接跟 Claude 说类似的话：

- "帮我连接飞书 CLI"
- "我 token 又过期了，帮我搭一个自动刷新"
- "onboarding 一下飞书 CLI"

Claude 会识别触发条件，按 skill 里的步骤把你带完 5 步：

1. 安装 `@larksuite/cli`
2. 准备飞书应用凭据（appId / appSecret）
3. `lark-cli config init --new` 配置
4. `lark-cli auth login --recommend` 授权
5. 部署 `lark-cli-ensure-auth` 自动刷新脚本

## 目录结构

```
lark-cli-setup/
├── SKILL.md                        # skill 主文件（Claude 读取）
├── INSTALL.md                      # 本文件（人类读取）
└── scripts/
    └── lark-cli-ensure-auth        # Token 自动刷新脚本（Device Flow）
```

## 前置条件

- macOS 或 Linux
- Node.js ≥ 18
- 飞书应用凭据（App ID + App Secret）
  - 已有团队应用：向管理员索取，或复用团队已建好的自建应用
  - 新建应用：https://open.feishu.cn 创建自建应用
- 应用后台**开启"长期 refresh_token"**（否则无法实现长期自动刷新）

## 遇到问题

- Token 总过期 → 确认应用开启了 refresh_token
- `permission denied` → 按 SKILL.md 里"权限不足排查"章节处理
- `lark-cli` 找不到 → 检查 `which lark-cli`，必要时把 `/opt/homebrew/bin` 或 `npm config get prefix` 对应的 bin 目录加入 PATH
