#!/bin/bash
source scripts/common.sh

log "[Recon] Installing tools..."

run_parallel_limited \
"go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest" \
"go install github.com/projectdiscovery/naabu/v2/cmd/naabu@latest"

# APT separately
install_or_skip amass "apt install -y amass"

move_go_bins