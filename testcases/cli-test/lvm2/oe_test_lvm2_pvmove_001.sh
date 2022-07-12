#!/usr/bin/bash

# Copyright (c) 2022 Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   duanxuemin
# @Contact   :   duanxuemin_job@163.com
# @Date      :   2022-04-09
# @License   :   Mulan PSL v2
# @Desc      :   lvm2 command test
# ############################################
source ./common/disk_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment!"
    DNF_INSTALL lvm2
    check_free_disk
    version_id=$(cat /etc/os-release | grep "VERSION_ID" | awk -F "=" {'print$NF'} | awk -F "\"" {'print$2'})
    LOG_INFO "End to prepare the test environment!"
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    pvcreate -y /dev/${local_disk} /dev/${local_disk1}
    CHECK_RESULT $?
    pvs | grep "/dev/${local_disk}" && pvs | grep "/dev/${local_disk1}"
    CHECK_RESULT $?
    vgcreate test /dev/${local_disk} /dev/${local_disk1}
    CHECK_RESULT $?
    lvcreate -L 50MB -n lv1 test | grep 'Logical volume "lv1" created'
    CHECK_RESULT $?
    pvmove -q
    CHECK_RESULT $?
    pvmove -t 2>&1 | grep "TEST MODE: Metadata will NOT be updated and volumes will not be (de)activated"
    CHECK_RESULT $?
    if [${version_id} = "22.03"]; then
        pvmove --devices /dev/${local_disk}
        CHECK_RESULT $?
    fi
    touch /etc/lvm/profile/my.profile
    CHECK_RESULT $?
    pvmove --commandprofile my /dev/${local_disk}
    CHECK_RESULT $?
    SLEEP_WAIT 5
    pvmove --driverloaded y /dev/${local_disk1} /dev/${local_disk} | grep "Moved: 100.00%"
    CHECK_RESULT $?
    pvmove --nolocking /dev/${local_disk} /dev/${local_disk1} | grep "Moved: 100.00%"
    CHECK_RESULT $?
    pvmove --lockopt /dev/${local_disk} /dev/${local_disk1} | grep "Moved: 100.00%"
    CHECK_RESULT $?
    if [${version_id} = "22.03"]; then
        pvmove --journal my /dev/${local_disk} /dev/${local_disk1} | grep "Moved: 100.00%"
        CHECK_RESULT $?
    fi
    LOG_INFO "End executing testcase!"
}
function post_test() {
    LOG_INFO "Start environment cleanup."
    vgremove -f test
    pvremove -f /dev/${local_disk}
    pvremove -f /dev/${local_disk1}
    rm -rf /etc/lvm/profile/my.profile
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup."
}

main $@
