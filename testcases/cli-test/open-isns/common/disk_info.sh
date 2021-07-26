#!/usr/bin/bash
disk_test=$(lsblk -r --output NAME,MOUNTPOINT | awk -F '/' '/sd|vd/ { dsk=substr($1,1,3);dsks[dsk]+=1 } END { for ( i in dsks ) { if (dsks[i]==1) print i } }'|tr -d "\r"|awk 'NR==1')
echo -e "n\np\n1\n\n+2G\np\nw\n" | fdisk "/dev/${disk_test}"
echo "${disk_test}"
