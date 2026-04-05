#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLIST_LABEL="com.applemailanchor"
PLIST_DEST="$HOME/Library/LaunchAgents/$PLIST_LABEL.plist"

echo "==> Apple Mail Anchor Setup"

# 1. Find Python 3
PYTHON=$(which python3 2>/dev/null)
if [ -z "$PYTHON" ]; then
    echo "Error: python3 not found. Install Python 3 and try again."
    exit 1
fi
echo "    Python: $PYTHON"

# 2. Copy Raycast script
mkdir -p "$HOME/scripts"
cp "$SCRIPT_DIR/applemailanchor.sh" "$HOME/scripts/applemailanchor.sh"
chmod +x "$HOME/scripts/applemailanchor.sh"
echo "    Raycast script copied to ~/scripts/"

# 3. Write plist with correct paths
cat > "$PLIST_DEST" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$PLIST_LABEL</string>
    <key>ProgramArguments</key>
    <array>
        <string>$PYTHON</string>
        <string>$SCRIPT_DIR/server.py</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/applemailanchor.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/applemailanchor.log</string>
</dict>
</plist>
EOF
echo "    Plist written to $PLIST_DEST"

# 4. Unload if already running, then load
launchctl unload "$PLIST_DEST" 2>/dev/null || true
launchctl load "$PLIST_DEST"
echo "    Server loaded via launchd"

# 5. Verify
sleep 1
STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:9876/)
if [ "$STATUS" = "400" ]; then
    echo ""
    echo "✓ Server is running on localhost:9876"
else
    echo ""
    echo "Warning: server may not have started. Check logs: tail -f /tmp/applemailanchor.log"
fi

echo ""
echo "Next steps:"
echo "  1. Open Raycast → Script Commands → Add Directories → select ~/scripts"
echo "  2. Raycast Settings (⌘,) → Extensions → AppleMailAnchor → assign a hotkey (e.g. ⌥⌘C)"
