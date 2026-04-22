#!/bin/bash

echo "Removing toolkit..."

rm -rf /opt/sqlmap /opt/XSStrike /opt/gf /opt/hakrawler
rm -rf /opt/commix /opt/crlfuzz /opt/SecLists /opt/PayloadsAllTheThings
rm -rf ~/go

echo "Done."
