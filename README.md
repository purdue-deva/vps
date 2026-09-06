# Ubuntu Ephemeral Server & AzureBot CLI

An automated ephemeral Ubuntu server environment running on GitHub Actions, managed remotely via a native Bash Telegram bot, Tailscale VPN, and Cloudflare Tunnel.

---

## 🌟 Key Features

- **Ephemeral Cloud Infrastructure:** Runs on `ubuntu-latest` with a 360-minute (6-hour) maximum lifespan per workflow session.
- **Zero-Dependency Telegram Bot:** Built completely with native Bash, `curl`, and `jq` without requiring Python, Node.js bot libraries, or heavy external runtimes.
- **Integrated Groq LLM:** Automatic fallback to Groq-hosted open LLM for queries that do not match bot commands.
- **Web Terminal & Local File Server:** Web-based interactive shell using `ttyd` and a simple HTTP file server using `http-server`.
- **Bi-Directional File Transfer:** Upload documents or media directly through Telegram to `/root/uploads`, or download files from the runner to Telegram via `/fetch`.
- **Dual Networking:** Connect securely through a Tailscale mesh network or expose internal services to public hostnames via Cloudflare Tunnel (`cloudflared`).

---

## 🌐 Cloudflare Tunnel & Port Configuration

The workflow automatically initializes and installs the Cloudflare Tunnel service using your `CF_TUNNEL_TOKEN` secret. To access internal runner services through custom subdomains, configure the following ingress rules under **Networks > Tunnels > [Your Tunnel Name] > Public Hostname** in the [Cloudflare Zero Trust Dashboard](https://one.dash.cloudflare.com/):

| Service | Protocol | Local URL / Target Port | Description & Notes |
| :--- | :--- | :--- | :--- |
| **Web Terminal (`ttyd`)** | `HTTP` | `localhost:7681` (or `127.0.0.1:7681`) | Browser-based interactive shell. Protected by basic auth: `parid:paridos` (change after this). Enable WebSocket support if prompted. |
| **File Server (`uploads`)** | `HTTP` | `localhost:8090` (or `127.0.0.1:8090`) | Static directory listing serving files stored under `/root/uploads/`. |
| **SSH Server (Optional)** | `SSH` | `localhost:22` | Direct terminal access for user `runneradmin`. Requires client-side `cloudflared access ssh` configuration or browser rendering. |

> **Tip:** If accessing services via Tailscale, these ports are accessible directly on your Tailscale network at `http://<TAILSCALE_IP>:7681` and `http://<TAILSCALE_IP>:8090` without needing public Cloudflare hostnames.

---

## 📋 Telegram Bot Commands

| Command | Arguments | Description |
| :--- | :--- | :--- |
| `/help` | — | Displays the command center menu. |
| `/status` | — | Shows CPU model, live CPU load percentage, RAM usage, and uptime. |
| `/ip` | — | Outputs the Tailscale IPv4 address and SSH credentials (`runneradmin`). |
| `/neofetch` | — | Runs `neofetch --stdout` and displays detailed hardware/OS specs. |
| `/speedtest`| — | Executes `speedtest-cli` to report network bandwidth. |
| `/fetch` | `<file_path>` | Uploads and sends a file from the server directly to your Telegram chat. |
| `/scanhost` | `<target_ip>` | Runs a quick fast-scan (`nmap -Pn -F`) against a specified IP or host. |
| `/kill` | `<process_name>` | Executes `pkill -9 -f` against matching process names (protected against killing the bot itself). |
| `/cmd` | `<bash_command>` | Executes arbitrary shell commands as `root` and outputs the result. |

---

## ⚙️ Required GitHub Secrets

Configure these environment secrets in your repository settings under **Settings > Secrets and variables > Actions**:

| Secret Name | Purpose |
| :--- | :--- |
| `RDP_PASS` | Password assigned to `runneradmin` and the database setup variable. |
| `TAILSCALE_AUTH_KEY` | Tailscale reusable auth key used to join your Tailnet. |
| `CF_TUNNEL_TOKEN` | Token provided by Cloudflare Zero Trust to bind the runner to your tunnel. |
| `TELEGRAM_BOT_TOKEN` | API authentication token obtained from `@BotFather`. |
| `TELEGRAM_CHAT_ID` | Telegram numeric User ID authorized to access and control the bot. |
| `GROQ_API_KEY` | API key from Groq Console used for natural language AI processing. |

---

## 🚀 Execution & Lifecycle

- **Automated Schedule:** Triggered every 5 hours via cron (`0 */5 * * *`).
- **Manual Trigger:** Can be dispatched manually at any time using the `workflow_dispatch` button under the **Actions** tab.
- **Session Concurrency:** Managed by concurrency group `tailscale-exit-node` with `cancel-in-progress: true` to prevent overlapping runner instances.
- **Cleanup:** Automatically executes `sudo tailscale logout` when the job completes or is cancelled to keep your Tailnet clean.
