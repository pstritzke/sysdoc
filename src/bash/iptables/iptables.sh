#!/bin/sh

#
#                                XXXXXXXXXXXXXXXXXX
#                              XXX     Network    XXX
#                                XXXXXXXXXXXXXXXXXX
#                                        +
#                                        |
#                                        v
#  +-------------+              +------------------+
#  |table: filter| <---+        | table: nat       |
#  |chain: INPUT |     |        | chain: PREROUTING|
#  +-----+-------+     |        +--------+---------+
#        |             |                 |
#        v             |                 v
#  [local process]     |           ****************          +--------------+
#        |             +---------+ Routing decision +------> |table: filter |
#        v                         ****************          |chain: FORWARD|
# ****************                                           +------+-------+
# Routing decision                                                  |
# ****************                                                  |
#        |                                                          |
#        v                        ****************                  |
# +-------------+       +------>  Routing decision  <---------------+
# |table: nat   |       |         ****************
# |chain: OUTPUT|       |               +
# +-----+-------+       |               |
#       |               |               v
#       v               |      +-------------------+
# +--------------+      |      | table: nat        |
# |table: filter | +----+      | chain: POSTROUTING|
# |chain: OUTPUT |             +--------+----------+
# +--------------+                      |
#                                       v
#                               XXXXXXXXXXXXXXXXXX
#                             XXX    Network     XXX
#                               XXXXXXXXXXXXXXXXXX
#
# iptables [-t table] {-A|-C|-D} chain rule-specification
#
# iptables [-t table] {-A|-C|-D} chain  rule-specification
#
# iptables  [-t table] -I chain [rulenum] rule-specification
#
# iptables [-t table] -R chain rulenum  rule-specification
#
# iptables [-t table] -D chain rulenum
#
# iptables [-t table] -S [chain [rulenum]]
#
# iptables  [-t  table]  {-F|-L|-Z} [chain [rulenum]] [options...]
#
# iptables [-t table] -N chain
#
# iptables [-t table] -X [chain]
#
# iptables [-t table] -P chain target
#
# iptables [-t table]  -E  old-chain-name  new-chain-name
#
# rule-specification = [matches...] [target]
#
# match = -m matchname [per-match-options]
#
#
# Targets
# 
# can be a user defined chain
#
# ACCEPT - accepts the packet
# DROP   - drop the packet on the floor
# QUEUE  - packet will be stent to queue
# RETURN - stop traversing this chain and
#          resume ate the next rule in the
#          previeus (calling) chain. 
#
# if packet reach the end of the chain or
# a target RETURN, default policy for that
# chain is applayed.
#
# Target Extensions
#
# AUDIT
# CHECKSUM
# CLASSIFY
# DNAT
# DSCP
# LOG
#     Torn on kernel logging, will print some 
#     some information on all matching packets.
#     Log data can be read with dmesg or syslogd.
#     This is a non-terminating target and a rule
#     should be created with matching criteria.
#
#     --log-level level
#           Level of logging (numeric or see sys-
#           log.conf(5)
#    
#     --log-prefix prefix
#           Prefix log messages with specified prefix
#           up to 29 chars log
#
#     --log-uid
#           Log the userid of the process with gener-
#           ated the packet
# NFLOG
#     This target pass the packet to loaded logging
#     backend to log the packet. One or more userspace
#     processes may subscribe to the group to receive
#     the packets.
#
# ULOG
#     This target provides userspace logging of maching
#     packets. One or more userspace processes may then
#     then subscribe to various multicast groups and 
#     then receive the packets.
#     
#
# Commands
#
# -A, --append chain rule-specification
# -C, --check chain rule-specification
# -D, --delete chain rule-specification
# -D, --delete chain rulenum
# -I, --insert chain [rulenum] rule-specification
# -R, --replace chain rulenum rule-specification
# -L, --list [chain]
# -P, --policy chain target
#
# Parameters
#
# -p, --protocol protocol 
#       tcp, udp, udplite, icmp, esp, ah, sctp, all
# -s, --source address[/mask][,...]
# -d, --destination address[/mask][,...]
# -j, --jump target
# -g, --goto chain
# -i, --in-interface name
# -o, --out-interface name
# -f, --fragment
# -m, --match options module-name 
#       iptables can use extended packet matching
#       modules.
# -c, --set-counters packets bytes

