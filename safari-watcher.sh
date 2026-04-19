#!/bin/bash
was_running=false
just_restored=false

while true; do
    sleep 0.5
    if pgrep -x "Safari" > /dev/null; then
        count=$(osascript -e 'tell application "Safari" to count of windows' 2>/dev/null)
        if [ "$count" = "0" ]; then
            osascript -e 'tell application "Safari" to quit'
            was_running=false
            just_restored=false
        elif [ "$count" -gt "0" ]; then
            if [ "$was_running" = false ]; then
                was_running=true
                sleep 3
                if [ -s ~/safari-tabs-backup.txt ]; then
                    osascript << APPLESCRIPT
tell application "Safari"
    set alreadyOpen to {}
    repeat with t in tabs of window 1
        set u to URL of t
        if u is not missing value then
            set end of alreadyOpen to u
        end if
    end repeat

    set urlList to paragraphs of (do shell script "grep -E '^https?://' ~/safari-tabs-backup.txt 2>/dev/null || true")
    repeat with u in urlList
        if u is not "" and alreadyOpen does not contain u then
            tell window 1 to set current tab to (make new tab with properties {URL:u})
            set end of alreadyOpen to u
        end if
    end repeat

    set tabsToClose to {}
    repeat with t in tabs of window 1
        set u to URL of t
        if u is "favorites://" or u is "about:blank" or u is missing value then
            set end of tabsToClose to t
        end if
    end repeat
    repeat with t in tabsToClose
        close t
    end repeat

    set current tab of window 1 to tab 1 of window 1
end tell
APPLESCRIPT
                    just_restored=true
                fi
            fi

            # Skip saving once right after restore, then save normally
            if [ "$just_restored" = true ]; then
                just_restored=false
            else
                osascript << 'APPLESCRIPT'
tell application "Safari"
    set tabURLs to {}
    repeat with w in windows
        repeat with t in tabs of w
            set u to URL of t
            if u is not missing value and u is not "favorites://" and u is not "about:blank" then
                if tabURLs does not contain u then
                    set end of tabURLs to u
                end if
            end if
        end repeat
    end repeat
    set urlText to ""
    repeat with u in tabURLs
        set urlText to urlText & u & linefeed
    end repeat
    do shell script "echo " & quoted form of urlText & " > ~/safari-tabs-backup.txt"
end tell
APPLESCRIPT
            fi
        fi
    else
        was_running=false
    fi
done
