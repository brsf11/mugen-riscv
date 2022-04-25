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
# @Desc      :   Using tag to merge snapshots
# ############################################
source ../common/storage_disk_lib.sh
function pre_test() {
    LOG_INFO "Start environment preparation."
    check_free_disk
    mkfs.ext4 -F /dev/${local_disk}
    mkfs.ext4 -F /dev/${local_disk1}
    pvcreate -y /dev/${local_disk}
    vgcreate openeulertest /dev/${local_disk}
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    vgextend openeulertest /dev/${local_disk1} -y
    CHECK_RESULT $?
    lvcreate -y --type mirror -m 1 -L 50MB -n test openeulertest
    expect -c "
    set timeout 30
    log_file testlog
    spawn lvconvert --type raid1 /dev/openeulertest/test
    sleep 5
    expect \"*\[y/n\]*\" {send \"y\r\"}
    expect eof
"
    grep -iE "fail|error" testlog
    CHECK_RESULT $? 1
    lvs -a -o name,copy_percent,devices openeulertest | grep test
    CHECK_RESULT $?
    expect -c "
    set timeout 30
    log_file testlog1
    spawn lvconvert --splitmirror 1 --trackchanges openeulertest/test
    expect \"*\[y/n\]*\" {send \"y\r\"}
    expect eof
"
    grep -iE "fail|error" testlog1
    CHECK_RESULT $? 1
    vgchange --addtag lvm_test_tag /dev/openeulertest
    CHECK_RESULT $?

    expect -c "
    set timeout 30
    log_file testlog2
    spawn lvconvert --merge openeulertest  --background
    expect \"*\[y/n\]*\" {send \"y\r\"}
    expect eof
"
    grep -iE "fail|error" testlog2
    CHECK_RESULT $? 1
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    lvremove -y openeulertest/test
    vgremove -y openeulertest
    pvremove -y /dev/${local_disk} ${local_disk1}
    rm -rf testlog*
    LOG_INFO "Finish environment cleanup."
}

main $@
