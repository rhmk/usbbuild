#!/bin/bash
# 
# Update Hostname to DNS provided Hostname
#
hostnamectl set-hostname $(hostname)
#
# Update /etc/issue
#
cat > /etc/issue << EOI
##### DEMO SYSTEM #####
\S
Kernel \r on an \m (\l)
Name: \n
EOI
ip -o -4 addr show  $(route -n | awk ' ( $1 == "0.0.0.0" ) { print $NF } ') | awk ' { print "IP: " $4 "\n" }' >> /etc/issue

