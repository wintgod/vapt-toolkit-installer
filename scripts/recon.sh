#!/bin/bash
source scripts/common.sh

log "[Recon] Installing tools..."

run_parallel_limited \
"go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest" \
"go install github.com/projectdiscovery/naabu/v2/cmd/naabu@latest" \
"go install github.com/owasp-amass/amass/v4/...@master"

move_go_bins