#!/bin/bash
# rh_discovery.sh
# discription: Discovers system information critical to a hardware migration
# Author: Ken Clarke
# Versions
# version 1.0 initial release 12-12-18
# 
RELEASE=$(cat /etc/*release | grep -m 1 release)
VERSION=$(cat /etc/*release | grep -m 1 release | grep -o [4-7] | head -1)
MDATE=$(date +%F"_"%T)
OUTPUT=RH_discover_${MDATE}
ERROR_LOG=rh_discovery_log_${MDATE}
HEADER="======================================"
#Define functions
systemINFO () {
echo $HEADER
echo "RedHat Release" 
echo $HEADER
echo ""
echo $RELEASE 
echo ""
echo $HEADER
echo "CPU Information"
echo $HEADER
echo ""
cat /proc/cpuinfo
echo ""
echo $HEADER
echo "MEMORY Information"
echo $HEADER
echo ""
cat /proc/meminfo
echo ""
echo $HEADER
echo "System and BIOS information" 
echo $HEADER
echo ""
echo $HEADER
echo "Memory summary"
echo $HEADER
free
echo ""
echo $HEADER
echo "Swap file information"
echo $HEADER
swapon -s
echo ""
dmidecode 
echo ""
echo $HEADER
echo "System PCI slots"
echo $HEADER
echo ""
lspci
echo ""
}
diskFilesystemINFO () {
echo $HEADER
echo "HBA's installed"
echo $HEADER
echo ""
lspci -nn | grep -i hba
if [ $? -eq 0 ]
  then
    echo $HEADER
    echo "HBA cards installed on this system"
    echo $HEADER
    echo ""
    echo $HEADER
    echo "Available HBA ports"
    echo $HEADER
    ls -l /sys/class/fc_host  
    echo ""
    echo $HEADER
    echo "The port state online\offline"
    echo $HEADER
    cat /sys/class/fc_host/host?/port_state
    echo ""
    echo $HEADER
    echo "WWN numbers of HBA ports"
    echo $HEADER
    cat /sys/class/fc_host/host?/port_name
    echo ""
  else
    echo "NO HBA Cards installed"
    echo ""
fi
if [ -f /etc/multipath.conf ]
  then
    echo $HEADER
    echo "Multipath Information"
    multipath -ll
    echo ""
fi
echo $HEADER
echo "List of disks"
echo $HEADER
lsblk -o NAME,FSTYPE,MOUNTPOINT,UUID,SIZE,TYPE,WWN,HCTL
echo ""
echo $HEADER
echo "Mounted filesystems"
echo $HEADER
df -h 
echo ""
echo $HEADER
echo "Current fstab file"
echo $HEADER
cat /etc/fstab
echo ""
echo $HEADER
echo "Logical Volumes"
echo $HEADER
lvs -a
echo ""
echo $HEADER
echo "Volume Groups"
echo $HEADER
vgs -a
echo ""
echo $HEADER
echo "Partition List"
echo $HEADER
fdisk -l
echo ""
}
service&processINFO () {
if [ $VERSION -eq 7 ]
  then
    DEFAULT_RUN_LEVEL=$(systemctl get-default)
    echo $HEADER
    echo 'List of running services ,systemd'
    echo $HEADER
    systemctl --no-pager list-units -t service
    echo ""
    echo $HEADER
    echo "List of active systemd Targets"
    echo $HEADER
    systemctl --no-pager list-units -t target
    echo ""
    echo $HEADER
    echo "List of of services associated with the multi-user.target"
    echo $HEADER
    systemctl --no-pager list-dependencies $DEFAULT_RUN_LEVEL
    echo ""
    echo $HEADER
    echo "Systemd custom scripts and links"
    echo $HEADER
    ls /etc/systemd/system/
    echo ""
fi
echo ""
echo $HEADER
echo "list of started services using init scripts"
echo $HEADER
chkconfig --list
echo ""
echo $HEADER
echo "SYSV init scripts"
echo "$HEADER"
ls /etc/init.d/
echo ""
echo $HEADER
echo "List of processes by MEM useage"
echo $HEADER
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem
echo ""
echo $HEADER
echo "List of processes by CPU useage"
echo $HEADER
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu
echo ""
echo $HEADER
echo "List of processes by user"
w
echo ""
}
networkINFO () {
echo $HEADER
echo "NETWORK information"
echo $HEADER
ifconfig 
echo ""
ip addr show
echo ""
ip link show
echo ""
echo $HEADER
echo "Routing information"
echo $HEADER
netstat -rn
echo ""
if [ -f /proc/bonding ]
  then
    echo $HEADER
    echo "Network Bonds"
    echo $HEADER
    cat /proc/bonding
    echo ""
fi
}
packageINFO () {
echo $HEADER
echo "Installed packages"
echo $HEADER
rpm -qa
echo ""
}
#Start of script
systemINFO >> $OUTPUT 2>> $ERROR_LOG
diskFilesystemINFO >> $OUTPUT 2>> $ERROR_LOG
service&processINFO >> $OUTPUT 2>> $ERROR_LOG
networkINFO >> $OUTPUT 2>> $ERROR_LOG
packageINFO >> $OUTPUT 2>> $ERROR_LOG
cat /var/log/messages >> $OUTPUT 2>> $ERROR_LOG
