#!/bin/bash
# /opt/DaemonSpectre/spectre.sh
# Core logic for DaemonSpectre

if grep -q $'\r' "$0"; then
    echo "NOTICE: Converting script to Unix format..." >> /dev/stderr
    
    # 2. Use 'tr' to delete the carriage return character
    # This reads the script's content, strips the \r, and overwrites the script file.
    # Note: Requires temporary file creation because we're modifying the source file
    TMP_FILE=$(mktemp)
    tr -d '\r' < "$0" > "$TMP_FILE"
    mv "$TMP_FILE" "$0"
    
    # Re-execute the cleaned script
    exec "$0" "$@"
fi

WHITELIST_FILE="/opt/DaemonSpectre/daemonspectre_wlist.txt"

# --- Function to get all active jobs in a clean, parsable format ---
get_all_active_jobs() {
    # 1. User Crontabs (crontab -e jobs)
    for user_file in /var/spool/cron/crontabs/* 2>/dev/null; do
        user=$(basename "$user_file")
        # List jobs, ignore comments/empty lines, and prepend user:
        crontab -u "$user" -l 2>/dev/null | grep -v '^\s*#' | grep -v '^\s*$' | awk -v u="$user" '{print u":"$0}'
    done

    # 2. System Crontabs (/etc/crontab and /etc/cron.d/)
    # Filter for non-comment/non-empty lines and prepend the filename
    grep -rE '^[0-9*@]' /etc/crontab /etc/cron.d/* 2>/dev/null | grep -v '^\s*#' | grep -v '^\s*$' | awk -F: '{
        # $1 is the filename, $2 is the line content
        # Normalize the line to USER:SCHEDULE:COMMAND format
        # System crons have 6 fields before the command (Min, Hr, Dom, Mon, Dow, User)
        if ($1 == "/etc/crontab") {
            # Normalize the line and print (User is $6, command is $7 onwards)
            print $6 ":" $1 " " $2 " " $3 " " $4 " " $5 " " $7
        } else {
            # For /etc/cron.d files, the line is 6 fields (Min...User) + command
            user=$6;
            sub(/^[^:]*:/, "", $0); # Remove filename prefix
            print $6 ":" $1 " " $2 " " $3 " " $4 " " $5 " " $7
        }
    }'
}

# --- Function to list all jobs, numbered for whitelisting ---
list_all_jobs() {
    # Get all active jobs and pipe them to a numbering utility (nl)
    get_all_active_jobs | nl -w3 -s '. '
}

# --- Function to generate the initial, commented whitelist file ---
generate_initial_whitelist() {
    # If the whitelist file doesn't exist or is empty, generate it.
    if [ ! -s "$WHITELIST_FILE" ]; then
        echo "# --- DaemonSpectre Whitelist Configuration ---" > "$WHITELIST_FILE"
        echo "# To whitelist a job, remove the '#' at the start of the line." >> "$WHITELIST_FILE"
        echo "# Lines must be in the format: USER:SCHEDULE COMMAND" >> "$WHITELIST_FILE"
        echo "" >> "$WHITELIST_FILE"
        
        # Get all jobs and comment them out before writing to the file
        get_all_active_jobs | sed 's/^/# /' >> "$WHITELIST_FILE"
        
        echo "Initial whitelist generated. Please edit it now."
    fi
}

# --- Function to show suspicious jobs ---
show_suspicious_jobs() {
    # 1. Check if the whitelist file is ready
    if [ ! -f "$WHITELIST_FILE" ]; then
        echo "🚨 ERROR: Whitelist file not found. Run 'spectre wlist -e' first to generate it."
        return 1
    fi
    
    # 2. Extract only the UNCOMMENTED (whitelisted) lines
    ACTIVE_WHITELIST=$(grep -v '^\s*#' "$WHITELIST_FILE" | grep -v '^\s*$')
    
    # 3. Get all current jobs
    ALL_JOBS=$(get_all_active_jobs)
    
    echo "--- 🚨 Suspicious Cron Jobs (Not in Whitelist) 🚨 ---"
    
    # Use process substitution to feed the active whitelist to grep
    # -F: fixed strings, -x: entire line match, -v: invert match
    echo "$ALL_JOBS" | grep -F -v -x -f <(echo "$ACTIVE_WHITELIST")
}

# --- Main execution based on command argument ---
case "$1" in
    ls)
        echo "--- 🌍 All Active Cron Jobs (Format: USER:SCHEDULE COMMAND) ---"
        list_all_jobs
        ;;
    sus)
        show_suspicious_jobs
        ;;
    wlist)
        case "$2" in
            -e)
                # Generate initial list if needed, then open editor
                generate_initial_whitelist
                ${EDITOR:-nano} "$WHITELIST_FILE"
                echo "Whitelist updated. Remember to save changes."
                ;;
            *)
                echo "--- ✅ Current Active Whitelist ---"
                grep -v '^\s*#' "$WHITELIST_FILE" | grep -v '^\s*$'
                ;;
        esac
        ;;
    *)
        echo "Usage: spectre {ls | sus | wlist [-e]}"
        exit 1
        ;;
esac
