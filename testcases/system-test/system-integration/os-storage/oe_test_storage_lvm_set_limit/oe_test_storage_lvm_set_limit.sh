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
# @Date      :   2020-05-06
# @License   :   Mulan PSL v2
# @Desc      :   Set the upper limit of IO used by raid type volume in the background
# ############################################
source ../common/storage_disk_lib.sh
function pre_test() {
    LOG_INFO "Start environment preparation."
    check_free_disk
    pvcreate /dev/${local_disk1} -y
    vgcreate openeulertest /dev/${local_disk1} -y
    vgextend openeulertest /dev/${local_disk} -y
    vgextend openeulertest /dev/${local_disk3} -y
    vgextend openeulertest /dev/${local_disk2} -y
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    expect -c "
    set timeout 30
    log_file testlog
    spawn lvcreate --type raid10 -i 2 -m 1 -L 50MB --maxrecoveryrate 128 -n test openeulertest
    expect \"*\[y/n\]*\" {send \"y\r\"}
    expect eof
"
    grep -iE "fail|error" testlog
    CHECK_RESULT $? 1
    lvscan | grep "/dev/openeulertest/test"
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    lvremove -y openeulertest/test
    vgremove -y openeulertest
    pvremove /dev/${local_disk1} /dev/${local_disk2} /dev/${local_disk} /dev/${local_disk3}
    rm -rf testlog
    LOG_INFO "Finish environment cleanup."
}

main $@
