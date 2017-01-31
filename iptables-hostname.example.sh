#!/bin/bash
function include { . "$(dirname $(readlink -f ${0}))/${1}.sh"; }

include "iptables";

LAN=eth0;

function startInput {
    # allow local loopback and already established connections
    $iptables -A INPUT -i lo -j ACCEPT -m comment --comment "local loopback";
    $iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT;

    # ICMP (Ping)
    $iptables -A INPUT -p ${icmp} "--${icmp}-type" echo-reply -m limit --limit 1/second --limit-burst 5 -j ACCEPT -m comment --comment "ping";
    $iptables -A INPUT -p ${icmp} "--${icmp}-type" echo-reply -m limit --limit 1/second --limit-burst 5 -j ACCEPT -m comment --comment "ping";
    $iptables -A INPUT -p ${icmp} "--${icmp}-type" echo-request -m limit --limit 1/second --limit-burst 5 -j ACCEPT -m comment --comment "ping";
    $iptables -A INPUT -p ${icmp} "--${icmp}-type" echo-request -m limit --limit 1/second --limit-burst 5 -j ACCEPT -m comment --comment "ping";

    #$iptables -A INPUT -p tcp -m tcp --dport 111 -j ACCEPT -m comment --comment "NFS Server";
    #$iptables -A INPUT -p tcp -m tcp --dport 2049 -j ACCEPT -m comment --comment "NFS Server";
    #$iptables -A INPUT -p tcp -m tcp --dport 4000 -j ACCEPT -m comment --comment "NFS Server";
    #$iptables -A INPUT -p tcp -m tcp --dport 4001 -j ACCEPT -m comment --comment "NFS Server";
    #$iptables -A INPUT -p tcp -m tcp --dport 4002 -j ACCEPT -m comment --comment "NFS Server";
    #$iptables -A INPUT -p udp -m udp --dport 111 -j ACCEPT -m comment --comment "NFS Server";
    #$iptables -A INPUT -p udp -m udp --dport 2049 -j ACCEPT -m comment --comment "NFS Server";
    #$iptables -A INPUT -p udp -m udp --dport 4000 -j ACCEPT -m comment --comment "NFS Server";
    #$iptables -A INPUT -p udp -m udp --dport 4001 -j ACCEPT -m comment --comment "NFS Server";
    #$iptables -A INPUT -p udp -m udp --dport 4002 -j ACCEPT -m comment --comment "NFS Server";

    # Some other common services you may want to allow
    #$iptables -A INPUT -p TCP --dport 25565 -j ACCEPT -m comment --comment "Minecraft Server";
    #$iptables -A INPUT -p TCP --dport 53 -j ACCEPT -m comment --comment "DNS Server";
    #$iptables -A INPUT -p UDP --dport 53 -j ACCEPT -m comment --comment "DNS Server";
    #$iptables -A INPUT -p TCP --dport 25 -j ACCEPT -m comment --comment "SMTP Server";
    #$iptables -A INPUT -p TCP --dport 993 -j ACCEPT -m comment --comment "IMAP Server";
    #$iptables -A INPUT -p TCP --dport 587 -j ACCEPT -m comment --comment "SMTP Server";
    #$iptables -A INPUT -p TCP --dport 143 -j ACCEPT -m comment --comment "IMAP Server";
    $iptables -A INPUT -p TCP --dport 22 -j ACCEPT -m comment --comment "SSH Server";
    #$iptables -A INPUT -p TCP --dport 8080 -j ACCEPT; # Common alternative HTTP
    $iptables -A INPUT -p TCP --dport 80 -j ACCEPT -m comment --comment "HTTP Server";
    $iptables -A INPUT -p TCP --dport 443 -j ACCEPT -m comment --comment "HTTPS Server";
    #$iptables -A INPUT -p TCP --dport 444 -j ACCEPT; # Common alternative HTTPS

    $iptables -A INPUT -p TCP --match multiport --dports 137,138,445 -j DROP -m comment --comment "Silently drop some TCP destionation ports";
    $iptables -A INPUT -p UDP --match multiport --dports 137,138,445 -j DROP -m comment --comment "Silently drop some UDP destionation ports";
}

function startForward {
    echo -n;
}

