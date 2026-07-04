# lark-cli-onboarding

**Tiếng Việt** | [English](./README.en.md)

> **Gửi một link — người nhận chạy một lệnh — Claude Code điều khiển được Lark/Feishu.**

![status](https://img.shields.io/badge/status-active-brightgreen)
![platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-blue)
![license](https://img.shields.io/badge/license-MIT-yellow)

## Giới thiệu

`lark-cli-onboarding` là một bộ cài **một lệnh** giúp [Claude Code](https://claude.com/claude-code) điều khiển không gian làm việc **Lark/Feishu** của bạn — đọc mail, tóm tắt cuộc họp, quản lý task, gửi tin nhắn, tạo tài liệu, thao tác Base — bằng ngôn ngữ tự nhiên, ngay trong terminal.

**Vấn đề nó giải quyết:** [`@larksuite/cli`](https://github.com/larksuite/cli) chính thống rất mạnh (200+ lệnh) nhưng để một người mới dùng được cần: cài đúng, tạo app lấy credential, đăng nhập OAuth, và token user hết hạn mỗi ~2 giờ. `lark-cli-onboarding` gói toàn bộ khâu thiết lập đó lại — **clone → `./install.sh` → xong** — kèm cơ chế **tự làm mới token** để không phải đăng nhập lại liên tục.

Khác với cách dùng MCP: repo này để Claude Code **chạy thẳng `lark-cli` qua Bash** (không cần MCP server), nên luôn dùng được **toàn bộ** lệnh của CLI và CLI luôn ở bản mới nhất.

## Tính năng nổi bật

- 🚀 **Cài một lệnh** — `install.sh` lo hết: cài CLI, skill, helper, hook.
- 🔄 **Token tự làm mới** — hook `SessionStart` của Claude Code refresh token im lặng mỗi phiên, **không bao giờ tự bật trình duyệt**.
- 📱 **Đăng nhập bằng QR** — quét mã bằng app Lark/Feishu trên điện thoại, khỏi cần đăng nhập trên desktop.
- 🧠 **Skill dẫn đường** — gõ *"kết nối giúp tôi lark-cli"* trong Claude Code, skill `lark-cli-setup` hướng dẫn từng bước.
- 🆕 **Luôn mới nhất** — cài `@larksuite/cli@latest` từ npm; cập nhật chỉ là `npm update`.
- 🔐 **An toàn mặc định** — credential lưu cục bộ (`chmod 600`), ưu tiên `--dry-run` cho thao tác ghi, repo không chứa secret.
- ♻️ **Idempotent** — chạy lại `install.sh` không nhân đôi hook hay cấu hình.

## Cài đặt

### Yêu cầu
- macOS hoặc Linux (Windows dùng WSL)
- [Node.js](https://nodejs.org) ≥ 18, `npm`, `python3`
- Một ứng dụng Feishu/Lark (App ID + App Secret) — hướng dẫn lấy ở [bước 2](#2-lấy-app-id--app-secret-một-lần)

### 1. Chạy bộ cài

```bash
git clone https://github.com/nixthinh-bit/lark-cli-onboarding.git
cd lark-cli-onboarding
./install.sh
```

Hoặc một dòng:

```bash
curl -fsSL https://raw.githubusercontent.com/nixthinh-bit/lark-cli-onboarding/main/install.sh | bash
```

> 💡 Nên đọc `install.sh` trước khi chạy (nhất là với `curl | bash`) — script ngắn, minh bạch.

`install.sh` sẽ: cài `@larksuite/cli@latest` → cài skill vào `~/.claude/skills` → cài helper vào `~/.local/bin` → cắm hook auto-refresh vào `~/.claude/settings.json`. Gỡ bất cứ lúc nào bằng `./uninstall.sh`.

### 2. Lấy App ID / App Secret (một lần)

> Tham khảo FAQ chính thức: <https://open.larkoffice.com/document/faq/trouble-shooting/how-to-obtain-app-id>

1. Mở developer console theo phiên bản:
   - Feishu (bản Trung): <https://open.feishu.cn/app>
   - Lark (quốc tế): <https://open.larksuite.com/app>
2. Chưa có app thì bấm **Create custom app / 创建企业自建应用** → đặt tên, icon → tạo.
3. Vào app → menu trái → **Credentials & Basic Info / 凭证与基础信息**.
4. Copy **App ID**, rồi bấm hiện/copy **App Secret**.
5. Cùng trang, mục **Security Settings**: **bật "long-lived refresh_token"** (bắt buộc để token tự tươi lâu dài).

> ⚠️ App Secret = mật khẩu. Chỉ lưu ở `~/.lark-cli/config.json` trên máy bạn; **đừng** dán lên kênh công khai/log.

### 3. Đăng nhập một lần

```bash
lark-cli config init --new         # nhập brand + App ID/Secret
lark-cli auth login --recommend    # duyệt OAuth (browser hoặc QR — xem phần Sử dụng)
```

Không quen terminal? Mở Claude Code và gõ *"kết nối giúp tôi lark-cli"* — skill sẽ dẫn cả 3 bước trên. Xong nhớ **restart Claude Code**.

## Sử dụng

### Trong Claude Code
Sau khi cài, chỉ cần nói chuyện tự nhiên — Claude Code tự gõ `lark-cli` giùm:

> *"Hôm nay tôi có việc gì cần làm?"*
> *"Tóm tắt các mail chưa đọc trong hộp thư."*
> *"Tạo một tài liệu tên 'Kế hoạch tuần' và ghi 3 gạch đầu dòng."*

### Chạy trực tiếp bằng CLI

```bash
lark-cli contact +get-user --as user        # xem thông tin của chính mình
lark-cli calendar +agenda --as user         # lịch hôm nay
lark-cli im send --to "<chat_id>" --text "hello" --as bot
```

> Lưu ý cú pháp: các shortcut dùng tiền tố `+` (vd `contact +get-user`), không phải `contact get-user`.

### Đăng nhập bằng QR (tiện cho người ở xa)

```bash
OUT=$(lark-cli auth login --recommend --no-wait --json)
URL=$(echo "$OUT" | python3 -c "import sys,json;print(json.load(sys.stdin).get('verification_url',''))")
CODE=$(echo "$OUT" | python3 -c "import sys,json;print(json.load(sys.stdin).get('device_code',''))")

lark-cli auth qrcode "$URL" --ascii          # in QR ra terminal để quét
# hoặc: lark-cli auth qrcode "$URL" --output qr.png

# mở app Lark/Feishu trên điện thoại → quét → đồng ý, rồi hoàn tất:
lark-cli auth login --device-code "$CODE" --json
```

Trong Claude Code, chỉ cần nói *"đăng nhập lark bằng QR"*.

### Token & auto-refresh

- Hook `SessionStart` chạy `lark-cli-ensure-auth --quiet` mỗi phiên → refresh im lặng bằng refresh_token, không bật browser.
- Chạy tay bất cứ lúc nào: `lark-cli-ensure-auth` (không cờ) → nếu cần sẽ hiện QR + mở browser để đăng nhập lại.
- Token **Lark** (miễn phí, ~2 giờ) tách biệt hoàn toàn với hạn mức **Claude** (gói Pro, cửa sổ 5 giờ) — hook này chỉ lo token Lark.

## Đóng góp

Rất hoan nghênh issue và PR. Repo cố tình giữ nhỏ và dễ đọc để ai cũng fork/tùy biến được.

### Cấu trúc

```
lark-cli-onboarding/
├── install.sh          # bootstrap idempotent (npm + copy skill/helper + merge hook)
├── uninstall.sh        # gỡ sạch, giữ nguyên credential
└── skills/lark-cli-setup/
    ├── SKILL.md        # Claude Code đọc để dẫn cài đặt & đăng nhập
    ├── INSTALL.md
    └── scripts/lark-cli-ensure-auth   # helper auto-refresh (đọc .identities.user.tokenStatus)
```

### Mẹo phát triển
- **Đổi/thêm hành vi cài** → sửa `install.sh`; luôn giữ tính idempotent (merge, đừng append mù).
- **Sửa helper token** → nhớ CLI ≥ 1.0.5x đặt trạng thái ở `.identities.user.tokenStatus` (không còn top-level `.tokenStatus`); `--quiet` phải tuyệt đối không mở browser.
- **Muốn chạy trên Codex CLI** → Codex cũng hỗ trợ Skills + hook `SessionStart` nhưng ở `~/.codex/` (config TOML), không phải `~/.claude/`. Cần thêm nhánh dò `~/.codex` trong `install.sh` để copy đúng chỗ. PR cho phần này rất được chào đón.
- Sau khi sửa, kiểm cú pháp: `bash -n install.sh uninstall.sh skills/lark-cli-setup/scripts/lark-cli-ensure-auth`.

### Báo lỗi / gửi PR
1. Mở [issue](https://github.com/nixthinh-bit/lark-cli-onboarding/issues) mô tả môi trường (OS, `node -v`, `lark-cli --version`) và bước tái hiện.
2. Fork → nhánh tính năng → commit rõ ràng → mở Pull Request.
3. **Đừng** commit credential, App Secret, token, hay đường dẫn hạ tầng nội bộ.

## License

[MIT](./LICENSE) © 2026 nixthinh-bit
