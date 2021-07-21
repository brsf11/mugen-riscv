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
#@Author        :   zhujinlong
#@Contact       :   zhujinlong@163.com
#@Date          :   2020-10-12
#@License       :   Mulan PSL v2
#@Desc          :   Public class
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function deploy_env() {
    DNF_INSTALL "nfs-utils net-tools" 2
    P_SSH_CMD --node 2 --cmd "mkdir -p /shared/{automount_a,automount_b};
        echo '/shared *(rw,sync,no_root_squash)' >/etc/exports;
        systemctl stop firewalld;
        systemctl restart rpcbind;
        systemctl restart nfs;
        netstat -antulp | grep ':2049';
        showmount -e localhost | grep '/shared'
        "
    DNF_INSTALL "autofs nfs-utils"
    cat >/etc/auto.master <<EOF
+auto.master
/mnt01 /etc/auto.mnt01
EOF
    echo "nfs -rw,soft,intr ${NODE2_IPV4}:/shared" >/etc/auto.mnt01
    systemctl stop firewalld
    systemctl restart autofs
    systemctl restart nfs
    SLEEP_WAIT 5
    cd /mnt01/nfs || exit 1
    df -h | grep "${NODE2_IPV4}:/shared"
}

function clear_env() {
    systemctl stop autofs
    systemctl stop nfs
    systemctl start firewalld
    P_SSH_CMD --node 2 --cmd "rm -rf /shared;
        > /etc/exports;
        systemctl stop rpcbind;
        systemctl stop nfs;
        systemctl start firewalld
        "
    DNF_REMOVE
    rm -f /etc/auto.* /tmp/automount_pid /run/autofs.fifodevel
}
