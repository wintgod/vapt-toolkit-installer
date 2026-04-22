#!/bin/bash
source scripts/common.sh

read -p "SecLists: 1) Git 2) Snap: " c
if [[ "$c" == "1" ]]; then
    git clone https://github.com/danielmiessler/SecLists.git /opt/SecLists
else
    snap install seclists
fi

read -p "Install PayloadsAllTheThings? (y/n): " p
if [[ "$p" == "y" ]]; then
    git clone https://github.com/swisskyrepo/PayloadsAllTheThings.git /opt/PayloadsAllTheThings
fi
