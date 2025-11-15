1. Download and Navigate
The user clones your repo (or downloads the files) and navigates into the directory.

Bash

git clone https://github.com/YourRepo/DaemonSpectre.git
cd DaemonSpectre
2. Install and Globalize
The user makes the install script executable and runs it using sudo.

Bash

chmod +x install_spectre.sh
sudo ./install_spectre.sh
3. Build Whitelist and Audit
The user can now immediately use the global spectre command:

Bash

# Generate the initial commented whitelist and open it for editing
spectre wlist -e

# View all active jobs
spectre ls

# Audit for suspicious jobs
spectre sus
