#!/bin/bash
echo -e "Starting firewall \n"

#modprobe ip_conntrack
#modprobe ip_conntrack_ftp
#############
# Variables #
############
   IPTABLES=/sbin/iptables
   IF_EXT=eth0
   IF_EXT2=eth0:0
   IP_SSH=5.196.75.153


###################
# Vide les tables #
##################
echo -e "Cleaning tables \n"
  ${IPTABLES} -t mangle -F
  ${IPTABLES} -t nat -F
  ${IPTABLES} -F
  ${IPTABLES} -t mangle -X
  ${IPTABLES} -t nat -X
  ${IPTABLES} -X
  ${IPTABLES} -Z


#####################
# Regles par defaut #
####################
echo -e "Default rules ! \n"

 ## ignore_echo_broadcasts, TCP Syncookies, ip_forward
  echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts

 ## Police par defaut
  ${IPTABLES} -P INPUT DROP
  ${IPTABLES} -P OUTPUT DROP
  ${IPTABLES} -P FORWARD DROP

 ## Loopback accepte
  ${IPTABLES} -A FORWARD -i lo -o lo -j ACCEPT
  ${IPTABLES} -A INPUT -i lo -j ACCEPT
  ${IPTABLES} -A OUTPUT -o lo -j ACCEPT

 ## REJECT les fausses connex pretendues s'initialiser et sans syn
  ${IPTABLES} -A INPUT -p tcp ! --syn -m state --state NEW,INVALID -j REJECT


####################
# Regles speciales #
###################
### Creation des chaines
   ${IPTABLES} -N SPOOFED
   ${IPTABLES} -N SERVICES

### Interdit les paquets spoofes
   ${IPTABLES} -A SPOOFED -s 127.0.0.0/8 -j DROP
   ${IPTABLES} -A SPOOFED -s 169.254.0.0/12 -j DROP
   ${IPTABLES} -A SPOOFED -s 172.16.0.0/12 -j DROP
   ${IPTABLES} -A SPOOFED -s 192.168.0.0/16 -j DROP
   ${IPTABLES} -A SPOOFED -s 10.0.0.0/8 -j DROP


### INPUT autorises
echo -e "Allowed input \n"


  ### DNS
#	${IPTABLES} -A INPUT -p TCP --sport 53 -j ACCEPT
#	${IPTABLES} -A INPUT -p UDP --sport 53 -j ACCEPT

  #  ${IPTABLES} -A OUTPUT -p udp -d ${IP_SSH} --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
 #   ${IPTABLES} -A INPUT  -p udp -s ${IP_SSH} --sport 53 -m state --state ESTABLISHED     -j ACCEPT
#    ${IPTABLES} -A OUTPUT -p tcp -d ${IP_SSH} --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
#    ${IPTABLES} -A INPUT  -p tcp -s ${IP_SSH} --sport 53 -m state --state ESTABLISHED     -j ACCEPT

#${IPTABLES} -A OUTPUT -p udp -o eth0 --dport 53 -j ACCEPT
#${IPTABLES} -A INPUT -p udp -i eth0 --sport 53 -j ACCEPT
#${IPTABLES} -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
#${IPTABLES} -A FORWARD -i eth0 -o eth0 -s ${IP_SSH} -p udp --dport 53 -j ACCEPT
#${IPTABLES} -A FORWARD -i eth0 -o eth0 -s ${IP_SSH} -p tcp --dport 53 -m state --state NEW -j ACCEPT

   ### ICMP
       ## Ping (*)
       ${IPTABLES} -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
   ### TCP
       ## SSH (*)
       ${IPTABLES} -A SERVICES -p tcp -d ${IP_SSH} --dport 22 -j ACCEPT
       ${IPTABLES} -A SERVICES -p tcp -d ${IP_SSH} --dport 8448 -j ACCEPT
  ###
       ${IPTABLES} -A SERVICES -p tcp -d ${IP_SSH} --dport 3000 -j ACCEPT
  ## MAIL (*)
       ${IPTABLES} -A SERVICES -p tcp -d localhost --dport 25 -j ACCEPT
  ## HTTP
       ${IPTABLES} -A SERVICES -p tcp -d ${IP_SSH} --dport 80 -j ACCEPT
       #${IPTABLES} -A SERVICES -p tcp -d ${IP_SSH} --dport 8080 -j ACCEPT
       ${IPTABLES} -A SERVICES -p tcp -d ${IP_SSH} --dport 443 -j ACCEPT

  ## Pootle
       ${IPTABLES} -A SERVICES -p tcp -d ${IP_SSH} --dport 8000 -j ACCEPT
 ## Marven
       ${IPTABLES} -A SERVICES -p tcp -d ${IP_SSH} --dport 9200 -j ACCEPT


  ## FTP
       #${IPTABLES} -A SERVICES -p tcp -d ${IP_SSH} --dport 21 -j ACCEPT
       # ${IPTABLES} -A SERVICES -p tcp -d ${IP_SSH} --dport 20 -j ACCEPT
       # iptables -t filter -A OUTPUT -p tcp --dport 40000:50000 -j ACCEPT
  ## SVN
     ${IPTABLES} -A SERVICES -p tcp -d ${IP_SSH} --dport 3690 -j ACCEPT
  ## MLDONKEY
    #${IPTABLES} -A SERVICES -p tcp -d ${IP_SSH} --dport 4001 -j ACCEPT
    #${IPTABLES} -A SERVICES -p tcp -d ${IP_SSH} --dport 7083 -j ACCEPT
    #${IPTABLES} -A SERVICES -p tcp -d ${IP_SSH} --dport 4662 -j ACCEPT
    #${IPTABLES} -A SERVICES -p udp -d ${IP_SSH} --dport 4672 -j ACCEPT
  ## MySQL
    #  ${IPTABLES} -A SERVICES -p tcp -d ${IP_SSH} --dport 3306 -j ACCEPT
  ##
 ${IPTABLES} -A SERVICES -p tcp -d ${IP_SSH} --dport 8080 -j ACCEPT
#################################
# Ports ouverts sur le firewall #
################################
   ${IPTABLES} -A OUTPUT -j ACCEPT
   ${IPTABLES} -A INPUT -m state --state ESTABLISH,RELATED -j ACCEPT
   ${IPTABLES} -A INPUT -j SPOOFED
   ${IPTABLES} -A INPUT -i ${IF_EXT} -j SERVICES
   ${IPTABLES} -A INPUT -i ${IF_EXT2} -j SERVICES

${IPTABLES} -I INPUT -d ${IP_SSH} -p tcp --dport 80 -m string --to 700 --algo bm --string 'GET /w00tw00t.at.ISC.SANS.' -j DROP
${IPTABLES} -I INPUT -d ${IP_SSH} -p tcp --dport 443 -m string --to 700 --algo bm --string 'GET /w00tw00t.at.ISC.SANS.' -j DROP
${IPTABLES} -I INPUT -d ${IP_SSH} -p tcp --dport 80 -m string --to 700 --algo bm --string 'User-Agent: Toata dragostea mea pentru diavola' -j DROP
${IPTABLES} -I INPUT -d ${IP_SSH} -p tcp --dport 443 -m string --to 700 --algo bm --string 'User-Agent: Toata dragostea mea pentru diavola' -j DROP
${IPTABLES} -I INPUT -d ${IP_SSH} -p tcp --dport 80 -m string --to 700 --algo bm --string 'Morfeus strikes again' -j DROP
${IPTABLES} -I INPUT -d ${IP_SSH} -p tcp --dport 443 -m string --to 700 --algo bm --string 'Morfeus strikes again' -j DROP



echo "DONE !"
