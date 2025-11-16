#!/bin/bash
echo "---  DaemonSpectre Installation ---"

GLOBAL_COMMAND_NAME="spectre"
GLOBAL_INSTALL_PATH="/usr/local/bin/$GLOBAL_COMMAND_NAME"
JOBLIST_FILE="/etc/daemonspectre_jlist.txt"
WHITELIST_FILE="/etc/daemonspectre_wlist.txt"
CORE_SCRIPT_LOCAL="spectre.sh"

# 1. Check for required permissions
if [[ $EUID -ne 0 ]]; then
    echo "🚨 This script must be run with sudo or as root."
    exit 1
fi

echo "Installing $GLOBAL_COMMAND_NAME to $GLOBAL_INSTALL_PATH..."
cp "$CORE_SCRIPT_LOCAL" "$GLOBAL_INSTALL_PATH"
chmod +x "$GLOBAL_INSTALL_PATH"
if [ ! -f "$WHITELIST_FILE" ]; then
    echo "Creating central whitelist file: $WHITELIST_FILE"
    touch "$WHITELIST_FILE"
fi
if [ ! -f "$JOBLISTLIST_FILE" ]; then
    echo "Creating central whitelist file: $JOBLIST_FILE"
    touch "$JOBLIST_FILE"
fi

crontab -l | sed '1,23d' | awk '{print "JOB" ++i " : " $0}' > /etc/daemonspectre_jlist.txt
echo ""
echo "DaemonSpectre ready..."
echo "You can now run 'spectre ls' or 'spectre wlist -e' globally."
