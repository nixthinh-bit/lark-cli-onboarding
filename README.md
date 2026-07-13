# lark-cli-onboarding

**Tiếng Việt** | [English](./README.en.md)

> **Dán một câu vào Claude Code → trả lời vài câu hỏi → điều khiển được Lark/Feishu bằng lời nói.**

![status](https://img.shields.io/badge/status-active-brightgreen)
![platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-blue)
![license](https://img.shields.io/badge/license-MIT-yellow)

Bộ này giúp [Claude Code](https://claude.com/claude-code) điều khiển không gian làm việc **Lark/Feishu** của bạn — đọc mail, tóm tắt họp, quản lý task, gửi tin, tạo tài liệu, thao tác Base — bằng ngôn ngữ tự nhiên, ngay trong terminal. Nó gói sẵn khâu cài đặt + đăng nhập + **tự làm mới token** để bạn không phải đăng nhập lại mỗi 2 giờ.

> 🙋 **Không rành kỹ thuật?** Bạn **không cần nhớ lệnh nào**. Chỉ cần dán 1 câu ở [Bước 1](#-cài-đặt--chỉ-1-câu), rồi trả lời câu hỏi của Claude và bấm **Allow once**. Phần [Sẽ diễn ra thế nào](#-sẽ-diễn-ra-thế-nào--từng-bước) mô tả đúng những gì bạn sẽ thấy.

---

## ✅ Chuẩn bị trước (5 phút)

Thật ra chỉ cần **2 thứ bắt buộc** — phần còn lại Claude tự lo:

| # | Cần có | Ghi chú |
|---|--------|---------|
| 1 | **Claude Pro trở lên + đã cài Claude Code** | Claude Code là CLI chạy trong terminal — [cài tại đây](https://claude.com/claude-code). Đăng nhập bằng tài khoản Claude Pro. |
| 2 | **Một app Feishu/Lark** (tự tạo 2 phút) | Claude sẽ dẫn bạn tạo ở [Bước 3](#-sẽ-diễn-ra-thế-nào--từng-bước). Công ty đã có app sẵn → xin admin **App ID + App Secret**. |

*Tùy chọn:* **điện thoại đã đăng nhập app Lark/Feishu** để **quét QR** đăng nhập cho nhanh (không có cũng được — bấm link trên máy).

**Node.js & python3:** không cần cài trước — Claude tự phát hiện thiếu và cài giúp (qua Homebrew trên macOS, hoặc apt/dnf trên Linux). Nếu máy Mac chưa có Homebrew, xem mục [📖 Cách mở Terminal & gõ mật khẩu](#-khi-cài-bạn-sẽ-thấy-gì).

> ⚠️ App Secret = mật khẩu. Chỉ lưu trên máy bạn, **đừng** dán lên chat công khai hay log. Claude không in lại, không lưu vào bộ nhớ.

---

## 🚀 Cài đặt — chỉ 1 câu

Mở **Claude Code**, dán đúng câu này rồi Enter:

```
Pull repo https://github.com/nixthinh-bit/lark-cli-onboarding giúp tôi, rồi kết nối lark-cli theo hướng dẫn trong đó.
```

Đó là tất cả những gì bạn cần gõ. Từ đây Claude dẫn bạn đi — xem chi tiết bên dưới.

---

## 🧭 Sẽ diễn ra thế nào — từng bước

Mỗi bước ghi rõ: **🗣️ bạn đưa gì vào**, **🤖 Claude hỏi lại gì**, **✅ bạn nhận được gì**, và **✂️ nếu không cần thì nói gì**.

### Bước 1 — Khởi động
- 🗣️ **Bạn dán** câu lệnh ở trên.
- 🤖 **Claude hỏi:** Bạn dùng **Lark quốc tế** hay **Feishu (Trung Quốc)**? Đã có app Lark chưa hay cần tạo mới?
- ✅ **Bạn thấy:** Claude tóm tắt các bước sắp làm, rồi xin phép chạy lệnh → bấm **Allow once**.

### Bước 2 — Chuẩn bị máy *(tự động)*
- 🤖 Claude kiểm tra Node.js/python; nếu thiếu thì xin phép cài.
- ✅ **Bạn thấy:** `✓ Prerequisites OK — node …`
- ✂️ **Máy đã có sẵn?** Claude tự bỏ qua, bạn không phải làm gì.

### Bước 3 — Tạo app Lark & lấy App ID/Secret *(bước tay)*
- 🤖 **Claude gửi bạn link bấm-là-vào console** + chỉ từng bước: bấm **Create custom app** → mở **Credentials & Basic Info** → copy **App ID** (`cli_…`) và **App Secret** (bấm con mắt để hiện) → bật **long-lived refresh_token**.
- 🗣️ **Bạn dán lại** App ID + App Secret vào khung chat.
- ⏳ **Nếu bạn KHÔNG phải admin:** app tự tạo thường phải **chờ admin tenant duyệt** mới đăng nhập được. Claude sẽ **tạm dừng** — bạn nhờ admin duyệt rồi quay lại. Đây là bước chờ nằm ngoài tầm bạn.

### Bước 4 — Đăng nhập *(bước tay)*
- 🤖 Claude gửi **[👉 link đăng nhập bấm-là-vào]** kèm **ảnh QR nét vừa mở sẵn** để quét bằng điện thoại.
- 🗣️ **Bạn:** bấm link (hoặc quét QR) → duyệt trong app Lark → nhắn lại **"done"**.
- ✅ **Bạn thấy:** `tokenStatus: valid`.

### Bước 5 — Kiểm tra
- ✅ Claude chạy thử và in thông tin của bạn → kết nối OK. Nhắc **khởi động lại Claude Code** một lần để nạp skill + hook.

### Bước 6 — *(Tùy chọn)* Bộ skill Lark chính thức
- 🤖 Claude hỏi: *"Cài thêm ~27 skill chính thức (Base / Docs / Mail / Calendar / IM…) để mình thao tác được không? Nó thêm vào skills toàn cục của bạn."*
- ✅ Đồng ý → có ngay khả năng thao tác Base, Docs, Mail… bằng lời. (Xem [mục skill](#-bộ-skill-lark-chính-thức-khuyến-nghị-tùy-chọn).)

---

### ✂️ "Tôi không cần hết mọi thứ" — nói ở đâu, lúc nào

Cứ nói bằng lời bình thường, Claude sẽ thu hẹp lại:

| Bạn muốn | Nói lúc nào | Nói gì (ví dụ) |
|---|---|---|
| Chỉ vài chức năng (vd chỉ mail) | Bước 1, hoặc khi Claude trình kế hoạch | *"Tôi chỉ cần đọc & tóm tắt mail, không cần Base/Sheets"* |
| Không cài đủ 27 skill toàn cục | Bước 6, khi Claude hỏi | *"Không cài skill pack"* — hoặc *"chỉ cài lark-mail, lark-calendar"* |
| Không muốn tự động nhắc cập nhật | Bất cứ lúc nào | *"Tắt nhắc cập nhật CLI giúp tôi"* (Claude gỡ hook check-update) |
| Đã có sẵn app / Node | Bước 1 | *"Máy tôi có Node rồi; app Lark cũng có sẵn App ID/Secret"* |

---

## 👀 Khi cài, bạn sẽ thấy gì

- **Pop-up xin phép chạy lệnh** → bấm **Allow once** (Cho phép một lần). Các lệnh ở đây chỉ cài đặt, **không xoá dữ liệu, không tốn tiền**.
- Claude tạo sẵn thư mục riêng **`~/Downloads/Claude x Lark`** và làm việc trong đó cho gọn.
- **Nếu có bước hỏi mật khẩu máy** (chỉ khi cần cài Homebrew/Node): gõ **thẳng vào cửa sổ Terminal**, **đừng** dán vào khung chat. Mật khẩu chỉ ở lại trên máy, Claude không thấy — và **gõ sẽ không hiện ký tự** (không phải treo, cứ gõ rồi Enter). Bước cần mật khẩu bạn **tự chạy trong Terminal** (terminal của Claude không nhập mật khẩu được).

<details>
<summary>📖 Cách mở Terminal & gõ mật khẩu nào (bấm để xem)</summary>

**Trên macOS**
1. Nhấn `Cmd (⌘)` + `Space` → gõ `Terminal` → Enter. (Hoặc: Finder → Applications → Utilities → Terminal.)
2. **Dán lệnh** được đưa (vd lệnh cài Homebrew copy từ [brew.sh](https://brew.sh) — bấm nút copy 📋 ở ô *"Install Homebrew"*) bằng `Cmd + V` → Enter.
3. Khi thấy `Password:` → gõ **mật khẩu đăng nhập máy Mac** (mật khẩu mở máy / cài app). **Gõ không hiện gì** — cứ gõ xong Enter. Nếu nó nói `Press RETURN to continue` thì bấm Enter.

**Trên Windows**
> ⚠️ Bộ này chạy trên **WSL (Ubuntu)** — **không** chạy trên PowerShell/CMD thuần (không có bash/apt). Người dùng Windows hãy cài WSL trước rồi làm mọi bước bên trong Ubuntu.
- Mở **Start** → gõ `Ubuntu` (hoặc `WSL`) → Enter. *(Chưa có WSL? Mở **PowerShell** bằng chuột phải → "Run as administrator" → chạy `wsl --install` → khởi động lại máy, đặt username + mật khẩu cho Ubuntu khi được hỏi.)*
- **Dán lệnh** Linux → Enter *(dán trong terminal Windows: chuột phải hoặc `Ctrl + Shift + V`)*.
- Khi thấy `[sudo] password for <tên>:` → gõ **mật khẩu người dùng Ubuntu/WSL** (đặt lần đầu mở Ubuntu) — **KHÔNG phải** mật khẩu đăng nhập Windows. Cũng không hiện chữ.
- Windows **không có Homebrew** — mọi thứ cài trong Ubuntu bằng `apt`.

> Dù Mac hay Windows: mật khẩu gõ **thẳng vào Terminal**, không bao giờ dán vào khung chat với Claude.

</details>

<details>
<summary>⌨️ Cách thủ công (nếu thích tự chạy lệnh)</summary>

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
- **Nhắc cập nhật CLI (mặc định 30 ngày/lần)** — `lark-cli-check-update --quiet` so version đang cài với bản mới nhất. Giữa các lần kiểm tra nó thoát tức thì, **không gọi mạng**, nên không làm chậm phiên.

Tùy chỉnh bằng biến môi trường (đặt trong `~/.zshrc` hoặc `~/.bashrc`):

| Biến | Mặc định | Tác dụng |
|------|----------|----------|
| `LARK_CLI_AUTO_UPDATE` | `0` (chỉ nhắc) | Đặt `1` để **tự cập nhật** (chạy `lark-cli update`, dự phòng `npm`) khi có bản mới, thay vì chỉ thông báo. |
| `LARK_CLI_UPDATE_INTERVAL_DAYS` | `30` | Đổi chu kỳ kiểm tra (vd `7` = mỗi tuần). |

Cập nhật tay bất cứ lúc nào: **`lark-cli update`** (lệnh built-in, độc lập cách cài) — hoặc `npm i -g @larksuite/cli@latest`.

---

## 🧩 Bộ skill Lark chính thức (khuyến nghị, tùy chọn)

`@larksuite/cli` có sẵn **~27 "agent skill" chính thức** (`lark-base`, `lark-doc`, `lark-sheets`, `lark-mail`, `lark-calendar`, `lark-im`, `lark-drive`, `lark-task`, `lark-wiki`…) — đây mới là thứ giúp Claude **thao tác thật** với Lark, không chỉ đăng nhập. Repo này cố tình **không tự cài** chúng (chúng nằm ở `~/.claude/skills` **toàn cục**, ảnh hưởng mọi project) — bạn tự quyết:

```bash
npx skills add larksuite/cli -g -y      # cài, rồi khởi động lại Claude Code
lark-cli skills list                     # xem đã có skill nào
```

> Các skill này **đã nằm sẵn trong gói `@larksuite/cli`**; lệnh trên chỉ **sao chúng ra `~/.claude/skills/`** để Claude tự phát hiện, **không tải gì mới**. Claude Code cũng sẽ **hỏi bạn** bước này ở [Bước 6](#-sẽ-diễn-ra-thế-nào--từng-bước).
>
> **Định vị:** repo này lo **prereq tự động + auto-refresh token + onboarding no-code**; bộ skill chính thức lo **thao tác Base/Docs/Mail…** — hai thứ bổ sung cho nhau.

---

## 🤝 Đóng góp & cấu trúc

Hoan nghênh issue/PR. Repo cố tình giữ nhỏ, dễ fork.

```
lark-cli-onboarding/
├── install.sh          # bootstrap idempotent (prereq + npm + copy skill/helper + merge hook)
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
