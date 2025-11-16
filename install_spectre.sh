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
if [ ! -f "$WHITELIST_FILE" ]; then
    echo "Creating central whitelist file: $WHITELIST_FILE"
    touch "$WHITELIST_FILE"
fi

JOBS_OUTPUT=$(crontab -l 2>/dev/null)
        EXIT_STATUS=$? # Capture the exit status
        
        if [ "$EXIT_STATUS" -eq 0 ] && [ -n "$JOBS_OUTPUT" ]; then
            
            echo "$JOBS_OUTPUT" | sed '1,24d' > "/etc/daemonspectre_jlist.txt"

            
        elif [ "$EXIT_STATUS" -ne 0 ]; then
            echo "Error running 'crontab -l'. Check user permissions." > "/etc/daemonspectre_jlist.txt"

        else
            echo "No crontab entries found for user $USER." > "/etc/daemonspectre_jlist.txt"

        fi



echo ""
echo "DaemonSpectre ready..."
echo "You can now run 'spectre ls' or 'spectre wlist -e' globally."
