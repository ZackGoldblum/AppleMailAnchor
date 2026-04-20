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
    set theSubject to subject of theMessage
    set latestMsg to theMessage
    set latestDate to date received of theMessage

    -- Build list of subjects to match: exact + with/without "Re: " prefix
    set subjectsToMatch to {theSubject}
    if theSubject starts with "Re: " then
        set end of subjectsToMatch to text 5 thru -1 of theSubject
    else
        set end of subjectsToMatch to "Re: " & theSubject
    end if

    repeat with acct in every account
        repeat with mbox in every mailbox of acct
            if name of mbox is in {"All Mail", "Sent Items", "Sent Mail", "Sent Messages"} then
                try
                    repeat with s in subjectsToMatch
                        set matches to (messages of mbox whose subject is (s as text))
                        repeat with m in matches
                            try
                                set msgDate to date received of m
                                if msgDate > latestDate then
                                    set latestDate to msgDate
                                    set latestMsg to m
                                end if
                            end try
                        end repeat
                    end repeat
                end try
            end if
        end repeat
    end repeat
    set rawID to message id of latestMsg
    set encodedID to do shell script "python3 -c 'from urllib.parse import quote; import sys; print(quote(sys.argv[1], safe=\"\"))' " & quoted form of rawID
    return "http://localhost:9876/?id=" & encodedID
end tell
APPLESCRIPT
)

if [ -n "$result" ]; then
    echo "$result" | pbcopy
    osascript -e 'display notification "Email link copied to clipboard." with title "Mail Anchor"'
fi
