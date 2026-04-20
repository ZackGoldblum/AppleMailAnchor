#!/bin/bash
# Usage: get_email.sh <message-id-or-notion-link>
# Accepts either a raw Message-ID or a full localhost:9876/?id=... URL

INPUT="$1"

# Extract Message-ID from URL if needed
if [[ "$INPUT" == *"localhost:9876"* ]]; then
    MSG_ID=$(python3 -c "from urllib.parse import urlparse, unquote; q=urlparse('$INPUT').query; print(unquote(next(p[3:] for p in q.split('&') if p.startswith('id='))))")
else
    MSG_ID="$INPUT"
fi

osascript << EOF
tell application "Mail"
    set msgID to "$MSG_ID"
    set foundMsg to missing value
    repeat with acct in every account
        repeat with mbox in every mailbox of acct
            try
                set matches to (messages of mbox whose message id is msgID)
                if (count of matches) > 0 then
                    set foundMsg to item 1 of matches
                    exit repeat
                end if
            end try
        end repeat
        if foundMsg is not missing value then exit repeat
    end repeat
    if foundMsg is not missing value then
        return "Subject: " & subject of foundMsg & "\nFrom: " & sender of foundMsg & "\nDate: " & (date received of foundMsg as string) & "\n\nBody:\n" & content of foundMsg
    else
        return "Message not found"
    end if
end tell
EOF
