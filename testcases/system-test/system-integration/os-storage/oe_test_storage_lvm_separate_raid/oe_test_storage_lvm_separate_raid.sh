#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   duanxuemin
# @Contact   :   52515856@qq.com
# @Date      :   2020-05-07
# @License   :   Mulan PSL v2
# @Desc      :   Separate the image of a raid volume and convert it to an LV
# ############################################
source ../common/storage_disk_lib.sh
function pre_test() {
    LOG_INFO "Start environment preparation."
    check_free_disk 
    mkfs.ext4 -F /dev/${local_disk}
    mkfs.ext4 -F /dev/${local_disk1}
    mkfs.ext4 -F /dev/${local_disk2}
    pvcreate -y /dev/${local_disk1} /dev/${local_disk}
    vgcreate openeulertest /dev/${local_disk1} /dev/${local_disk} -y
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    vgextend openeulertest /dev/${local_disk2} -y
    CHECK_RESULT $?
    lvcreate --type mirror -m 1 -L 50MB -n test openeulertest -y
    CHECK_RESULT $?
    expect -c "
    set timeout 30
    log_file testlog
    spawn lvconvert --type raid1 /dev/openeulertest/test
    expect \"*\[y/n\]*\" {send \"y\r\"}
    expect eof
"
    grep -iE "fail|error" testlog
    CHECK_RESULT $? 1
    expect -c "
    set timeout 30
    log_file testlog1
    spawn lvconvert --type mirror /dev/openeulertest/test
    expect \"*\[y/n\]*\" {send \"y\r\"}
    expect eof
"
    grep -iE "fail|error" testlog1
    CHECK_RESULT $? 1
    lvs -a -o name,copy_percent,devices openeulertest | grep test
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    lvremove -y openeulertest/test openeulertest/test1
    vgremove -y openeulertest
    pvremove /dev/${local_disk1} /dev/${local_disk2} /dev/${local_disk} -y
    rm -rf testlog*
    LOG_INFO "Finish environment cleanup."
}

main "$@"