IPT="/usr/sbin/iptables"
SPAMLIST="blockedip"
SPAMDROPMSG="BLOCKED IP DROP"
PUB_IF="wlp2s0"
#PUB_IP="192.168.1.65"
#PRIV_IF="wlp3s0"

modprobe ip_conntrack
modprobe ip_conntrack_ftp

echo "Stopping ipv4 firewall and deny everyone..."

iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X

echo "Starting ipv4 firewall filter table..."

# Set Default Rules
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP
 
#unlimited
$IPT -A INPUT -i lo -j ACCEPT
$IPT -A OUTPUT -o lo -j ACCEPT

# Block sync
$IPT -A INPUT -p tcp ! --syn -m state --state NEW -m limit --limit 5/m --limit-burst 7 -j LOG --log-level 7 --log-prefix "iptables: drop sync: "
$IPT -A INPUT -p tcp ! --syn -m state --state NEW -j DROP
 
# Block Fragments
$IPT -A INPUT -f -m limit --limit 5/m --limit-burst 7 -j LOG --log-level 4 --log-prefix "iptables: drop frag: "
$IPT -A INPUT -f -j DROP
 
# Block bad stuff
$IPT -A INPUT -p tcp --tcp-flags ALL FIN,URG,PSH -j DROP
$IPT -A INPUT -p tcp --tcp-flags ALL ALL -j DROP
 
$IPT -A INPUT -p tcp --tcp-flags ALL NONE -m limit --limit 5/m --limit-burst 7 -j LOG --log-level 4 --log-prefix "iptables: drop null: "
$IPT -A INPUT -p tcp --tcp-flags ALL NONE -j DROP # NULL packets
 
$IPT -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
 
$IPT -A INPUT -p tcp --tcp-flags SYN,FIN SYN,FIN -m limit --limit 5/m --limit-burst 7 -j LOG --log-level 4 --log-prefix "iptables: drop xmas: "
$IPT -A INPUT -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP #XMAS
 
$IPT -A INPUT -p tcp --tcp-flags FIN,ACK FIN -m limit --limit 5/m --limit-burst 7 -j LOG --log-level 4 --log-prefix "iptables: drop fin scan: "
$IPT -A INPUT -p tcp --tcp-flags FIN,ACK FIN -j DROP # FIN packet scans

$IPT -A INPUT -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP

##### Add your AP rules below ######

#echo 1 > /proc/sys/net/ipv4/ip_forward
#$IPT -t nat -A POSTROUTING -o ${PUB_IF} -j SNAT --to ${PUB_IP}
#$IPT -A FORWARD -i ${PRIV_IF} -o ${PUB_IF} -j ACCEPT
#$IPT -A FORWARD -i ${PUB_IF} -o ${PRIV_IF} -j ACCEPT

#$IPT -A INPUT -i ${PRIV_IF} -j ACCEPT
#$IPT -A OUTPUT -o ${PRIV_IF} -j ACCEPT

##### Server rules below ######

#echo "Allow ICMP"
#$IPT -A INPUT -i ${PUB_IF} -p icmp --icmp-type 0 -s 192.168.0.0/12 -j ACCEPT
#$IPT -A OUTPUT -o ${PUB_IF} -p icmp --icmp-type 0 -d 192.168.0.0/12 -j ACCEPT
#$IPT -A INPUT -i ${PUB_IF} -p icmp --icmp-type 8 -s 192.168.0.0/12 -j ACCEPT
#$IPT -A OUTPUT -o ${PUB_IF} -p icmp --icmp-type 8 -d 192.168.0.0/12 -j ACCEPT

