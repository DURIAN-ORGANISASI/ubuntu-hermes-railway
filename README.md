# Ubuntu + Hermes Agent for Railway

Deploy an Ubuntu 26.04 web terminal on Railway with Hermes Agent CLI installed, an automatic Fastfetch/neofetch-style login banner, and an optional auto-start for the Hermes messaging Gateway.

> This is a Railway container, not a full VPS or Ubuntu desktop. It provides an authenticated browser terminal. Railway may restart/recreate containers, so use a Volume for anything that must persist.

## Features

- Ubuntu 26.04 container
- Browser terminal via `ttyd`, protected by username/password
- Hermes Agent CLI installed using the official Hermes installer in non-interactive mode
- Automatic login banner with OS, kernel, architecture, uptime, CPU, RAM, disk and Gateway status
- General CLI tools including Git, curl, Python 3, pip/venv and build tools
- Optional automatic Gateway launch/restart when Hermes configuration exists
- `Asia/Jakarta` timezone by default
- Hermes data directory configurable with `HERMES_HOME` (defaults to `/opt/data`)

The image install uses `--skip-browser` to keep the default image lighter. This does not configure a model or messaging platform for you; those are set up interactively in the terminal. Browser automation can be added later if needed.

## Railway Variables

Set these under **Railway → Service → Variables**:

| Variable | Required | Value |
|---|---|---|
| `TERMINAL_USER` | Yes | Terminal login username; must not contain `:` |
| `TERMINAL_PASSWORD` | Yes | Unique random password, minimum 16 characters; 24–40 recommended |
| `TZ` | No | Defaults to `Asia/Jakarta` |
| `HERMES_HOME` | No | Defaults to `/opt/data` |
| `HERMES_AUTOSTART` | No | `true` (default) or `false` to disable Gateway auto-start |
| `PORT` | Automatically provided | Do not hardcode; Railway sets it at runtime |

Never store real API keys, Telegram/Discord tokens, or passwords in GitHub. Configure provider credentials through the Hermes CLI so secrets are written to Hermes' config area.

## Deploy

1. Create a **separate GitHub repository**, for example `ubuntu-hermes-railway`.
2. Upload all files from this project to the repository root, including `Dockerfile` and `entrypoint.sh`.
3. In Railway, select **New Project → Deploy from GitHub Repo** and choose the new repository.
4. Make sure the service builds from the `Dockerfile` at the repository root.
5. Add `TERMINAL_USER` and `TERMINAL_PASSWORD` in Railway Variables.
6. Generate a domain under **Settings → Networking** and open it in a browser.

## First-time Hermes setup

Open the terminal web page, log in, then run:

```bash
hermes --help
hermes setup
hermes gateway setup
```

Follow the prompts to select a model/provider and enter Telegram/Discord tokens for whichever channels you intend to use. This repo does not hardcode a model or provider. Confirm a normal CLI chat works before troubleshooting messaging.

Once setup has created `${HERMES_HOME}/config.yaml`, restart the Railway service. On container startup, the entrypoint detects this file and launches `hermes gateway run` in a restart loop. If setup has not created the file yet, the web terminal remains available and the Gateway is not started automatically.

To run the Gateway manually for diagnosis, use:

```bash
start-hermes
```

To check status/log output, inspect Railway Deploy Logs and the Hermes logs under `$HERMES_HOME/logs/`.

## Persistent storage

Without a Volume, files and configuration in the container are not guaranteed to survive a redeploy or container recreation.

Recommended volumes:

- **`/opt/data`** — Hermes config, `.env` secrets, sessions, memories and logs.
- **`/data`** — files you create from the general terminal.

If you only attach `/data`, Hermes configuration under `/opt/data` may still be lost. Add the Volume before completing Hermes setup if you need the configuration to persist.

## Automatic banner

No command is required at login. `/etc/profile.d/00-system-banner.sh` is loaded automatically for interactive Bash login shells. It uses `fastfetch` if installed; otherwise, a Bash fallback prints system details dynamically.

CPU and memory are what the container can see, not a guaranteed Railway plan quota. Disk usage reflects the filesystem containing `/data`.

## Security and limitations

- The web terminal is reachable over the public service domain; protect it with a strong, unique password.
- The shell runs as root inside the container.
- This does not install a full desktop GUI or enable a traditional VPS/systemd environment.
- Gateway uptime is tied to the Railway service and its resource/availability policies.
- Never commit real provider keys, channel tokens, or terminal passwords.
- Verify build success in Railway Deploy Logs; the repository package has not been built in your Railway environment by this README.

## Troubleshooting

**Build fails during Hermes installation:** inspect Railway build logs for upstream installer or package errors. The installer is downloaded from the official Hermes website during build, so the build requires network access and upstream availability.

**Gateway does not start automatically:** complete `hermes setup` and `hermes gateway setup`, check that `$HERMES_HOME/config.yaml` exists, and restart the Railway service. Ensure `HERMES_AUTOSTART=true`.

**Bot doesn't reply:** verify its token, Discord intents/permissions or Telegram configuration, selected model/provider, and Railway runtime logs.

**Config disappears after redeploy:** attach a Railway Volume at `/opt/data` and then complete setup again if the old config was already lost.

**Banner does not appear:** open a new terminal session and confirm it starts an interactive Bash login shell.

## Project files

```text
.
├── Dockerfile
├── entrypoint.sh
├── system-banner.sh
├── start-hermes
├── .dockerignore
├── .gitignore
├── .env.example
└── README.md
```

## References

- [Official Hermes installation guide](https://hermes-agent.nousresearch.com/docs/getting-started/installation/)
- [Official Hermes messaging/Gateway guide](https://hermes-agent.nousresearch.com/docs/user-guide/messaging/)
