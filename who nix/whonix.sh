#!/bin/bash
# Extended whonix status check
. init.sh

inf(){
    echo "-| $@"
}
err(){
    echo "${red}x|$rst $@"
}
wrn(){
    echo "${yel}!|$rst $@"
}
gut(){
    echo "${green}+|$rst $@"
}
dbg(){
    echo "${grey}#|$rst $@"
}
sus(){
    echo "${magenta}=|$rst $@"
}
hlt(){
    echo "${red}?|$rst $@"
    exit 1
}


red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
blue=`tput setaf 4`
pink=`tput setaf 126`
magenta=`tput setaf 5`
grey=`tput setaf 8`
rst=`tput sgr0`
bld=`tput bold`
und=`tput smul`
yel=$yellow

qx(){
	qvm-run -p $1 -- ${@:2}
}

torified=`qx sys-whonix curl -ks https://check.torproject.org/api/ip`
systemcheck=`qx sys-whonix systemcheck -v --leak-test 2>/dev/null`

echo $torified | grep -qi "true"
relayed=$?
echo $systemcheck | grep -qi "canary check: ok"
canary=$?
echo $systemcheck | grep -qi "malloc: disabled"
retval=$?
hmalloc=$((1 - retval))
echo $systemcheck | grep -qi "proxy test result: ok"
cookie=$?
echo $systemcheck | grep -q "nothing remarkable"
kmesg=$?
echo $systemcheck | grep -qi "unit check result: ok"
firewall=$?
echo $systemcheck | grep -q ": verified"
consensus=$?
echo $systemcheck | grep -qi "sdwdate reports: success"
sdwdate=$?

ipx=`echo $torified|awk -NF: '{print $NF}'|sed 's/"//g'|sed 's/}//g'`
sleep 1
ipy=`echo $torified|awk -NF: '{print $NF}'|sed 's/"//g'|sed 's/}//g'`
sleep 1
ipc=`echo $torified|awk -NF: '{print $NF}'|sed 's/"//g'|sed 's/}//g'`

if [ $firewall -ne 0 ]; then
    echo
    echo "[   ${red}${bold}.oO)$rst   ]"
else
    echo
    echo "[   ${green}${und}.oO)$rst   ]"
fi

echo "${grey} :::: $ipx -:- $ipy -:- $ipc :::: $rst"

if [ $relayed -eq 0 ]; then
    gut "Tor connected"
else
    err "Tor not connected"
fi
if [ "$ipx" != "$ipc" ]; then
    gut "Rotation enabled"
else
    wrn "Rotation is off"
fi
echo "---------------------------------"
if [ $sdwdate -eq 0 ]; then
    gut "Sdwdate initialized"
else
    err "Sdwdate failure"
fi
if [ $hmalloc -eq 0 ]; then
    gut "Hardened malloc enabled"
else
    err "Hardened malloc offline"
fi
if [ $cookie -eq 0 ]; then
    inf "Control port started"
else
    wrn "Control port unreachable"
fi
if [ $cookie -eq 0 ]; then
    gut "Warrant canary enrolled"
else
    wrn "Warrant canary expired"
fi
echo "---------------------------------"
if [ $consensus -ne 0 ]; then
    echo
    echo "${yel}???$rst Tor consensus unverified"
fi
if [ $kmesg -ne 0 ]; then
    echo
    echo "${red}!!!$rst Kernel messages indicate fail"
fi