function startOutput {
    # allow local loopback and already established connections
    $iptables -A OUTPUT -o lo -j ACCEPT -m comment --comment "local loopback";
    $iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT;

    # ICMP (Ping)
    $iptables -A OUTPUT -p ${icmp} "--${icmp}-type" echo-reply -m limit --limit 1/second --limit-burst 5 -j ACCEPT -m comment --comment "ping";
    $iptables -A OUTPUT -p ${icmp} "--${icmp}-type" echo-reply -m limit --limit 1/second --limit-burst 5 -j ACCEPT -m comment --comment "ping";
    $iptables -A OUTPUT -p ${icmp} "--${icmp}-type" echo-request -m limit --limit 1/second --limit-burst 5 -j ACCEPT -m comment --comment "ping";
    $iptables -A OUTPUT -p ${icmp} "--${icmp}-type" echo-request -m limit --limit 1/second --limit-burst 5 -j ACCEPT -m comment --comment "ping";

    $iptables -A OUTPUT -p UDP --dport 53 -j ACCEPT;
    $iptables -A OUTPUT -p TCP --dport 53 -j ACCEPT;

    case $iptables in
        "ip6tables")
        ;;
        "iptables")
            $iptables -A OUTPUT -p TCP --dport 53 -m iprange --dst-range 192.168.2.11-192.168.2.13 -j ACCEPT -m comment --comment "DNS TCP from NS1 - NS3";
            $iptables -A OUTPUT -p UDP --dport 53 -m iprange --dst-range 192.168.2.11-192.168.2.13 -j ACCEPT -m comment --comment "DNS UDP from NS1 - NS3";

            $iptables -A OUTPUT -p TCP --dport 53 -d 10.0.176.22 -j ACCEPT -m comment --comment "DNS TCP to Backup NS4";
            $iptables -A OUTPUT -p UDP --dport 53 -d 10.0.176.22 -j ACCEPT -m comment --comment "DNS UDP to Backup NS4";

            $iptables -A OUTPUT -p TCP --match multiport --dports 443,22 -d someServer1.example.com -j ACCEPT -m comment --comment "someServer1";
            $iptables -A OUTPUT -p TCP --match multiport --dports 443,22 -d someServer2.example.com -j ACCEPT -m comment --comment "someServer2";
            $iptables -A OUTPUT -p TCP --match multiport --dports 443,22 -d someServer3.example.com -j ACCEPT -m comment --comment "someServer3";
            $iptables -A OUTPUT -p TCP --match multiport --dports 443,22 -d someServer4.example.com -j ACCEPT -m comment --comment "someServer4";

            $iptables -A OUTPUT -p TCP --dport 3306 -d someServer5.example.com -j ACCEPT -m comment --comment "MySQL on someServer5";
            $iptables -A OUTPUT -p TCP --dport 25 -d mail.example.com -j ACCEPT -m comment --comment "SMTP relay on mail.example.com";
       ;;
    esac

    $iptables -A OUTPUT -p TCP --match multiport --dports 80,443 -d artfiles.org -j ACCEPT -m comment --comment "debian update server";
    $iptables -A OUTPUT -p TCP --match multiport --dports 80,443 -d deb.nodesource.com -j ACCEPT -m comment --comment "nodejs update server";
    $iptables -A OUTPUT -p TCP --match multiport --dports 80,443 -d security.debian.org -j ACCEPT -m comment --comment "debian update server";

    #$iptables -A OUTPUT -j ACCEPT;
}

function startLogging {
    $iptables -N LOGGING_INPUT;
    $iptables -A LOGGING_INPUT -m limit --limit 3/second -j LOG --log-prefix "iptables unhandled (Input): " --log-level 4;

    $iptables -N LOGGING_FORWARD;
    $iptables -A LOGGING_FORWARD -m limit --limit 3/second -j LOG --log-prefix "iptables unhandled (FORWARD): " --log-level 4;

    $iptables -N LOGGING_OUTPUT;
    $iptables -A LOGGING_OUTPUT -m limit --limit 3/second -j LOG --log-prefix "iptables unhandled (OUTPUT): " --log-level 4;

    $iptables -A INPUT -j LOGGING_INPUT;
    $iptables -A FORWARD -j LOGGING_FORWARD;
    $iptables -A OUTPUT -j LOGGING_OUTPUT;
}

function startDropEverything {
    $iptables -A INPUT -j DROP;
    $iptables -A FORWARD -j DROP;
    $iptables -A OUTPUT -j DROP;
}

