#!/bin/bash
# install_spectre.sh - DaemonSpectre Installation Script

echo "--- 🛡️ DaemonSpectre Installation ---"

# 1. Determine the script's current absolute directory
# This is robust and finds the actual location of the repository.
INSTALL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Define local paths
WRAPPER_SCRIPT="$INSTALL_DIR/spectre_wrapper.sh"
GLOBAL_COMMAND="/usr/local/bin/spectre"
WHITELIST_FILE="/etc/daemonspectre_whitelist.txt"

echo "Installation directory detected: $INSTALL_DIR"

# 2. Check for required permissions
if [[ $EUID -ne 0 ]]; then
    echo "🚨 This script must be run with sudo or as root."
    exit 1
fi

# 3. Dynamic Path Update (The Fix!)
echo "Updating wrapper script with dynamic path..."
# Create a temporary file
TMP_WRAPPER=$(mktemp)

# Copy the original wrapper to the temp file
cp "$WRAPPER_SCRIPT" "$TMP_WRAPPER"

# Use 'sed' to replace the placeholder with the actual, absolute INSTALL_DIR
# We use a non-standard delimiter (~) for sed because paths contain slashes (/)
sed "s~%%INSTALL_DIR%%~$INSTALL_DIR~g" "$TMP_WRAPPER" > "$WRAPPER_SCRIPT.new"

# Move the corrected file back
mv "$WRAPPER_SCRIPT.new" "$WRAPPER_SCRIPT"

# 4. Set permissions and create the global link
echo "Setting executable permission on wrapper..."
chmod +x "$WRAPPER_SCRIPT"
chmod +x "$CORE_SCRIPT"
if [ -L "$GLOBAL_COMMAND" ]; then
    echo "Removing existing global link..."
    rm "$GLOBAL_COMMAND"
fi

echo "Creating global link: $GLOBAL_COMMAND -> $WRAPPER_SCRIPT"
ln -s "$WRAPPER_SCRIPT" "$GLOBAL_COMMAND"

# 5. Initialize central configuration files
if [ ! -f "$WHITELIST_FILE" ]; then
    echo "Creating central whitelist file: $WHITELIST_FILE"
    touch "$WHITELIST_FILE"
fi

echo ""
echo "--- ✅ DaemonSpectre Installation Complete! ---"
echo "Run 'spectre wlist -e' to set up your whitelist."
