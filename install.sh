#!/bin/bash

# Safari Session Restore - Installer
# https://github.com/sebastianburke/safari-session-restore

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo "🔵 Safari Session Restore - Installer"
echo "======================================"
echo ""

# --- Check macOS ---
if [[ "$OSTYPE" != "darwin"* ]]; then
  echo -e "${RED}❌ This script only works on macOS.${NC}"
  exit 1
fi

SCRIPT_PATH="$HOME/safari-watcher.sh"
PLIST_PATH="$HOME/Library/LaunchAgents/com.user.safariwatcher.plist"
BACKUP_PATH="$HOME/safari-tabs-backup.txt"

# --- Create the watcher script ---
echo -e "${YELLOW}→ Creating watcher script...${NC}"
cat > "$SCRIPT_PATH" << 'EOF'
#!/bin/bash
was_running=false

while true; do
    sleep 0.5
    if pgrep -x "Safari" > /dev/null; then
        count=$(osascript -e 'tell application "Safari" to count of windows' 2>/dev/null)
        if [ "$count" = "0" ]; then
            osascript -e 'tell application "Safari" to quit'
            was_running=false
        elif [ "$count" -gt "0" ]; then
            if [ "$was_running" = false ]; then
                was_running=true
                sleep 1
                if [ -f ~/safari-tabs-backup.txt ]; then
                    osascript << APPLESCRIPT
tell application "Safari"
    set openURLs to {}
    repeat with t in tabs of window 1
        set end of openURLs to URL of t
    end repeat
    if (count of tabs of window 1) is 1 then
        set URL of current tab of window 1 to "about:blank"
    end if
    set urlList to paragraphs of (do shell script "cat ~/safari-tabs-backup.txt")
    set first_tab to true
    repeat with u in urlList
        if u is not "" and u is not "favorites://" then
            if openURLs does not contain u then
                if first_tab then
                    set URL of current tab of window 1 to u
                    set first_tab to false
                else
                    tell window 1 to set current tab to (make new tab with properties {URL:u})
                end if
            end if
        end if
    end repeat
    set current tab of window 1 to tab 1 of window 1
end tell
APPLESCRIPT
                fi
            fi
            osascript << 'APPLESCRIPT'
tell application "Safari"
    set tabURLs to {}
    repeat with w in windows
        repeat with t in tabs of w
            set end of tabURLs to URL of t
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
    else
        was_running=false
    fi
done
EOF

chmod +x "$SCRIPT_PATH"
echo -e "${GREEN}✅ Watcher script created.${NC}"

# --- Create the launchd plist ---
echo -e "${YELLOW}→ Creating launchd agent...${NC}"
mkdir -p "$HOME/Library/LaunchAgents"
cat > "$PLIST_PATH" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.safariwatcher</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>$SCRIPT_PATH</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
EOF
echo -e "${GREEN}✅ Launchd agent created.${NC}"

# --- Load the agent ---
echo -e "${YELLOW}→ Starting the watcher...${NC}"

# Unload first in case it's already running
launchctl unload "$PLIST_PATH" 2>/dev/null || true
launchctl load "$PLIST_PATH"

# --- Verify ---
sleep 1
if launchctl list | grep -q "safariwatcher"; then
  echo -e "${GREEN}✅ Watcher is running!${NC}"
else
  echo -e "${RED}❌ Something went wrong. Try running: launchctl load $PLIST_PATH${NC}"
  exit 1
fi

echo ""
echo -e "${GREEN}🎉 All done! Safari will now restore your tabs when you close the window with the red X.${NC}"
echo ""
