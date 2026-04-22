#!/bin/bash
source scripts/common.sh

log "[Crawling] Installing tools..."

run_parallel_limited \
"go install github.com/projectdiscovery/katana/cmd/katana@latest" \
"go install github.com/lc/gau/v2/cmd/gau@latest" \
"go install github.com/tomnomnom/waybackurls@latest"

run_parallel_limited \
"git clone https://github.com/hakluke/hakrawler.git /opt/hakrawler"

move_go_bins