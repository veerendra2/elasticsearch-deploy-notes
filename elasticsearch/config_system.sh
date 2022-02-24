#!/bin/bash
# Docs: https://www.elastic.co/guide/en/elasticsearch/reference/current/setting-system-settings.html

echo "[*] Disabling swapping"
swapoff -a
# *** Perminent Config ***
# Comment out any lines that contain the word 'swap' in '/etc/fstab'

echo "[*] Configuring file discriptors for elasticseach user"
ulimit -n 65535
# *** Perminent Config ***
# echo 'elasticsearch  -  nofile  65535'| sudo tee /etc/security/limits.conf
# Ubuntu ignores the limits.conf file for processes started by init.d. To enable the limits.conf file, edit /etc/pam.d/su and uncomment the following line
# # session    required   pam_limits.so

echo "[*] Configuring mmap count "
sysctl -w vm.max_map_count=262144
# *** Perminent Config ***
# update the vm.max_map_count setting in /etc/sysctl.conf

echo "[*] Configuring number of threads"
ulimit -u 4096
# *** Perminent Config ***
# echo 'elasticsearch  -  nproc  4096'| sudo tee /etc/security/limits.conf
# Ubuntu ignores the limits.conf file for processes started by init.d. To enable the limits.conf file, edit /etc/pam.d/su and uncomment the following line
# # session    required   pam_limits.so

