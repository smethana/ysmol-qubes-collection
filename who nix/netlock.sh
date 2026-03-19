#!/bin/bash
# Real-time lock net access until sdwdate initialized
vm="test"
air="qvm-prefs $vm netvm none"
net="qvm-prefs $vm netvm sys-vpn"
init="info - success"
halt="info - end."

qvm-run -p --user root sys-whonix -- journalctl -f | grep -iE --line-buffered "$init|$halt" | while read l; do if [[ "$l" =~ "$halt" ]]; cmd=$air; else cmd=$net; fi; eval "$cmd"; done 
