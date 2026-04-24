#!/bin/bash

echo "[+] Removing VAPT Toolkit..."

# Remove Git-based tools
sudo rm -rf \
/opt/sqlmap \
/opt/XSStrike \
/opt/LinkFinder \
/opt/jsleak \
/opt/commix \
/opt/crlfuzz \
/opt/hakrawler \
/opt/SecLists \
/opt/PayloadsAllTheThings

# Remove SQLMap symlink
sudo rm -f \
/usr/local/bin/sqlmap \
/usr/local/bin/amass 

# Remove Go binaries
TOOLS=(
nuclei
subfinder
naabu
httpx
katana
gau
waybackurls
dalfox
qsreplace
ffuf
)

for tool in "${TOOLS[@]}"; do
    sudo rm -f /usr/local/bin/$tool
done

# Remove Go installation
sudo rm -rf /usr/local/go
rm -rf ~/go

# Remove apt packages
sudo apt remove --purge -y nmap masscan 2>/dev/null

# Remove snap packages
if snap list | grep -q seclists; then
    sudo snap remove seclists
fi

# Remove metasploit
sudo apt remove --purge -y metasploit-framework 2>/dev/null

# Cleanup
sudo apt autoremove -y
sudo apt clean

echo "[✔] All toolkit components removed successfully"