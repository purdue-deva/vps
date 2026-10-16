# 🐧 Ubuntu Ephemeral Server — Rimuru-MD & AzureBot C2

![Ubuntu](https://img.shields.io/badge/Ubuntu-Latest-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)
![NodeJS](https://img.shields.io/badge/Node.js-v22-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-Ephemeral_VPS-2088FF?style=for-the-badge&logo=github-actions&logoColor=white)
![Tailscale](https://img.shields.io/badge/Tailscale-Exit_Node-242424?style=for-the-badge&logo=tailscale&logoColor=white)
![Cloudflare](https://img.shields.io/badge/Cloudflare-Tunnel-F38020?style=for-the-badge&logo=cloudflare&logoColor=white)

Repositori ini berisi sistem orkestrasi **Ephemeral Ubuntu Server** berbasis GitHub Actions yang berjalan secara otomatis dan berkesinambungan (rotasi setiap 5 jam dengan batas *timeout* 360 menit per sesi).

Dirancang khusus untuk menjalankan **Rimuru-MD (WhatsApp Multi-Device Bot)** lengkap dengan fitur *state persistence* otomatis (Backup & Restore via Rclone + Google Drive), akses jaringan privat penuh (**Tailscale VPN & Exit Node** + **Cloudflare Zero Trust Tunnel**), skrip auto-setup **Pterodactyl Panel (`panel.sh`)**, serta **AzureBot Core Engine** (Bot Telegram *Command & Control* murni berbasis Bash + AI).

---

## ✨ Fitur Utama

* 🔄 **Zero-Data-Loss Ephemeral Cycle (`Doomsday Protocol`):** Setiap kali *runner* menyala, server otomatis mengunduh dan mengekstrak `storage_backup.tar.gz` (sesi autentikasi WA) dan `database_backup.tar.gz` dari Google Drive melalui **Rclone**. Saat sesi berakhir atau dibatalkan (`if: always()`), server membungkus kembali seluruh perubahan data terbaru dan mengunggahnya ke Google Drive sebelum *shutdown*.
* 🤖 **Auto-Deploy Rimuru-MD (Node.js v22 + PM2):** Menarik repositori *private* utama (`riddsanz/rimuru`) menggunakan Personal Access Token (PAT), menginstal dependensi, memulihkan memori/sesi, dan menjalankannya di latar belakang menggunakan **PM2**.
* 🌐 **Dual Network Tunneling (Tailscale & Cloudflared):**
  * Terhubung otomatis ke jaringan *mesh* **Tailscale** sebagai `ubuntu-azure-temp` sekaligus berfungsi sebagai **Exit Node** dan membuka akses SSH penuh (`runneradmin`).
  * Terintegrasi dengan **Cloudflare Tunnel (`cloudflared`)** untuk mengekspos layanan lokal ke domain publik tanpa perlu membuka *port forwarding*.
* 🖥️ **Web Terminal (`ttyd`) & File Server:**
  * **Web Terminal (`Port 7681`):** Akses *shell* `bash` interaktif langsung dari browser (dilindungi autentikasi dasar `parid:paridos`).
  * **HTTP File Server (`Port 8090`):** Direktori `/root/uploads` disajikan secara langsung melalui `http-server` untuk kemudahan unduh/unggah berkas.
* 🦖 **Pterodactyl Auto-Setup Ready (`panel.sh`):** Menyalin dan memberikan izin eksekusi otomatis pada skrip `panel.sh` ke `/root/panel.sh` untuk kemudahan instalasi *Pterodactyl Panel / Wings* kapan saja dibutuhkan.
* 📡 **AzureBot Core Engine (Pure Bash Telegram C2 + Groq AI):** Mesin pengendali server jarak jauh via Telegram yang ditulis 100% menggunakan *Pure Bash* (dilengkapi *Anti Death-Loop / Poison Pill flush*) untuk eksekusi perintah `root`, transfer berkas dua arah, pemantauan *resource*, hingga asisten AI berbasis **Groq (`openai/gpt-oss-120b`)**.

---

## 📂 Struktur Direktori

Pastikan struktur berkas di repositori *runner* ini tersusun seperti berikut (skrip `panel.sh` berada di *root* sejajar dengan folder `.github`):

```text
├── .github/
│   └── workflows/
│       └── main.yml        # Workflow utama (ubuntu-server-ephemeral)
├── panel.sh                # Skrip auto-setup Pterodactyl (otomatis disalin ke /root/panel.sh)
└── README.md               # Dokumentasi proyek
```

---

## 🔐 Konfigurasi GitHub Secrets (Wajib)

Agar *workflow* ini dapat berjalan tanpa kendala, masuk ke repositori GitHub kamu lalu buka menu:
**`Settings` ➔ `Secrets and variables` ➔ `Actions` ➔ `New repository secret`**

Tambahkan **8 Secrets** berikut beserta nilainya:

| Nama Secret | Fungsi & Kegunaan | Cara Mendapatkan & Link Resmi |
| :--- | :--- | :--- |
| **`PAT_GITHUB`** | Token akses untuk meng-clone repositori *private* utama (`riddsanz/rimuru`). | 1. Buka **[GitHub Personal Access Tokens](https://github.com/settings/tokens)**.<br>2. Pilih **Tokens (classic)** ➔ **Generate new token (classic)**.<br>3. Centang *scope* **`repo`** (Full control of private repositories), lalu *generate* dan salin token `ghp_xxxx`. |
| **`RDP_PASS`** | Password untuk akun SSH Linux (`runneradmin` & `runner`) serta variabel `PTERO_DB_PASS`. | Buat password kustom yang kuat sesuai keinginanmu (contoh: `ParidServer2026!`). |
| **`TAILSCALE_AUTH_KEY`** | Kunci autentikasi otomatis agar *runner* langsung terhubung ke jaringan VPN Tailscale tanpa login manual. | 1. Buka **[Tailscale Admin Console - Keys](https://login.tailscale.com/admin/settings/keys)**.<br>2. Klik **Generate auth key...**<br>3. Aktifkan **Reusable** dan **Ephemeral** (opsional tetapi sangat disarankan untuk GitHub Actions).<br>4. Salin kode `tskey-auth-xxxx`. |
| **`CF_TUNNEL_TOKEN`** | Token konektor untuk menjalankan *daemon* Cloudflare Zero Trust Tunnel. | 1. Buka **[Cloudflare Zero Trust Dashboard](https://one.dash.cloudflare.com/)**.<br>2. Masuk ke **Networks** ➔ **Tunnels** ➔ **Create a tunnel** (pilih *Cloudflared*).<br>3. Salin hanya bagian **Token** panjang (`eyJhIjoi...`) dari perintah instalasi `cloudflared service install <TOKEN>`. |
| **`RCLONE_CONF`** | Seluruh isi konfigurasi `rclone.conf` yang memuat remote bernama **`Backup_Bot`** (terhubung ke Google Drive). | 1. Install Rclone di PC/laptop lokalmu dari **[Rclone Downloads](https://rclone.org/downloads/)**.<br>2. Jalankan `rclone config` ➔ ketik `n` (New remote) ➔ beri nama persis **`Backup_Bot`** ➔ pilih `drive` (Google Drive) dan selesaikan login OAuth di browser.<br>3. Jalankan `rclone config file` untuk melihat lokasi file `rclone.conf`, buka file tersebut dengan teks editor, lalu **salin seluruh isinya** ke dalam secret ini. |
| **`TELEGRAM_BOT_TOKEN`** | Token HTTP API untuk menghidupkan **AzureBot Core Engine** di Telegram. | 1. Chat **[@BotFather](https://t.me/BotFather)** di Telegram.<br>2. Ketik `/newbot`, ikuti instruksi pemberian nama dan *username*.<br>3. Salin token API yang diberikan (format: `1234567890:AAFxxxx...`). |
| **`TELEGRAM_CHAT_ID`** | ID akun Telegram pribadimu (digunakan sebagai *whitelist* keamanan agar hanya kamu yang bisa mengontrol server via bot). | 1. Chat **[@userinfobot](https://t.me/userinfobot)** atau **[@MissRose_bot](https://t.me/MissRose_bot)** (ketik `/id`) di Telegram.<br>2. Salin angka **Id** akunmu (contoh: `123456789`). |
| **`GROQ_API_KEY`** | API Key untuk fitur obrolan AI pada AzureBot ketika kamu mengirim pesan teks biasa (non-command) di Telegram. | 1. Buka **[GroqCloud Console](https://console.groq.com/keys)**.<br>2. Login dan klik **Create API Key**.<br>3. Salin kunci yang diawali dengan `gsk_xxxx`. |

---

## ⚙️ Alur Kerja Sistem (Workflow Lifecycle)

1. **Trigger & Concurrency Control:**
   * Berjalan otomatis setiap 5 jam sekali (`cron: '0 */5 * * *'`) atau dapat dipicu kapan saja secara manual lewat tombol **Run workflow** (`workflow_dispatch`).
   * Menggunakan grup konkurensi `tailscale-exit-node` dengan `cancel-in-progress: true`. Saat sesi baru menyala atau dipicu ulang, sesi lama akan menerima sinyal pembatalan, mengeksekusi **Doomsday Backup** secara aman, lalu menyerahkan tongkat estafet ke server baru.
2. **Provisioning & Network Tunneling:**
   * Mengatur zona waktu ke `Asia/Jakarta` (WIB), membuat user `runneradmin` dengan akses `sudo`, dan mengaktifkan servis SSH.
   * Menginstal Tailscale (`--advertise-exit-node`) dan Cloudflared, serta utilitas jaringan/sistem (`speedtest-cli`, `nmap`, `jq`, `ttyd`, `neofetch`).
3. **Web Services & Pterodactyl Script Prep:**
   * Menjalankan File Server di port `8090` (serving `/root/uploads`) dan Web Terminal `ttyd` di port `7681`.
   * Menyalin `panel.sh` dari *root* repositori ke `/root/panel.sh` (`chmod +x`).
4. **Rimuru-MD Resurrection (Rclone Restore & PM2):**
   * Menginjeksi `~/.config/rclone/rclone.conf` dari secret `RCLONE_CONF`.
   * Mengunduh hanya 2 berkas arsip tunggal (`storage_backup.tar.gz` & `database_backup.tar.gz`) dari remote `Backup_Bot:` untuk menghindari *rate-limit* API Google Drive akibat ribuan *file* sesi kecil (*chunks*).
   * Mengekstrak arsip, menghapus file `.tar.gz` mentah untuk menghemat ruang disk, lalu menyalakan Rimuru-MD menggunakan `pm2 start . --name rimuru`.
5. **AzureBot Core Loop (Telegram C2):**
   * Membersihkan antrean pesan lama (*Flush Pending Updates*) agar bot tidak terjebak mengeksekusi perintah usang (*poison pill*).
   * Mengirimkan notifikasi status aktif beserta IP Tailscale, kredensial SSH, dan tautan Web Terminal ke Telegram kamu, lalu berjaga selama sesi server berlangsung.
6. **Doomsday Protocol (`if: always()`):**
   * Sebelum server mati karena *timeout* 6 jam atau dihentikan manual, PM2 akan dihentikan (`pm2 stop rimuru`) agar tidak ada transaksi file yang korup.
   * Folder `storage/` dan `database/` dikompresi kembali menjadi `.tar.gz` dan diunggah ke Google Drive (`Backup_Bot:`), disusul dengan `tailscale logout` agar node lama bersih dari daftar perangkat Tailscale.

---

## 📱 Daftar Perintah Telegram (AzureBot C2)

Saat server aktif, kamu dapat mengendalikannya langsung melalui bot Telegram milikmu menggunakan perintah berikut:

| Command | Parameter | Deskripsi |
| :--- | :--- | :--- |
| `/help` atau `/start` | - | Menampilkan informasi pusat kendali (*Command Center*). |
| `/status` | - | Mengecek spesifikasi dan kesehatan server secara *real-time* (Model CPU, Load %, penggunaan RAM, dan Uptime). |
| `/ip` | - | Menampilkan detail IP Tailscale, username (`runneradmin`), dan password SSH/Database. |
| `/neofetch` | - | Menampilkan output informasi sistem lengkap ala `neofetch`. |
| `/speedtest` | - | Menjalankan pengujian kecepatan jaringan server (`speedtest-cli --simple`). |
| `/scanhost` | `<IP / Domain>` | Memindai port terbuka pada target menggunakan `nmap -Pn -F`. |
| `/fetch` | `<path/ke/file>` | Mengambil/mengunduh file langsung dari dalam server ke ruang obrolan Telegram (contoh: `/fetch /root/rimuru/config.js`). |
| `/kill` | `<nama_proses>` | Mematikan paksa proses Linux menggunakan `pkill -9 -f` (dilengkapi proteksi agar tidak membunuh `bash` atau `curl` utama). |
| `/cmd` | `<perintah_bash>` | Mengeksekusi perintah terminal secara langsung sebagai `root` (mendukung perpindahan direktori persisten `cd <folder>`). |
| **Upload File** | *(Kirim Media/Dokumen)* | Kirimkan dokumen, foto, video, atau audio apa pun ke bot Telegram, dan file tersebut akan otomatis diunduh ke `/root/uploads/` (serta langsung bisa diakses lewat File Server port `8090`). |
| **Chat Biasa** | *(Teks tanpa `/`)* | Ketik pesan apa saja tanpa awalan garis miring (`/`) untuk mengobrol langsung dengan asisten AI server (ditenagai oleh Groq). |

---

## 🦖 Menjalankan Setup Pterodactyl (`panel.sh`)

Skrip `panel.sh` yang diletakkan di *root* repositori akan secara otomatis disalin ke `/root/panel.sh` saat server menyala. Kamu dapat menjalankannya melalui salah satu dari tiga cara berikut:

1. **Via SSH (Tailscale):**
   ```bash
   ssh runneradmin@<TAILSCALE_IP>
   sudo /root/panel.sh
   ```
2. **Via Web Terminal (`ttyd`):**
   Buka `http://<TAILSCALE_IP>:7681` di browser (Login: `parid` / `paridos`), lalu jalankan:
   ```bash
   sudo /root/panel.sh
   ```
3. **Via Telegram (`/cmd`):**
   *(Khusus jika `panel.sh` mendukung mode non-interaktif/unattended)*:
   ```text
   /cmd /root/panel.sh
   ```
