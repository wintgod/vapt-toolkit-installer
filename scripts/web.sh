#!/bin/bash
source scripts/common.sh

install_or_skip nuclei "go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest"
install_or_skip dalfox "go install github.com/projectdiscovery/dalfox/v2@latest"
install_or_skip qsreplace "go install github.com/tomnomnom/qsreplace@latest"

if [ ! -d /opt/XSStrike ]; then
    git clone https://github.com/s0md3v/XSStrike.git /opt/XSStrike >> $LOG_FILE 2>&1
    pip3 install -r /opt/XSStrike/requirements.txt >> $LOG_FILE 2>&1
    INSTALLED+=("XSStrike")
else
    SKIPPED+=("XSStrike")
    log "[✔] XSStrike already installed"
fi
