#!/usr/bin/bash
# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
# @Author    :   liujingjing
# @Contact   :   liujingjing25812@163.com
# @Date      :   2020/10/19
# @License   :   Mulan PSL v2
# @Desc      :   Public class integration
#####################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function deploy_env() {
    remote_disks=$(TEST_DISK 2)
    remote_disk=/dev/$(echo $remote_disks | awk -F " " '{for(i=1;i<=NF;i++) if ($i!~/[0-9]/)j=i;print $j}')
    P_SSH_CMD --node 2 --cmd "dnf install -y scsi-target-utils; 
        echo -e 'n\np\n1\n\n+2000M\nw' | fdisk ${remote_disk}; 
        echo -e '<target iqn.2013-12.com.make:ws.httpd>\nbacking-store ${remote_disk}\n</target>' >>/etc/tgt/targets.conf; 
        systemctl restart tgtd; 
        systemctl stop firewalld;"
    DNF_INSTALL "iscsi-initiator-utils multipath-tools device-mapper-event device-mapper"
    systemctl restart iscsid
    iscsiadm -m discovery -t sendtargets -p ${NODE2_IPV4}
    iscsiadm -m node -T iqn.2013-12.com.make:ws.httpd -l
    mpathconf --enable --with_multipathd y
    service multipathd start
    multipath -v2
    multipath -ll
    echo "
defaults {
       user_friendly_names       yes
       max_fds                   max
       queue_without_daemon      no
       flush_on_last_del         yes
}

devices {
       device {
               vendor                  \"IET \"
               product                 \"VIRTUAL-DISK\"
               path_grouping_policy    multibus
               getuid_callout          \"/sbin/scsi_id -g -u -s/block/%n\"
               path_checker            directio
               path_selector           \"round-robin 0\"
               hardware_handler        \"0\"
               failback                15
               rr_weight               priorities
               no_path_retry           queue
               rr_min_io               100
               product_blacklist       LUNZ
       }
}" >/etc/multipath.conf
    lsmod | grep dm_multipath || modprobe dm_multipath
    modprobe dm_multipath
    service multipathd restart
    chkconfig --level 345 multipathd on
}

function clear_env() {
    P_SSH_CMD --node 2 --cmd "dnf remove -y scsi-target-utils; echo -e 'd\nw\n' | fdisk ${remote_disk}"
    iscsiadm -m node --logoutall=all
    multipath -F
    DNF_REMOVE
    del_file=$(ls | grep -vE ".sh")
    rm -rf ${del_file} /tmp/disk1
}
