#!/bin/bash
source scripts/common.sh

run_parallel_limited \
"go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest" \
"go install github.com/hahwul/dalfox/v2@latest" \
"go install github.com/tomnomnom/qsreplace@latest" \
"go install github.com/tomnomnom/unfurl@latest" \
"go install github.com/ffuf/ffuf/v2@latest"

# XSStrike
if [ ! -d /opt/XSStrike ]; then
    git clone https://github.com/s0md3v/XSStrike.git /opt/XSStrike >> $LOG_FILE 2>&1
    pip3 install -r /opt/XSStrike/requirements.txt >> $LOG_FILE 2>&1
    INSTALLED+=("XSStrike")
else
    SKIPPED+=("XSStrike")
    log "[✔] XSStrike already installed"
fi

# LinkFinder
if [ ! -d /opt/LinkFinder ]; then
    log "${YELLOW}[+] Installing LinkFinder...${END}"
    git clone https://github.com/GerbenJavado/LinkFinder.git /opt/LinkFinder >> "$LOG_FILE" 2>&1
    pip3 install -r /opt/LinkFinder/requirements.txt >> "$LOG_FILE" 2>&1
    INSTALLED+=("LinkFinder")
fi

# jsleak
if [ ! -d /opt/jsleak ]; then
    log "${YELLOW}[+] Installing jsleak...${END}"
    git clone https://github.com/channyein1337/jsleak.git /opt/jsleak >> "$LOG_FILE" 2>&1
    INSTALLED+=("jsleak")
fi