#!/bin/bash
function include { . "$(dirname $(readlink -f ${0}))/include/${1}.sh"; }

include "color";
include "isRoot";
include "echo";

echo -ne "$color_red";
if [ $(isRoot) = "false" ]; then
    echo "You must be root, to execute this file!" 1>&2;
    exit 1;
fi
echo -ne "$color_reset";

function printHelp {
cat << EOF
start    - setup iptables
stop     - drop all rules
restart  - drop all rules and setup iptables again
EOF
}

case "$1" in
    "help"|"--help"|"-h"|"h")
        printHelp;
        return 0;
    ;;
esac




function AddPortForwardingV4 {
    runAndEcho "iptables -t nat -A PREROUTING -p $4 --dport $1 -i $5 -j DNAT --to ${2}:${3}";
}

function AddPortForwardingV6 {
    echo_failure "\"AddPortForwardingV6\" is not implemented!1!!";
}

function restart {
    echo_info "restarting (${color_green}${iptables}${color_reset})";
    stop;
    start;
}

function start {
    loadModules;
    echo_info "start iptables (${color_green}${iptables}${color_reset})";
    startA;
}

function stop {
    echo_info "stop iptables (${color_green}${iptables}${color_reset})";
    stopA;
}

function loadModules {
    echo_info "loading kernel modules";
    loadModulesA;
}

function updateEnv {
    case $1 in
    "4")
        iptables="iptables";
        icmp="icmp";
        dhcp="dhcp";
        igmp="igmp";
    ;;
    "6")
        iptables="ip6tables";
        icmp="icmpv6";
        dhcp="dhcpv6";
        igmp="igmpv6";
    ;;
    esac
}

function printNetInfoByInterface {
    echo -ne "$color_yellow";
    interface=$1;
    t1=$(ifconfig | grep $interface);

    if [ "$t1" != "" ]; then
        t2=$(ifconfig $interface | grep $interface);
        if [ "$t1" == "$t2" ]; then
            Current_IP=$(ip addr show $interface | grep -m 1 'inet' | awk '{print $2}');
            NET_MASK=$(netstat -rn | grep -m 1 $interface | awk '{print $3}');
            echo -e "$color_reset";
            echo -e "Interface:             ${color_green}${interface}${color_reset}";
            echo -e "Current IP-Addr.:      ${color_yellow}${Current_IP}";
        fi
    fi

    echo -ne "$color_reset";
}