#echo "Allow DNS Server"
#$IPT -A INPUT -i ${PUB_IF} -p udp --sport 1024:65535 --dport 53  -m state --state NEW,ESTABLISHED -s 192.168.0.0/16 -j ACCEPT
#$IPT -A OUTPUT -o ${PUB_IF} -p udp --sport 53 --dport 1024:65535 -m state --state ESTABLISHED -d 192.168.0.0/16 -j ACCEPT

#echo "Allow HTTP and HTTPS server"
#$IPT -A INPUT -i ${PUB_IF} -p tcp --dport 443 -m state --state NEW,ESTABLISHED -s 192.168.0.0/12 -j ACCEPT
#$IPT -A INPUT -i ${PUB_IF} -p tcp --dport 80 -m state --state NEW,ESTABLISHED -s 192.168.0.0/12 -j ACCEPT
#$IPT -A OUTPUT -o ${PUB_IF} -p tcp --sport 80 -m state --state NEW,ESTABLISHED -s 192.168.0.0/12 -j ACCEPT
#$IPT -A OUTPUT -o ${PUB_IF} -p tcp --sport 443 -m state --state NEW,ESTABLISHED -s 192.168.0.0/12 -j ACCEPT

#echo "Allow ssh server"
#$IPT -A OUTPUT -o ${PUB_IF} -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
#$IPT -A INPUT  -i ${PUB_IF} -p tcp --dport 22 -m state --state ESTABLISHED -j ACCEPT
#$IPT -A INPUT  -i ${PUB_IF} -p tcp --dport 22 -m state --state NEW -m limit --limit 3/min --limit-burst 3 -j ACCEPT

##### Add your rules below ######

echo "Allow DNS Client"
$IPT -A INPUT -i ${PUB_IF} -p udp --sport 53 --dport 1024:65535 -m state --state ESTABLISHED -j ACCEPT
$IPT -A INPUT -i ${PUB_IF} -p tcp --sport 53 --dport 1024:65535 -m state --state ESTABLISHED -j ACCEPT
$IPT -A OUTPUT -o ${PUB_IF} -p udp --sport 1024:65535 --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
$IPT -A OUTPUT -o ${PUB_IF} -p tcp --sport 1024:65535 --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT

echo "Allow Whois Client"
$IPT -A INPUT -i ${PUB_IF} -p tcp --sport 43 -m state --state ESTABLISHED -j ACCEPT
$IPT -A OUTPUT -o ${PUB_IF} -p tcp --sport 1024:65535 --dport 43 -m state --state NEW,ESTABLISHED -j ACCEPT

echo "Allow HTTP Client"
$IPT -A INPUT -i ${PUB_IF} -p tcp --sport 80 --dport 1024:65535 -m state --state ESTABLISHED -j ACCEPT
$IPT -A INPUT -i ${PUB_IF} -p tcp --sport 443 --dport 1024:65535 -m state --state ESTABLISHED -j ACCEPT
$IPT -A OUTPUT -o ${PUB_IF} -p tcp --sport 1024:65535 --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
$IPT -A OUTPUT -o ${PUB_IF} -p tcp --sport 1024:65535 --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT

echo "Allow Rsync Client"
$IPT -A OUTPUT -o ${PUB_IF} -p tcp --dport 873 -m state --state NEW,ESTABLISHED -j ACCEPT
$IPT -A INPUT -i ${PUB_IF} -p tcp --sport 873 -m state --state ESTABLISHED -j ACCEPT

echo "Allow POP3S Client"
$IPT -A OUTPUT -o ${PUB_IF} -p tcp --dport 995 -m state --state NEW,ESTABLISHED -j ACCEPT
$IPT -A INPUT -i ${PUB_IF} -p tcp --sport 995 -m state --state ESTABLISHED -j ACCEPT

