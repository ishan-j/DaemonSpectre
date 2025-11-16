#!/bin/bash
# --- Main Command Router ---

function wjobs() {
echo " "
echo "Current white list of jobs..."
cat /etc/daemonspectre_wlist.txt
echo " "
echo "All jobs scheduled"
cat /etc/daemonspectre_jlist.txt
echo " "
while true; do
    echo "Enter number of job to add into whitelist (e for exit): "
    read -r wj

    # Check if the input is 'e' using the correct test syntax
    if [ "$wj" == 'e' ]; then
        echo "Exiting job selection."
        exit 0
    # Check if the input is empty
    elif [ -z "$wj" ]; then
        echo "Input cannot be empty. Please enter a number or 'e'."
        continue
    # If not 'e', treat the input as a job number
    else
        # Use grep to find the job line and append it to the whitelist file
        # We use -q for silent grep and check its exit status first
        if grep -q "JOB$wj" /etc/daemonspectre_jlist.txt; then
           sudo  grep "JOB$wj" /etc/daemonspectre_jlist.txt >> /etc/daemonspectre_wlist.txt
            echo "JOB$wj added to /etc/daemonspectre_wlist.txt"
        else
            echo "Error: JOB$wj not found in /etc/daemonspectre_jlist.txt"
        fi
    fi
done

}

function sus() {

LIST_FILE="/etc/daemonspectre_jlist.txt"
WLIST_FILE="/etc/daemonspectre_wlist.txt"

# --- Initialization ---
echo "--- Job Comparison Report ---"
echo ""

# Create temporary files for processing
TEMP_SORTED_LIST=$(mktemp)
TEMP_SORTED_WLIST=$(mktemp)

# Sort the files to ensure reliable comparison later (using comm)
sort "$LIST_FILE" > "$TEMP_SORTED_LIST"
sort "$WLIST_FILE" > "$TEMP_SORTED_WLIST"

# --- 1. SAFE (Present in both files) ---
echo "##  SAFE ENTRIES (In list AND wlist)"
# comm -12 prints lines common to both sorted files
comm -12 "$TEMP_SORTED_LIST" "$TEMP_SORTED_WLIST"
echo ""

# --- 2. SUSPICIOUS (Present in list, NOT in wlist) ---
echo "## SUSPICIOUS ENTRIES (In list, NOT in wlist)"
# comm -23 prints lines unique to the first file (list)
comm -23 "$TEMP_SORTED_LIST" "$TEMP_SORTED_WLIST"
echo ""

# --- 3. CONFLICT (Present in wlist, NOT in list) ---
echo "## CONFLICT ENTRIES (In wlist, NOT in list)"
comm -13 "$TEMP_SORTED_LIST" "$TEMP_SORTED_WLIST"
echo ""

rm "$TEMP_SORTED_LIST" "$TEMP_SORTED_WLIST"

echo "--- Report Complete ---"

}

case "$1" in
    ls)
        echo "--- Active Cron Jobs for User: $USER (crontab -e) ---"
        cat /etc/daemonspectre_jlist.txt
        ;;
    
    wlist)
	 cat /etc/daemonspectre_wlist.txt
	;;   
    wjob)
	wjobs
	;;
   sus)
	sus		
	;;
     *)
        echo "DaemonSpectre: Simple Cron Job Lister"
        echo "Usage: spectre ls"
        exit 1
        ;;
esac
