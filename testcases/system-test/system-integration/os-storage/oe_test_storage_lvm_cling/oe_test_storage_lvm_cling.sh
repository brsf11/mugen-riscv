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
# @Desc      :   Using the way of clip to assign PV
# ############################################
source ../common/storage_disk_lib.sh
function pre_test() {
    LOG_INFO "Start loading data!"
    check_free_disk
    pvcreate -y /dev/${local_disk3}
    vgcreate opentest /dev/${local_disk3}
    vgextend opentest /dev/${local_disk} /dev/${local_disk1} /dev/${local_disk2} -y
    LOG_INFO "Loading data is complete!"
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    expect -c "
    set timeout 30
    log_file testlog
    spawn lvcreate --type raid1 -m 1 -n test --nosync -L 50MB opentest
    expect \"*\[y/n\]*\" {send \"y\r\"}
    expect eof
"
    grep -iE "error|fail|while executing" testlog
    CHECK_RESULT $? 1
    lvs -a -o +devices
    CHECK_RESULT $?
    lvextend --alloc cling -L +50MB opentest/test
    CHECK_RESULT $?
    lvs -a -o +devices
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf testlog
    vgremove -y opentest
    pvremove /dev/${local_disk3} /dev/${local_disk} /dev/${local_disk2} /${local_disk1}
    LOG_INFO "Finish environment cleanup."
}

main $@
