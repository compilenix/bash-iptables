#!/bin/bash
function include { . "$(readlink -f $0)/include/$1.sh"; }

. ./iptables.sh

LAN=eth0

function startA {
    # First we flush our current rules
    $iptables -F
    $iptables -t nat -F

    $iptables -P INPUT ACCEPT
    $iptables -P OUTPUT ACCEPT
    $iptables -P FORWARD ACCEPT

    # Then we lock our services so they only work from the LAN
    $iptables -A INPUT -i lo -j ACCEPT
    #$iptables -I INPUT -j ACCEPT
    #$iptables -A INPUT -i ${LAN} -j ACCEPT
    $iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

    # ICMP (Ping)
    #$iptables -A INPUT -p ${icmp} "--${icmp}-type" echo-reply -j ACCEPT
    #$iptables -A INPUT -p ${icmp} "--${icmp}-type" echo-reply -j ACCEPT

    # for NFS server
    #$iptables -A INPUT -p tcp -m tcp --dport 111 -j ACCEPT
    #$iptables -A INPUT -p tcp -m tcp --dport 2049 -j ACCEPT
    #$iptables -A INPUT -p tcp -m tcp --dport 4000 -j ACCEPT
    #$iptables -A INPUT -p tcp -m tcp --dport 4001 -j ACCEPT
    #$iptables -A INPUT -p tcp -m tcp --dport 4002 -j ACCEPT
    #$iptables -A INPUT -p udp -m udp --dport 111 -j ACCEPT
    #$iptables -A INPUT -p udp -m udp --dport 2049 -j ACCEPT
    #$iptables -A INPUT -p udp -m udp --dport 4000 -j ACCEPT
    #$iptables -A INPUT -p udp -m udp --dport 4001 -j ACCEPT
    #$iptables -A INPUT -p udp -m udp --dport 4002 -j ACCEPT

    # Some other common services you may want to allow
    #$iptables -A INPUT -p TCP --dport 25565 -j ACCEPT # Minecraft Server
    #$iptables -A INPUT -p TCP --dport 53 -j ACCEPT # DNS Server
    #$iptables -A INPUT -p UDP --dport 53 -j ACCEPT # DNS Server
    #$iptables -A INPUT -p TCP --dport 25 -j ACCEPT # SMTP Server (insecure)
    #$iptables -A INPUT -p TCP --dport 993 -j ACCEPT # IMAP Server (secure)
    #$iptables -A INPUT -p TCP --dport 587 -j ACCEPT # SMTP Server (secure)
    #$iptables -A INPUT -p TCP --dport 143 -j ACCEPT # IMAP Server (insecure)
    #$iptables -A INPUT -p TCP --dport 22 -j ACCEPT # SSH (secure)
    #$iptables -A INPUT -p TCP --dport 8080 -j ACCEPT # Common alternative HTTP
    #$iptables -A INPUT -p TCP --dport 80 -j ACCEPT # HTTP (insecure)
    #$iptables -A INPUT -p TCP --dport 443 -j ACCEPT # HTTPS (secure)
    #$iptables -A INPUT -p TCP --dport 444 -j ACCEPT # Common alternative HTTPS

    # Port redirect (on to a local port only)
    #$iptables -t nat -A PREROUTING -p tcp --dport 8079 -i ${WAN} -j REDIRECT --to-port 22

    case $iptables in
        "ip6tables")
            echo 0 > /proc/sys/net/ipv6/conf/${LAN}/forwarding
            #echo 0 > /proc/sys/net/ipv6/conf/${WAN}/forwarding
        ;;

        "iptables")
            # Port Forwarding   From    To              To      Protocol   Comment
            #AddPortForwardingV4 30033   192.168.1.5     30033   tcp        # TeamSpeak 3 Server
            #AddPortForwardingV4 10011   192.168.1.5     10011   tcp        # TeamSpeak 3 Server
            #AddPortForwardingV4 2008    192.168.1.5      2008   tcp        # TeamSpeak 3 Server
            #AddPortForwardingV4 9987    192.168.1.5      9987   udp        # TeamSpeak 3 Server

            # NAT and forwarding policies
            #$iptables -A FORWARD -s 192.168.2.0/255.255.255.0 -j ACCEPT
            #$iptables -A FORWARD -d 192.168.2.0/255.255.255.0 -j ACCEPT
            #$iptables -A FORWARD -s 10.0.0.0/255.255.255.0 -j ACCEPT
            #$iptables -A FORWARD -d 10.0.0.0/255.255.255.0 -j ACCEPT
            #$iptables -t nat -A POSTROUTING -o ${WAN} -j MASQUERADE

            #$iptables -A INPUT -i ${WAN} -s 192.168.1.0/255.255.255.0 -j ACCEPT
            #$iptables -A INPUT -s 10.0.0.0/255.255.255.0 -j ACCEPT
            #$iptables -A INPUT -d 10.0.0.0/255.255.255.0 -j ACCEPT

            #$iptables -A FORWARD -s 10.0.0.0/255.255.255.0 -j ACCEPT
            #$iptables -A FORWARD -d 10.0.0.0/255.255.255.0 -j ACCEPT

            echo 0 > /proc/sys/net/ipv4/conf/${LAN}/forwarding
            #echo 0 > /proc/sys/net/ipv4/conf/${WAN}/forwarding
            ;;
    esac

    #$iptables -A INPUT -j DROP

    case $iptables in
    "ip6tables")
        /etc/init.d/ip6tables save
    ;;
    "iptables")
        /etc/init.d/iptables save
    ;;
    esac

}

function stopA {
    $iptables -F
    $iptables -t nat -F

    $iptables -P INPUT ACCEPT
    $iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    $iptables -P OUTPUT ACCEPT
    $iptables -P FORWARD DROP

    case $iptables in
        "ip6tables")
            echo 0 > /proc/sys/net/ipv6/conf/${LAN}/forwarding
            #echo 0 > /proc/sys/net/ipv6/conf/${WAN}/forwarding
            ;;
        "iptables")
            echo 0 > /proc/sys/net/ipv4/conf/${LAN}/forwarding
            #echo 0 > /proc/sys/net/ipv4/conf/${WAN}/forwarding
            ;;
    esac
}

function loadModulesA {
    modprobe -v ip_tables
    #modprobe -v ipt_MASQUERADE
    #modprobe -v iptable_nat
    #modprobe -v ip_set
}

case "$1" in
    "start")
        updateEnv "4"
        start

        #echo "IPv6 is disabled."
        updateEnv "6"
        start
    ;;
    "stop")
        updateEnv "4"
        stop

        #echo "IPv6 is disabled."
        updateEnv "6"
        stop
    ;;
    "restart")
        updateEnv "4"
        restart

        #echo "IPv6 is disabled."
        updateEnv "6"
        restart
    ;;
    "help"|"--help"|"-h"|"h"|*)
        printHelp
    ;;
esac
