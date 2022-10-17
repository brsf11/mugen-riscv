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
# @Desc      :   Manually replace the device in a raid volume
# ############################################

source ../common/storage_disk_lib.sh
function pre_test() {
    LOG_INFO "Start environment preparation."
    check_free_disk
    pvcreate -y /dev/${local_disk}
    vgcreate openeulertest /dev/${local_disk}
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    vgextend openeulertest /dev/${local_disk2} /dev/${local_disk1} -y
    expect -c "
    set timeout 30
    log_file testlog
    spawn lvcreate --type raid1 -m 1 -L 50MB -n test openeulertest
    expect \"*\[y/n\]*\" {send \"y\r\"}
    expect eof
"
    grep -iE "fail|error" testlog
    CHECK_RESULT $? 1
    SLEEP_WAIT 6
    lvchange --syncaction check openeulertest/test -y
    CHECK_RESULT $?
    lvs -a -o name,copy_percent,devices openeulertest
    CHECK_RESULT $?
    expect -c "
    set timeout 30
    log_file testlog1
    spawn lvconvert --replace /dev/${local_disk} openeulertest/test 
    expect \"*\[y/n\]*\" {send \"y\r\"}
    expect eof
"
    grep -iE "fail|error" testlog1
    CHECK_RESULT $? 1
    lvs -a -o name,copy_percent,devices openeulertest
    CHECK_RESULT $?
    expect -c "
    set timeout 30
    log_file testlog2
    spawn lvconvert --replace /dev/${local_disk1} openeulertest/test /dev/${local_disk}
    expect \"*\[y/n\]*\" {send \"y\r\"}
    expect eof
"
    grep -iE "fail|error" testlog2
    CHECK_RESULT $? 1
    lvs -a -o name,copy_percent,devices openeulertest
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    lvremove -y openeulertest/test
    vgremove -y openeulertest
    pvremove -y /dev/${local_disk} /dev/${local_disk2} /dev/${local_disk1}
    rm -rf testlog*
    LOG_INFO "Finish environment cleanup."
}

main "$@"
