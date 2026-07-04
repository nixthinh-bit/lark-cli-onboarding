# lark-cli-onboarding

**Gửi 1 link → người nhận chạy 1 lệnh → Claude Code điều khiển được Lark/Feishu.**

Đây là phiên bản "chia sẻ bằng link" của cách kết nối Lark **qua CLI + Bash** (không dùng MCP). Nó đóng gói:

- Bản CLI chính thống **`@larksuite/cli`** (cài mới nhất từ npm),
- Skill **`lark-cli-setup`** để Claude Code tự dẫn/tự chạy quy trình cài,
- Helper **`lark-cli-ensure-auth`** giữ token user luôn tươi,
- Một **hook SessionStart** của Claude Code tự refresh token mỗi phiên — **không bao giờ bật trình duyệt ngầm**.

Sau khi cài, bạn làm việc với Lark ngay trong Claude Code: nó **tự gõ lệnh `lark-cli …` qua Bash** rồi đọc kết quả. Không cần MCP server.

---

## Cài đặt

```bash
git clone https://github.com/<owner>/lark-cli-onboarding.git
cd lark-cli-onboarding
./install.sh
```

Hoặc một dòng (khi repo đã public):

```bash
curl -fsSL https://raw.githubusercontent.com/<owner>/lark-cli-onboarding/main/install.sh | bash
```

Gỡ: `./uninstall.sh`

## Yêu cầu

- macOS hoặc Linux
- Node.js ≥ 18, `python3`
- Một ứng dụng Feishu/Lark (App ID + App Secret) đã **bật "long-lived refresh_token"**

---

## Cái gì tự động, cái gì phải làm tay

Đây là chỗ cần thành thật — kể cả repo dùng MCP cũng **không** làm hộ được mấy bước sau:

| Bước | `install.sh` lo? |
|---|---|
| Cài `@larksuite/cli` mới nhất | ✅ |
| Cài skill + helper + hook auto-refresh | ✅ |
| Kiểm tra & báo trạng thái | ✅ |
| Giữ token tươi các phiên sau | ✅ (hook, chạy ngầm) |
| Tạo App ID/Secret trên open.feishu.cn | ❌ — con người làm |
| Duyệt OAuth trên trình duyệt lần đầu (`auth login`) | ❌ — con người bấm đồng ý |

Hai bước ❌ chỉ làm **một lần**. Sau đó mọi thứ tự chạy. (Cảm giác "MCP tự làm hết" chẳng qua vì auth đã được cài từ trước — dưới nắp capo nó cũng cần đúng 2 bước này.)

Hai bước đó có thể để Claude Code dẫn giúp: mở Claude Code, gõ *"kết nối giúp tôi lark-cli"* → skill `lark-cli-setup` sẽ dẫn qua đủ 5 bước.

### Lấy App ID / App Secret ở đâu

> Tham khảo FAQ chính thức: <https://open.larkoffice.com/document/faq/trouble-shooting/how-to-obtain-app-id>

1. Mở developer console theo phiên bản:
   - Feishu (bản Trung): <https://open.feishu.cn/app>
   - Lark (quốc tế): <https://open.larksuite.com/app>
2. **Chưa có app thì tạo:** bấm *Create custom app / 创建企业自建应用* → đặt tên, icon → tạo.
3. Vào app → menu trái → **Credentials & Basic Info / 凭证与基础信息**.
4. Ở khối **App Credentials / 应用凭证**: copy **App ID**, rồi bấm hiện/copy **App Secret**.
5. Cùng trang, mục **Security Settings / 安全设置**: **bật "long-lived refresh_token"** (bắt buộc để token tự tươi lâu dài).
6. Dán **App ID** + **App Secret** vào Claude Code khi skill hỏi (hoặc khi `lark-cli config init --new` nhắc nhập).

> ⚠️ App Secret = mật khẩu. Chỉ lưu ở `~/.lark-cli/config.json` trên máy bạn, **đừng** dán lên kênh công khai/log. Có sẵn app của tổ chức thì xin admin App ID/Secret, bỏ qua bước 2.

---

## So với cách dùng MCP (repo `lark-mcp-cli`)

| | Repo này (CLI + Bash) | Repo MCP |
|---|---|---|
| Chạy ở đâu | **Claude Code** (có terminal) | Claude Desktop / claude.ai web |
| Claude gọi Lark qua | Bash chạy `lark-cli` | Giao thức MCP → server shell-out ra `lark-cli` |
| Phạm vi | **Toàn bộ 200+ lệnh** lark-cli | Chỉ các tool được định nghĩa sẵn |
| Cập nhật CLI | `npm update` → luôn mới | Đóng băng trong bản build server |
| Công bảo trì | ~0 | Phải maintain server + tool |

Chọn repo này nếu bạn sống trong **Claude Code**. Chọn MCP nếu cần điều khiển Lark từ **app Desktop/web** không có terminal.

---

## Token auto-refresh hoạt động thế nào

- Hook **SessionStart** chạy `lark-cli-ensure-auth --quiet` mỗi khi mở phiên Claude Code.
- Ở chế độ `--quiet`: chỉ **refresh im lặng bằng refresh_token** (một API call nhẹ), **không** bật trình duyệt.
- Nếu refresh_token đã hết hạn (mặc định ~vài ngày) → helper chỉ **cảnh báo** và nhắc `lark-cli auth login --recommend`, không làm phiền.
- Chạy tay bất cứ lúc nào: `lark-cli-ensure-auth` (không cờ) → nếu cần sẽ mở Device Flow trên trình duyệt.

> Lưu ý: token của **Lark** (miễn phí, ~2 giờ) hoàn toàn tách biệt với hạn mức **Claude** (gói Pro, cửa sổ 5 giờ). Hook này chỉ lo token Lark.

---

## Bảo mật

- `~/.lark-cli/config.json` chứa secret dạng thô → `install.sh` không đụng tới; hãy `chmod 600` và **đừng commit** thư mục `~/.lark-cli/`.
- Không in `appSecret` / `accessToken` / `refreshToken` ra log.
- Hook chỉ chạy đúng một helper cục bộ với đường dẫn tuyệt đối; xem `skills/lark-cli-setup/scripts/lark-cli-ensure-auth`.
- Với thao tác ghi/xoá, skill yêu cầu xác nhận và ưu tiên `--dry-run`.

## Cấu trúc repo

```
lark-cli-onboarding/
├── install.sh                     # bootstrap 1 lệnh
├── uninstall.sh
└── skills/
    └── lark-cli-setup/
        ├── SKILL.md               # Claude Code đọc để dẫn cài đặt
        ├── INSTALL.md
        └── scripts/
            └── lark-cli-ensure-auth   # helper auto-refresh (đã sửa cho CLI >=1.0.5x)
```
