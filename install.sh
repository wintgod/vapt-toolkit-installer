#!/bin/bash

LOG_FILE="logs/install.log"
mkdir -p logs

source scripts/common.sh

SILENT=false
UPDATE=false

for arg in "$@"; do
    [[ "$arg" == "--silent" ]] && SILENT=true
    [[ "$arg" == "--update" ]] && UPDATE=true
done

INSTALLED=()
SKIPPED=()

# Root check
if [[ $EUID -ne 0 ]]; then
    echo "Run as root"
    exit 1
fi

# -----------------------------
# GO INSTALL / UPDATE
# -----------------------------
install_go() {
    echo "[+] Installing latest Go..."

    GO_VERSION=$(curl -s https://go.dev/VERSION?m=text | head -n 1)

    wget https://go.dev/dl/${GO_VERSION}.linux-amd64.tar.gz

    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf ${GO_VERSION}.linux-amd64.tar.gz

    export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin

    if ! grep -q "/usr/local/go/bin" ~/.bashrc; then
        echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bashrc
    fi

    rm ${GO_VERSION}.linux-amd64.tar.gz
}

# -----------------------------
# SYSTEM PREP
# -----------------------------
log "Updating system..."
apt update -y >> $LOG_FILE 2>&1
apt install -y git curl wget build-essential python3 python3-pip snapd >> $LOG_FILE 2>&1

install_go

# -----------------------------
# UPDATE MODE
# -----------------------------
if $UPDATE; then
    log "Running UPDATE MODE..."

    go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
    go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
    go install github.com/projectdiscovery/naabu/v2/cmd/naabu@latest
    go install github.com/projectdiscovery/httpx/cmd/httpx@latest
    go install github.com/projectdiscovery/katana/cmd/katana@latest
    go install github.com/projectdiscovery/dalfox/v2@latest
    go install github.com/lc/gau/v2/cmd/gau@latest
    go install github.com/tomnomnom/waybackurls@latest

    move_go_bins

    log "Update complete"
    exit 0
fi

# -----------------------------
# MENU
# -----------------------------
if ! $SILENT; then
    echo "===================================="
    echo "     VAPT Toolkit Installer"
    echo "===================================="
    echo "[1] Basic"
    echo "[2] Recon"
    echo "[3] Web"
    echo "[4] Crawling / URLs"
    echo "[5] Exploitation"
    echo "[6] Wordlists"
    echo "[7] Full Install"
    echo "===================================="

    read -p "Select option: " choice
else
    choice=7
fi

case $choice in
    1) bash scripts/basic.sh ;;
    2) bash scripts/recon.sh ;;
    3) bash scripts/web.sh ;;
    4) bash scripts/crawling.sh ;;
    5) bash scripts/exploitation.sh ;;
    6) bash scripts/wordlists.sh ;;
    7)
        for script in scripts/*.sh; do
            [[ "$script" == *common.sh ]] && continue
            bash $script
        done
        ;;
    *) echo "Invalid option"; exit 1 ;;
esac

# -----------------------------
# FINAL SUMMARY
# -----------------------------
log "\n=========== SUMMARY ==========="

if [ ${#INSTALLED[@]} -gt 0 ]; then
    log "\n[+] Newly Installed:"
    printf '%s\n' "${INSTALLED[@]}" | tee -a "$LOG_FILE"
else
    log "\n[+] No new tools installed."
fi

if [ ${#SKIPPED[@]} -gt 0 ]; then
    log "\n[✔] Already Present:"
    printf '%s\n' "${SKIPPED[@]}" | tee -a "$LOG_FILE"
else
    log "\n[✔] No tools were previously installed."
fi

log "\n=========== VERIFY ==========="

verify_tool() {
    TOOL_NAME=$1
    TOOL_PATH=$2

    if command -v "$TOOL_NAME" >/dev/null 2>&1; then
        log "[✔] $TOOL_NAME installed (binary found)"
    elif [ -n "$TOOL_PATH" ] && [ -d "$TOOL_PATH" ]; then
        log "[✔] $TOOL_NAME installed (directory found)"
    else
        log "[✘] $TOOL_NAME missing"
    fi
}

# Recon
verify_tool "nmap" ""
verify_tool "masscan" ""
verify_tool "subfinder" ""
verify_tool "amass" ""
verify_tool "naabu" ""
verify_tool "httpx" ""

# Web
verify_tool "nuclei" ""
verify_tool "sqlmap" ""
verify_tool "dalfox" ""
verify_tool "gf" ""
verify_tool "qsreplace" ""
verify_tool "ffuf" ""
verify_tool "unfurl" ""

# Crawling
verify_tool "katana" ""
verify_tool "hakrawler" "/opt/hakrawler"
verify_tool "gau" ""
verify_tool "waybackurls" ""

# JS tools
verify_tool "LinkFinder" "/opt/LinkFinder"
verify_tool "jsleak" "/opt/jsleak"
verify_tool "XSStrike" "/opt/XSStrike"

# Exploitation
verify_tool "commix" "/opt/commix"
verify_tool "crlfuzz" "/opt/crlfuzz"
verify_tool "msfconsole" ""

# Wordlists
verify_tool "SecLists" "/opt/SecLists"
verify_tool "PayloadsAllTheThings" "/opt/PayloadsAllTheThings"

log "\nLog saved at: $LOG_FILE"