function startA {
    $iptables -F;
    $iptables -t nat -F;

    $iptables -P INPUT ACCEPT;
    $iptables -P FORWARD ACCEPT;
    $iptables -P OUTPUT ACCEPT;

    startInput;
    startForward;
    startOutput;

    # Port redirect (on to a local port only)
    #$iptables -t nat -A PREROUTING -p tcp --dport 8079 -i ${WAN} -j REDIRECT --to-port 22;

    case $iptables in
        "ip6tables")
            echo 0 > /proc/sys/net/ipv6/conf/${LAN}/forwarding;
            #echo 0 > /proc/sys/net/ipv6/conf/${WAN}/forwarding;
        ;;

        "iptables")
            # Port Forwarding   From    To              To      Protocol -m comment   Comment
            #AddPortForwardingV4 30033   192.168.1.5     30033   tcp;        # TeamSpeak 3 Server
            #AddPortForwardingV4 10011   192.168.1.5     10011   tcp;        # TeamSpeak 3 Server
            #AddPortForwardingV4 2008    192.168.1.5      2008   tcp;        # TeamSpeak 3 Server
            #AddPortForwardingV4 9987    192.168.1.5      9987   udp;        # TeamSpeak 3 Server

            # NAT and forwarding policies
            #$iptables -A FORWARD -s 192.168.2.0/255.255.255.0 -j ACCEPT;
            #$iptables -A FORWARD -d 192.168.2.0/255.255.255.0 -j ACCEPT;
            #$iptables -A FORWARD -s 10.0.0.0/255.255.255.0 -j ACCEPT;
            #$iptables -A FORWARD -d 10.0.0.0/255.255.255.0 -j ACCEPT;
            #$iptables -t nat -A POSTROUTING -o ${WAN} -j MASQUERADE;

            #$iptables -A INPUT -i ${WAN} -s 192.168.1.0/255.255.255.0 -j ACCEPT;
            #$iptables -A INPUT -s 10.0.0.0/255.255.255.0 -j ACCEPT;
            #$iptables -A INPUT -d 10.0.0.0/255.255.255.0 -j ACCEPT;

            #$iptables -A FORWARD -s 10.0.0.0/255.255.255.0 -j ACCEPT;
            #$iptables -A FORWARD -d 10.0.0.0/255.255.255.0 -j ACCEPT;

            echo 0 > /proc/sys/net/ipv4/conf/${LAN}/forwarding;
            #echo 0 > /proc/sys/net/ipv4/conf/${WAN}/forwarding;
            ;;
    esac

    startLogging;
    startDropEverything;

    case $iptables in
    "ip6tables")
        #/etc/init.d/ip6tables save;
        ip6tables-save > /etc/ip6tables.up.rules;
    ;;
    "iptables")
        #/etc/init.d/iptables save;
        iptables-save > /etc/iptables.up.rules;
    ;;
    esac

}

function stopA {
    $iptables -F;
    $iptables -t nat -F;
    $iptables -X;

    $iptables -P INPUT ACCEPT;
    $iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT;
    $iptables -P OUTPUT ACCEPT;
    $iptables -P FORWARD ACCEPT;

    case $iptables in
        "ip6tables")
            echo 0 > /proc/sys/net/ipv6/conf/${LAN}/forwarding;
            #echo 0 > /proc/sys/net/ipv6/conf/${WAN}/forwarding;
            ;;
        "iptables")
            echo 0 > /proc/sys/net/ipv4/conf/${LAN}/forwarding;
            #echo 0 > /proc/sys/net/ipv4/conf/${WAN}/forwarding;
            ;;
    esac
}

function loadModulesA {
    modprobe -v ip_tables;
    #modprobe -v ipt_MASQUERADE;
    #modprobe -v iptable_nat;
    #modprobe -v ip_set;
}

case "$1" in
    "start")
        updateEnv "4";
        start;

        #echo "IPv6 is disabled.";
        updateEnv "6";
        start;
    ;;
    "stop")
        updateEnv "4";
        stop;

        #echo "IPv6 is disabled.";
        updateEnv "6";
        stop;
    ;;
    "restart")
        updateEnv "4";
        restart;

        #echo "IPv6 is disabled.";
        updateEnv "6";
        restart;
    ;;
    "help"|"--help"|"-h"|"h"|*)
        printHelp;
    ;;
esac
