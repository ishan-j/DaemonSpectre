#!/bin/bash
# /opt/DaemonSpectre/spectre_wrapper.sh

# Path to the main script
SPECTRE_SCRIPT="/opt/DaemonSpectre/spectre.sh"

# Execute the main script with all arguments passed to the wrapper
sudo "$SPECTRE_SCRIPT" "$@"
