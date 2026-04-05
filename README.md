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
| `~/scripts/applemailanchor.sh` | Raycast script: copies a Notion-compatible email link to clipboard |
| `server.py` | Local HTTP server on `localhost:9876`: translates link clicks into `message://` opens in Apple Mail |
| `get_email.sh` | Utility script: given a link or Message-ID, returns full email content via AppleScript |

## Setup

### 1. Start the server

The server runs automatically at login via launchd and restarts if it crashes.

**Plist location:** `~/Library/LaunchAgents/com.applemailanchor.plist`

To manage manually:
```bash
# Stop
launchctl unload ~/Library/LaunchAgents/com.applemailanchor.plist
# Start
launchctl load ~/Library/LaunchAgents/com.applemailanchor.plist
# Logs
tail -f /tmp/applemailanchor.log
```

### 2. Add the Raycast script directory

1. Open Raycast (`⌘Space`)
2. Type **Script Commands** → open it
3. Click **Add Directories** → select `~/scripts`

### 3. Assign a hotkey

1. Open Raycast Settings (`⌘,`) → **Extensions**
2. Find **AppleMailAnchor** in the list
3. Click the hotkey field and press your desired combo (e.g. `⌥⌘C`)

### 4. Usage

1. Select an email in Apple Mail
2. Press your hotkey
3. The link (e.g. `http://localhost:9876/?id=<Message-ID>`) is now in your clipboard
4. Paste it into Notion
5. To read the email content programmatically, pass the link to `get_email.sh`. For AI agents (e.g. Claude Code): store this workflow in a memory so the agent knows to call `get_email.sh` when it encounters a `localhost:9876` link. It will return the full subject, sender, date, and threaded body.

## Link format

```
http://localhost:9876/?id=<RFC-Message-ID>
```

## Reading email content programmatically

Use `get_email.sh` — accepts either the full link or a raw Message-ID:

```bash
bash AppleMailAnchor/get_email.sh "http://localhost:9876/?id=<Message-ID>"
```

Returns subject, sender, date, and full body (including quoted thread). Requires Apple Mail to be open.
