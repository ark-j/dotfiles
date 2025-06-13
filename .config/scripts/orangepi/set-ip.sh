#!/bin/bash
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root priviledges"
  exit 1
fi
nmcli con modify "Wired connection 1" ipv4.addresses 192.168.1.250/24
nmcli con modify "Wired connection 1" ipv4.gateway 192.168.1.1
nmcli con modify "Wired connection 1" ipv4.dns "8.8.8.8 1.1.1.1"
nmcli con modify "Wired connection 1" ipv4.method manual
nmcli con down "Wired connection 1"
nmcli con up "Wired connection 1"