echo "Allow SMTPS Client"
$IPT -A OUTPUT -o ${PUB_IF} -p tcp --dport 465 -m state --state NEW,ESTABLISHED -j ACCEPT
$IPT -A INPUT -i ${PUB_IF} -p tcp --sport 465 -m state --state ESTABLISHED -j ACCEPT

echo "Allow NTP Client"
$IPT -A OUTPUT -o ${PUB_IF} -p udp --dport 123 -m state --state NEW,ESTABLISHED -j ACCEPT
$IPT -A INPUT -i ${PUB_IF} -p udp --sport 123 -m state --state ESTABLISHED -j ACCEPT

$IPT -A INPUT -i ${PUB_IF} -p tcp --sport 21 -m state --state ESTABLISHED -j ACCEPT
$IPT -A OUTPUT -o ${PUB_IF} -p tcp --dport 21 -m state --state NEW,ESTABLISHED -j ACCEPT

echo "Allow IRC Client"
$IPT -A OUTPUT -o ${PUB_IF} -p tcp --sport 1024:65535 --dport 6667 -m state --state NEW -j ACCEPT

echo "Allow Active FTP Client"
$IPT -A INPUT -i ${PUB_IF} -p tcp --sport 20 -m state --state ESTABLISHED -j ACCEPT
$IPT -A OUTPUT -o ${PUB_IF} -p tcp --dport 20 -m state --state NEW,ESTABLISHED -j ACCEPT

echo "Allow FairCoin"
$IPT -A OUTPUT -o ${PUB_IF} -p tcp --dport 46392 -m state --state NEW,ESTABLISHED -j ACCEPT
$IPT -A INPUT -i ${PUB_IF} -p tcp --sport 46392 -m state --state ESTABLISHED -j ACCEPT

echo "Allow Dashcoin"
$IPT -A OUTPUT -o ${PUB_IF} -p tcp --dport 29080 -m state --state NEW,ESTABLISHED -j ACCEPT
$IPT -A INPUT -i ${PUB_IF} -p tcp --sport 29080 -m state --state ESTABLISHED -j ACCEPT

echo "Allow warzone2100"
$IPT -A INPUT -i ${PUB_IF} -p tcp --dport 2100 -s 192.168.0.0/12 -j ACCEPT
$IPT -A OUTPUT -o ${PUB_IF} -p tcp --sport 2100 -j ACCEPT
$IPT -A OUTPUT -o ${PUB_IF} -p tcp --dport 2100 -j ACCEPT
$IPT -A OUTPUT -o ${PUB_IF} -p tcp --dport 9990 -j ACCEPT

echo "Allow wesnoth"
$IPT -A OUTPUT -o ${PUB_IF} -p tcp --dport 15000 -m state --state NEW -j ACCEPT
$IPT -A OUTPUT -o ${PUB_IF} -p tcp --dport 14998 -m state --state NEW -j ACCEPT

echo "Allow Git"
$IPT -A OUTPUT -o ${PUB_IF} -p tcp --dport 9418 -m state --state NEW -j ACCEPT

echo "Allow ssh client"
$IPT -A OUTPUT -o ${PUB_IF} -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
$IPT -A INPUT  -i ${PUB_IF} -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT

echo "Allow Passive Connections"
$IPT -A INPUT -i ${PUB_IF} -p tcp --sport 1024:65535 --dport 1024: -m state --state ESTABLISHED,RELATED -j ACCEPT
$IPT -A OUTPUT -o ${PUB_IF} -p tcp --sport 1024:65535 --dport 1024:  -m state --state ESTABLISHED,RELATED -j ACCEPT

##### END your rules ############

# log everything else and drop
$IPT -A INPUT -j LOG --log-level 7 --log-prefix "iptables: INPUT: "
$IPT -A OUTPUT -j LOG --log-level 7 --log-prefix "iptables: OUTPUT: "
$IPT -A FORWARD -j LOG --log-level 7 --log-prefix "iptables: FORWARD: "

exit 0
