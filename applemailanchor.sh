#!/bin/bash
# @raycast.title AppleMailAnchor
# @raycast.schemaVersion 1
# @raycast.mode silent

result=$(osascript <<APPLESCRIPT
tell application "System Events"
    set frontApp to name of first application process whose frontmost is true
end tell
if frontApp is not "Mail" then return
tell application "Mail"
    set theMessage to item 1 of (get selection)
    set theID to message id of theMessage
    return "http://localhost:9876/?id=" & theID
end tell
APPLESCRIPT
)

if [ -n "$result" ]; then
    echo "$result" | pbcopy
    osascript -e 'display notification "Email link copied to clipboard." with title "Mail Anchor"'
fi
