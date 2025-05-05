#!/bin/bash

TODO_FILE="$HOME/.todolist"
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
CYAN=$(tput setaf 6)
RESET=$(tput sgr0)

add_todo() {
    local task priority=1 deadline deadline_ts
    while getopts ":p:d:" opt; do
        case $opt in
            p) priority="$OPTARG" ;;
            d) deadline="$OPTARG" ;;
            *) ;;
        esac
    done
    shift $((OPTIND -1))
    task="$*"
    
    [[ "$priority" =~ ^[0-9+$ ]] || priority=1
    if [ -n "$deadline" ]; then
        deadline_ts=$(date -d "$deadline" +%s 2>/dev/null) || deadline_ts=""
    fi
    
    local next_id=1
    [ -f "$TODO_FILE" ] && next_id=$(($(awk -F'|' 'END{print $1}' "$TODO_FILE") + 1))
    echo "${next_id}|${task}|${priority}|${deadline_ts}" >> "$TODO_FILE"
    echo "Added: #$next_id"
}

view_todos() {
    [ ! -f "$TODO_FILE" ] && return
    current_ts=$(date +%s)
    
    temp_processed=$(mktemp)
    awk -F'|' -v ts="$current_ts" '{
        adj = $3;
        if ($4 && $4 > ts) {
            hrs = int(($4 - ts)/3600)
            if (hrs < 24) adj += 5
            else if (hrs < 48) adj +=3
            else if (hrs < 72) adj +=1
        }
        print adj "|" $0
    }' "$TODO_FILE" | sort -t'|' -k1,1nr -k5,5n | cut -d'|' -f2- > "$temp_processed"

    printf "${CYAN}%-5s %-30s %-10s %-15s %-20s %s${RESET}\n" "ID" "Task" "Priority" "Adj-Prio" "Deadline" "Status"
    
    while IFS='|' read -r id task priority deadline; do
        color="" status="" deadline_str=""
        if [ -n "$deadline" ]; then
            if [ "$deadline" -lt "$current_ts" ]; then
                status="${RED}OVERDUE${RESET}"
                color="$RED"
            else
                hrs=$(( (deadline - current_ts)/3600 ))
                [ $hrs -lt 24 ] && color="$YELLOW" && status="Urgent (${hrs}h)"
                [ $hrs -ge 24 ] && [ $hrs -lt 72 ] && color="$GREEN" && status="Upcoming (${hrs}h)"
                [ $hrs -ge 72 ] && color="$GREEN" && status="Later"
                deadline_str=$(date -d "@$deadline" "+%Y-%m-%d %H:%M")
            fi
        else
            deadline_str="N/A" 
            status="${GREEN}-${RESET}"
        fi
        
        printf "%-5s ${color}%-30s${RESET} %-10s %-15s %-20s %s\n" \
               "$id" "$task" "$priority" "$(echo "$@" | awk -F'|' '{print $1}')" "$deadline_str" "$status"
    done < "$temp_processed"
    rm "$temp_processed"
}

delete_todo() {
    [ -z "$1" ] && echo "Specify ID" && return
    sed -i "/^$1|/d" "$TODO_FILE" 2>/dev/null && echo "Deleted: #$1" || echo "ID not found"
}

case $1 in
    add) shift; add_todo "$@" ;;
    view) view_todos ;;
    delete) delete_todo "$2" ;;
    *) echo "Usage: ${0##*/} {add|view|delete} [args]" ;;
esac
