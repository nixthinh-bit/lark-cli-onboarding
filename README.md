# lark-cli-onboarding

**Tiếng Việt** | [English](./README.en.md)

> **Dán một câu vào Claude Code → làm theo hướng dẫn → điều khiển được Lark/Feishu bằng lời nói.**

![status](https://img.shields.io/badge/status-active-brightgreen)
![platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-blue)
![license](https://img.shields.io/badge/license-MIT-yellow)

Bộ này giúp [Claude Code](https://claude.com/claude-code) điều khiển không gian làm việc **Lark/Feishu** của bạn — đọc mail, tóm tắt họp, quản lý task, gửi tin, tạo tài liệu, thao tác Base — bằng ngôn ngữ tự nhiên, ngay trong terminal. Nó gói sẵn khâu cài đặt + đăng nhập + **tự làm mới token** để bạn không phải đăng nhập lại mỗi 2 giờ.

---

## ✅ Chuẩn bị trước (5 phút)

Thật ra chỉ cần **2 thứ bắt buộc** — phần còn lại (Node.js, python3) Claude sẽ tự cài giúp bạn ngay trong terminal:

| # | Cần có | Ghi chú |
|---|--------|---------|
| 1 | **Claude Pro trở lên + đã cài Claude Code** | Claude Code là CLI chạy trong terminal — [cài tại đây](https://claude.com/claude-code). Đăng nhập bằng tài khoản Claude Pro. |
| 2 | **Một app Feishu/Lark** (bạn tự tạo được, 2 phút) | Bấm thẳng vào console — Lark quốc tế: **[→ Tạo custom app (open.larksuite.com)](https://open.larksuite.com/app)** · Feishu (TQ): **[→ Tạo custom app (open.feishu.cn)](https://open.feishu.cn/app)** → **Create custom app** → lấy **App ID + App Secret** → bật **"long-lived refresh_token"**. Claude dẫn bạn **từng bước bấm gì**. ⚠️ **Không phải admin?** App tự tạo thường phải **chờ admin tenant duyệt/bật** (và duyệt scope) thì mới đăng nhập được — nhờ admin duyệt trước; đây là bước chờ nằm ngoài tầm bạn. Công ty đã có app sẵn → xin admin App ID/Secret. |
| 3 | *(khuyến nghị)* **Điện thoại đã đăng nhập app Lark/Feishu** | Để **quét QR** duyệt đăng nhập trong 10 giây, khỏi loay hoay browser. Không có cũng được — bạn bấm link đăng nhập trên máy. |

**Node.js ≥ 18 & python3:** không cần cài trước. `install.sh` tự phát hiện thiếu và cài qua Homebrew (macOS) / apt / dnf. Máy Mac **chưa có Homebrew**? Vào **[brew.sh](https://brew.sh)** → bấm nút copy (📋) ở ô lệnh mục *"Install Homebrew"* → dán vào terminal, Enter → nhập **mật khẩu máy Mac** (gõ không hiện chữ là bình thường) → xong chạy lại. Claude cũng làm hộ được bước này.

> ⚠️ App Secret = mật khẩu. Chỉ lưu trên máy bạn, **đừng** dán lên chat công khai hay log. Claude không in lại, không lưu vào bộ nhớ.

### Khi cài, bạn sẽ thấy gì (dành cho người không rành kỹ thuật)

- **Pop-up xin phép chạy lệnh** → bấm **Allow once** (Cho phép một lần). Các lệnh ở đây chỉ cài đặt, không xoá dữ liệu, không tốn tiền.
- Claude sẽ tạo sẵn thư mục riêng **`~/Downloads/Claude x Lark`** và làm việc trong đó cho gọn.
- **Nếu có bước hỏi mật khẩu máy** (chỉ khi cài Homebrew): gõ **thẳng vào cửa sổ Terminal của bạn**, **đừng** dán vào khung chat với Claude. Mật khẩu chỉ ở lại trên máy, Claude không thấy. Lưu ý: **gõ mật khẩu sẽ không hiện ký tự** — không phải bị treo, cứ gõ rồi Enter. Bước cần mật khẩu thì bạn **tự chạy trong Terminal**, Claude không chạy hộ được (terminal của Claude không nhập mật khẩu vào được).
- Gần cuối sẽ có **1 bước tay**: bấm link đăng nhập (hoặc quét QR bằng điện thoại) để duyệt quyền. Xong là chạy được.

<details>
<summary>📖 Cách mở Terminal & gõ mật khẩu nào (bấm để xem)</summary>

**Trên macOS**
1. Nhấn `Cmd (⌘)` + `Space` → gõ `Terminal` → Enter. (Hoặc: Finder → Applications → Utilities → Terminal.)
2. **Dán lệnh** được đưa (vd lệnh cài Homebrew copy từ [brew.sh](https://brew.sh)) bằng `Cmd + V` → Enter.
3. Khi thấy dòng `Password:` → gõ **mật khẩu đăng nhập máy Mac** (mật khẩu bạn dùng để mở máy / cài ứng dụng). **Gõ sẽ không hiện gì** — cứ gõ xong rồi Enter. Nếu nó nói `Press RETURN to continue` thì bấm Enter.

**Trên Windows**
> ⚠️ Bộ này chạy trên **WSL (Ubuntu)** — **không** chạy trên PowerShell/CMD thuần (không có bash/apt). Người dùng Windows hãy cài WSL trước rồi làm mọi bước bên trong Ubuntu.
- Claude Code chạy qua **WSL (Ubuntu)**. Mở **Start** → gõ `Ubuntu` (hoặc `WSL`) → Enter. *(Chưa có WSL? Mở **PowerShell** bằng chuột phải → "Run as administrator" → chạy `wsl --install` → khởi động lại máy, đặt username + mật khẩu cho Ubuntu khi được hỏi.)*
- **Dán lệnh** Linux (vd `sudo apt-get update && sudo apt-get install -y nodejs npm python3`) → Enter. *(Dán trong terminal Windows: chuột phải hoặc `Ctrl + Shift + V`.)*
- Khi thấy `[sudo] password for <tên>:` → gõ **mật khẩu người dùng Ubuntu/WSL** (cái bạn đặt lần đầu mở Ubuntu) — **KHÔNG phải** mật khẩu đăng nhập Windows. Gõ cũng không hiện chữ.
- Windows **không có Homebrew** — mọi thứ cài trong Ubuntu bằng `apt` như trên.

> Dù Mac hay Windows: mật khẩu này gõ **thẳng vào Terminal**, không bao giờ dán vào khung chat với Claude.

</details>

---

## 🚀 Cài đặt — chỉ 1 câu

Mở **Claude Code**, dán đúng câu này rồi Enter:

```
Pull repo https://github.com/nixthinh-bit/lark-cli-onboarding giúp tôi, rồi kết nối lark-cli theo hướng dẫn trong đó.
```

Claude Code sẽ tự: cài các thứ còn thiếu (Node.js/python qua Homebrew/apt) → clone repo → chạy `install.sh` (cài CLI + skill + auto-refresh) → rồi **dẫn bạn từng bước**: cách tạo custom app + lấy App ID/Secret, hiện **link đăng nhập bấm-là-vào** kèm **QR ảnh nét để quét bằng điện thoại**, kiểm tra kết nối. Bạn chỉ việc **làm theo** những gì nó hỏi và bấm **Allow once** khi được hỏi.

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
