#!/bin/bash
# --- Main Command Router ---
case "$1" in
    ls)
        echo "--- 👤 Active Cron Jobs for User: $USER (crontab -e) ---"
        cat /etc/daemonspectre_jlist.txt
        ;;
    
    wlist)
	 nano /etc/daemonspectre_wlist.txt
	;;   
    *)
        echo "DaemonSpectre: Simple Cron Job Lister"
        echo "Usage: spectre ls"
        exit 1
        ;;
esac
