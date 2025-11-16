#!/bin/bash
# /usr/local/bin/spectre - Core DaemonSpectre Logic

WHITELIST_FILE="/etc/daemonspectre_wlist.txt"
EDITOR_CMD="${EDITOR:-nano}"

# --- Check for root permissions (since this script runs globally) ---
if [[ $EUID -ne 0 ]]; then
    echo "🚨 Error: The 'spectre' command must be run with sudo for auditing privileges."
    exit 1
fi

# --- Function to get all active jobs in a clean format (UNITS: User:Schedule Command) ---
get_all_active_jobs() {
    # 1. User Crontabs (crontab -e jobs)
    for user_file in /var/spool/cron/crontabs/* 2>/dev/null; do
        user=$(basename "$user_file")
        crontab -u "$user" -l 2>/dev/null | grep -v '^\s*#' | grep -v '^\s*$' | awk -v u="$user" '{print u":"$0}'
    done

    # 2. System Crontabs (/etc/crontab and /etc/cron.d/)
    grep -rE '^[0-9*@]' /etc/crontab /etc/cron.d/* 2>/dev/null | grep -v '^\s*#' | grep -v '^\s*$' | awk -F: '
    {
        # Split line by spaces to identify user and command (fields 6 onwards)
        # This parsing is complex but handles the differing formats
        if (NF > 5 && $6 ~ /^[a-z_]/) { # Basic check for user field existence
            user=$6;
            sub(/^[^:]*:/, "", $0); # Remove filename prefix
            
            # Print user:schedule:command (fields 1-5 for schedule, rest for command)
            print user":"$1 " " $2 " " $3 " " $4 " " $5 " " substr($0, index($0,$7))
        }
    }'
}

# --- Command Handlers ---

list_all_jobs() {
    echo "--- 🌍 All Active Cron Jobs (Format: USER:SCHEDULE COMMAND) ---"
    get_all_active_jobs | nl -w3 -s '. '
}

generate_initial_whitelist() {
    # If the whitelist file doesn't exist, generate the commented list of all jobs
    if [ ! -s "$WHITELIST_FILE" ]; then
        echo "# --- DaemonSpectre Whitelist Configuration ---" > "$WHITELIST_FILE"
        echo "# To whitelist a job, remove the '#' at the start of the line." >> "$WHITELIST_FILE"
        echo "# Format: USER:MIN HR DOM MON DOW COMMAND" >> "$WHITELIST_FILE"
        echo "" >> "$WHITELIST_FILE"
        
        # Get all jobs, comment them out, and write to the file
        get_all_active_jobs | sed 's/^/# /' >> "$WHITELIST_FILE"
    fi
}

show_suspicious_jobs() {
    if [ ! -s "$WHITELIST_FILE" ]; then
        echo "🚨 ERROR: Whitelist is empty. Run 'spectre wlist -e' to set it up."
        return 1
    fi
    
    # 1. Extract only the UNCOMMENTED (whitelisted) lines
    ACTIVE_WHITELIST=$(grep -v '^\s*#' "$WHITELIST_FILE" | grep -v '^\s*$')
    
    # 2. Get all current active jobs
    ALL_JOBS=$(get_all_active_jobs)
    
    echo "--- 🚨 Suspicious Cron Jobs (Not in Whitelist) 🚨 ---"
    
    # 3. Use grep to filter (only print lines NOT found in the ACTIVE_WHITELIST)
    # The comparison logic: grep -F (fixed strings), -v (invert match), -x (exact line match)
    echo "$ALL_JOBS" | grep -F -v -x -f <(echo "$ACTIVE_WHITELIST")
}


# --- Main Command Router ---
case "$1" in
    ls)
        list_all_jobs
        ;;
    sus)
        show_suspicious_jobs
        ;;
    wlist)
        case "$2" in
            -e)
                generate_initial_whitelist # Ensures file exists and is populated
                "$EDITOR_CMD" "$WHITELIST_FILE"
                echo "Whitelist updated. Run 'spectre sus' to check for unknown jobs."
                ;;
            *)
                echo "--- ✅ Current Active Whitelist ---"
                grep -v '^\s*#' "$WHITELIST_FILE" | grep -v '^\s*$'
                ;;
        esac
        ;;
    *)
        echo "DaemonSpectre: Cron Job Auditing Tool"
        echo "Usage: sudo spectre {ls | sus | wlist [-e]}"
        exit 1
        ;;
esac
