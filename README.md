# Apple Mail Anchor

Link to specific emails from Notion (or anywhere) using a Raycast hotkey. Clicking the link opens the email directly in Apple Mail.

## How it works

1. Select an email in Apple Mail
2. Press the Raycast hotkey → the link is copied to clipboard
3. Paste into Notion (or any app)
4. Clicking the link hits the local server, which opens the email in Apple Mail

## Files

| File | Purpose |
|------|---------|
| `setup.sh` | One-time setup script: installs everything and starts the server |
| `server.py` | Local HTTP server on `localhost:9876`: translates link clicks into `message://` opens in Apple Mail |
| `applemailanchor.sh` | Raycast script: copies a Notion-compatible email link to clipboard (installed to `~/scripts/` by setup) |
| `get_email.sh` | Utility script: given a link or Message-ID, returns full email content via AppleScript |

## Prerequisites

- macOS with Apple Mail configured
- Python 3 installed — verify with `python3 --version`
- [Raycast](https://www.raycast.com) installed

## Setup

### 1. Run the setup script

From the project directory:

```bash
bash setup.sh
```

This will:
- Copy `applemailanchor.sh` to `~/scripts/`
- Generate and install the launchd plist with the correct paths for your machine
- Start the server immediately and register it to run at login

### 2. Add the script directory to Raycast

1. Open Raycast (`⌘Space`)
2. Type **Script Commands** → open it
3. Click **Add Directories** → select `~/scripts`

### 3. Assign a hotkey

1. Open Raycast Settings (`⌘,`) → **Extensions**
2. Find **AppleMailAnchor** in the list
3. Click the hotkey field and press your desired combo (e.g. `⌥⌘C`)

**Manage the server manually:**
```bash
# Stop
launchctl unload ~/Library/LaunchAgents/com.applemailanchor.plist
# Start
launchctl load ~/Library/LaunchAgents/com.applemailanchor.plist
# Logs
tail -f /tmp/applemailanchor.log
```

## Usage

1. Open Apple Mail and select an email
2. Press your Raycast hotkey (Mail must be the active window)
3. The link is copied to your clipboard: `http://localhost:9876/?id=<Message-ID>`
4. Paste it into Notion — clicking it will open the email in Apple Mail
5. To read the email content programmatically (e.g. via an AI agent), pass the link to `get_email.sh`:
   ```bash
   bash get_email.sh "http://localhost:9876/?id=<Message-ID>"
   ```
   For AI agents (e.g. Claude Code): store this workflow in memory so the agent knows to call `get_email.sh` when it encounters a `localhost:9876` link. It will return the full subject, sender, date, and threaded body.
