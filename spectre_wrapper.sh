#!/bin/bash
# /path/to/DaemonSpectre/spectre_wrapper.sh (Before Installation)

# The path below is a placeholder and will be replaced by install_spectre.sh
INSTALL_DIR="%%INSTALL_DIR%%" 

# Define the path for the core script
SPECTRE_SCRIPT="$INSTALL_DIR/spectre.sh"

# Execute the main script with root privileges
sudo "$SPECTRE_SCRIPT" "$@"
