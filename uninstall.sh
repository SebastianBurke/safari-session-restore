#!/bin/bash

# Safari Session Restore - Uninstaller
# https://github.com/sebastianburke/safari-session-restore

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo "🔴 Safari Session Restore - Uninstaller"
echo "========================================"
echo ""

SCRIPT_PATH="$HOME/safari-watcher.sh"
PLIST_PATH="$HOME/Library/LaunchAgents/com.user.safariwatcher.plist"
BACKUP_PATH="$HOME/safari-tabs-backup.txt"

echo -e "${YELLOW}→ Stopping watcher...${NC}"
launchctl unload "$PLIST_PATH" 2>/dev/null && echo -e "${GREEN}✅ Watcher stopped.${NC}" || echo "ℹ️  Watcher wasn't running."

echo -e "${YELLOW}→ Removing files...${NC}"
rm -f "$PLIST_PATH" && echo -e "${GREEN}✅ Removed launchd agent.${NC}"
rm -f "$SCRIPT_PATH" && echo -e "${GREEN}✅ Removed watcher script.${NC}"
rm -f "$BACKUP_PATH" && echo -e "${GREEN}✅ Removed tab backup file.${NC}"

echo ""
echo -e "${GREEN}🎉 Safari Session Restore has been fully removed.${NC}"
echo ""
