#!/bin/bash
source scripts/common.sh

log "[Basic] Installing tools..."

# APT sequential
install_or_skip nmap "apt install -y nmap"
install_or_skip masscan "apt install -y masscan"

# Parallel
run_parallel_limited \
"go install github.com/projectdiscovery/httpx/cmd/httpx@latest"

# SQLMap
if [ ! -d /opt/sqlmap ]; then
    git clone https://github.com/sqlmapproject/sqlmap.git /opt/sqlmap >> $LOG_FILE 2>&1
    ln -s /opt/sqlmap/sqlmap.py /usr/local/bin/sqlmap
    INSTALLED+=("sqlmap")
else
    SKIPPED+=("sqlmap")
    log "[✔] sqlmap already installed"
fi

move_go_bins