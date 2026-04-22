#!/bin/bash

LOG_FILE="logs/install.log"
mkdir -p logs

GREEN="\e[32m"; RED="\e[31m"; YELLOW="\e[33m"; END="\e[0m"

INSTALLED=()
SKIPPED=()

log() {
    echo -e "$1" | tee -a "$LOG_FILE"
}

install_or_skip() {
    TOOL=$1
    CMD=$2

    if command -v $TOOL >/dev/null 2>&1 || [ -d "/opt/$TOOL" ]; then
        log "${GREEN}[✔] $TOOL already installed${END}"
        SKIPPED+=("$TOOL")
    else
        log "${YELLOW}[+] Installing $TOOL...${END}"
        eval "$CMD" >> "$LOG_FILE" 2>&1
        INSTALLED+=("$TOOL")
    fi
}

update_go_tool() {
    TOOL=$1
    CMD=$2
    log "${YELLOW}[↻] Updating $TOOL...${END}"
    eval "$CMD" >> "$LOG_FILE" 2>&1
}

move_go_bins() {
    if [ -d "$HOME/go/bin" ]; then
        cp -n $HOME/go/bin/* /usr/local/bin/ 2>/dev/null
    fi
}

# -----------------------------
# PARALLEL EXECUTION
# -----------------------------

run_parallel() {
    JOBS=("$@")

    for job in "${JOBS[@]}"; do
        log "[→] Running: $job"
        eval "$job" >> "$LOG_FILE" 2>&1 &
    done

    wait
}

run_parallel_limited() {
    MAX_JOBS=$(nproc)
    count=0

    for job in "$@"; do
        log "[→] Running: $job"
        eval "$job" >> "$LOG_FILE" 2>&1 &
        ((count++))

        if (( count % MAX_JOBS == 0 )); then
            wait
        fi
    done

    wait
}