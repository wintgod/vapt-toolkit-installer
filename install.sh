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
    log "Installing/Updating Go..."

    GO_VERSION=$(curl -s https://go.dev/VERSION?m=text | head -n 1)
    wget -q https://go.dev/dl/${GO_VERSION}.linux-amd64.tar.gz

    rm -rf /usr/local/go
    tar -C /usr/local -xzf ${GO_VERSION}.linux-amd64.tar.gz

    export PATH=$PATH:/usr/local/go/bin
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

log "\n[+] Newly Installed:"
for t in "${INSTALLED[@]}"; do log "  - $t"; done

log "\n[✔] Already Present:"
for t in "${SKIPPED[@]}"; do log "  - $t"; done

log "\n=========== VERIFY ==========="

tools=(nmap sqlmap nuclei subfinder naabu gau waybackurls katana dalfox)

for tool in "${tools[@]}"; do
    if command -v $tool >/dev/null; then
        log "[✔] $tool OK"
    else
        log "[✘] $tool missing"
    fi
done

log "\nLog: $LOG_FILE"
