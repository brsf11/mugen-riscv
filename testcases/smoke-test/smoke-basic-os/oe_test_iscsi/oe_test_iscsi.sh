#!/usr/bin/bash

# Copyright (c) 2021 Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   lutianxiong
# @Contact   :   lutianxiong@huawei.com
# @Date      :   2020-07-20
# @License   :   Mulan PSL v2
# @Desc      :   open-iscsi & multipath-tools & target test
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function config_params() {
    LOG_INFO "Start to config params of the case."
    lun1=/home/iscsi_lun1_$$
    lun2=/home/iscsi_lun2_$$
    local_addr="127.0.0.1"
    iscsi_name="iqn.2020-07.org.openeuler:iscsi$$"
    firewall_status=0
    LOG_INFO "End to config params of the case."
}

function pre_test() {
    LOG_INFO "Start environment preparation."
    DNF_INSTALL "open-iscsi multipath-tools target-restore targetcli"
    dd if=/dev/zero of=$lun1 count=10 bs=1M
    dd if=/dev/zero of=$lun2 count=10 bs=1M
    systemctl status --no-pager firewalld && firewall_status=1
    systemctl stop firewalld
    mv /etc/iscsi/initiatorname.iscsi .
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    echo -e "cd /\n clearconfig confirm=true\n" | targetcli
    echo -e "cd /backstores/fileio\n create name=disk1 file_or_dev=${lun1}\n" | targetcli
    echo -e "cd /backstores/fileio\n create name=disk2 file_or_dev=${lun2}\n" | targetcli
    echo -e "cd /iscsi\n create ${iscsi_name}\n" | targetcli
    echo -e "cd /iscsi/${iscsi_name}/tpg1/acls\n create ${iscsi_name}:client\n" | targetcli
    echo -e "cd /iscsi/${iscsi_name}/tpg1/luns\n create /backstores/fileio/disk1 lun1\n" | targetcli
    echo -e "cd /iscsi/${iscsi_name}/tpg1/luns\n create /backstores/fileio/disk2 lun2\n" | targetcli
    systemctl restart target
    CHECK_RESULT $?
    echo "InitiatorName=${iscsi_name}:client" >/etc/iscsi/initiatorname.iscsi
    systemctl restart iscsid
    CHECK_RESULT $?
    iscsiadm -m discovery -t st -p ${local_addr}
    iscsiadm -m node -p ${local_addr} -l
    CHECK_RESULT $?
    systemctl restart multipathd
    CHECK_RESULT $?
    multipath -v2
    SLEEP_WAIT 3
    path1=$(multipath -ll | grep disk1 | awk '{print $1}')
    path2=$(multipath -ll | grep disk2 | awk '{print $1}')
    test -n "$path1" && test -n "$path2" || return 1
    sleep 1
    mkfs.ext4 -F /dev/mapper/"${path1}"
    CHECK_RESULT $?
    mkfs.ext4 -F /dev/mapper/"${path2}"
    CHECK_RESULT $?
    iscsiadm -m node -p ${local_addr} -u
    CHECK_RESULT $?
    iscsiadm -m node -o delete -p ${local_addr}
    CHECK_RESULT $?
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    iscsiadm -m node -p ${local_addr} -u
    iscsiadm -m node -o delete -p ${local_addr}
    systemctl stop multipathd
    systemctl stop iscsid
    systemctl stop target
    echo -e "cd /\n clearconfig confirm=true\n" | targetcli
    test -f initiatorname.iscsi && mv initiatorname.iscsi /etc/iscsi/initiatorname.iscsi
    rm -rf $lun1 $lun2
    test ${firewall_status} -eq 1 && systemctl restart firewalld
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main $@
