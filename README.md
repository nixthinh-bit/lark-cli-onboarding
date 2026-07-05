# lark-cli-onboarding

**Tiếng Việt** | [English](./README.en.md)

> **Dán một câu vào Claude Code → làm theo hướng dẫn → điều khiển được Lark/Feishu bằng lời nói.**

![status](https://img.shields.io/badge/status-active-brightgreen)
![platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-blue)
![license](https://img.shields.io/badge/license-MIT-yellow)

Bộ này giúp [Claude Code](https://claude.com/claude-code) điều khiển không gian làm việc **Lark/Feishu** của bạn — đọc mail, tóm tắt họp, quản lý task, gửi tin, tạo tài liệu, thao tác Base — bằng ngôn ngữ tự nhiên, ngay trong terminal. Nó gói sẵn khâu cài đặt + đăng nhập + **tự làm mới token** để bạn không phải đăng nhập lại mỗi 2 giờ.

---

## ✅ Chuẩn bị trước (5 phút)

Chuẩn bị đủ 4 thứ này thì việc cài chỉ còn là dán 1 câu rồi làm theo:

| # | Cần có | Ghi chú |
|---|--------|---------|
| 1 | **Claude Pro trở lên + đã cài Claude Code** | Claude Code là CLI chạy trong terminal — [cài tại đây](https://claude.com/claude-code). Đăng nhập bằng tài khoản Claude Pro. |
| 2 | **Node.js ≥ 18** (kèm `npm`) | Kiểm tra: `node -v`. Chưa có thì tải bản **LTS** ở [nodejs.org](https://nodejs.org). macOS/Linux; Windows dùng WSL. |
| 3 | **Một app Feishu/Lark đã được admin duyệt** | Bạn (hoặc admin) tạo app ở console, lấy **App ID + App Secret**, **bật "long-lived refresh_token"**. Nếu bạn không phải admin → nhờ admin tạo/duyệt và cấp quyền (scope). Chi tiết Claude sẽ dẫn từng bước. |
| 4 | **Điện thoại đã đăng nhập sẵn app Lark/Feishu** | Để **quét QR** duyệt đăng nhập trong 10 giây, khỏi loay hoay browser trên máy tính. |

> ⚠️ App Secret = mật khẩu. Chỉ lưu trên máy bạn, **đừng** dán lên chat công khai hay log.

---

## 🚀 Cài đặt — chỉ 1 câu

Mở **Claude Code**, dán đúng câu này rồi Enter:

```
Pull repo https://github.com/nixthinh-bit/lark-cli-onboarding giúp tôi, rồi kết nối lark-cli theo hướng dẫn trong đó.
```

Claude Code sẽ tự: clone repo → chạy `install.sh` (cài CLI + skill + auto-refresh) → rồi **dẫn bạn từng bước**: nhập App ID/Secret, hiện **mã QR để quét bằng điện thoại**, kiểm tra kết nối. Bạn chỉ việc **làm theo** những gì nó hỏi.

Xong thì **khởi động lại Claude Code** một lần để nạp skill + hook mới.

<details>
<summary>Cách thủ công (nếu thích tự chạy lệnh)</summary>

```bash
curl -fsSL https://raw.githubusercontent.com/nixthinh-bit/lark-cli-onboarding/main/install.sh | bash
```

Rồi đăng nhập một lần:
```bash
lark-cli config init --new         # nhập brand + App ID/Secret
lark-cli auth login --recommend    # duyệt OAuth (browser hoặc QR)
```
Gỡ sạch bất cứ lúc nào: `./uninstall.sh` (giữ nguyên credential).
</details>

---

## 💬 Dùng thử

Sau khi cài, cứ nói chuyện tự nhiên trong Claude Code — nó tự gõ `lark-cli` giùm:

> *"Hôm nay tôi có việc gì cần làm?"*
> *"Tóm tắt các mail chưa đọc trong hộp thư."*
> *"Tạo tài liệu tên 'Kế hoạch tuần' và ghi 3 gạch đầu dòng."*
> *"Đăng nhập lark bằng QR."* (khi cần đăng nhập lại)

Muốn chạy tay bằng CLI:
```bash
lark-cli contact +get-user --as user     # xem thông tin của chính mình
lark-cli calendar +agenda  --as user      # lịch hôm nay
```
> Cú pháp: shortcut dùng tiền tố `+` (vd `contact +get-user`).

---

## 🔄 Token & cập nhật tự động

Bộ cài cắm 2 hook `SessionStart` vào `~/.claude/settings.json` (chạy mỗi khi mở Claude Code):

- **Giữ token luôn tươi** — `lark-cli-ensure-auth --quiet` refresh im lặng bằng refresh_token, **không bao giờ tự bật browser**. Token Lark (~2 giờ) tách biệt hoàn toàn với hạn mức Claude.
- **Nhắc cập nhật CLI (mặc định 30 ngày/lần)** — `lark-cli-check-update --quiet` so version đang cài với bản mới nhất trên npm. Giữa các lần kiểm tra nó thoát tức thì, **không gọi mạng**, nên không làm chậm phiên.

Tùy chỉnh bằng biến môi trường (đặt trong `~/.zshrc` hoặc `~/.bashrc`):

| Biến | Mặc định | Tác dụng |
|------|----------|----------|
| `LARK_CLI_AUTO_UPDATE` | `0` (chỉ nhắc) | Đặt `1` để **tự chạy** `npm i -g @larksuite/cli@latest` khi có bản mới, thay vì chỉ thông báo. |
| `LARK_CLI_UPDATE_INTERVAL_DAYS` | `30` | Đổi chu kỳ kiểm tra (vd `7` = mỗi tuần). |

Cập nhật tay bất cứ lúc nào: `npm i -g @larksuite/cli@latest`.

---

## 🤝 Đóng góp & cấu trúc

Hoan nghênh issue/PR. Repo cố tình giữ nhỏ, dễ fork.

```
lark-cli-onboarding/
├── install.sh          # bootstrap idempotent (npm + copy skill/helper + merge hook)
├── uninstall.sh        # gỡ sạch, giữ nguyên credential
└── skills/lark-cli-setup/
    ├── SKILL.md        # Claude Code đọc để dẫn cài đặt & đăng nhập
    └── scripts/
        ├── lark-cli-ensure-auth    # auto-refresh token (đọc .identities.user.tokenStatus)
        └── lark-cli-check-update   # nhắc/tự cập nhật CLI theo chu kỳ
```

**Đừng** commit credential, App Secret, token, hay đường dẫn hạ tầng nội bộ. Sau khi sửa, kiểm cú pháp:
```bash
bash -n install.sh uninstall.sh skills/lark-cli-setup/scripts/*
```

## License

[MIT](./LICENSE) © 2026 nixthinh-bit
