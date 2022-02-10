#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   xuchunlin
# @Contact   :   xcl_job@163.com
# @Date      :   2020-04-10
# @License   :   Mulan PSL v2
# @Desc      :   Using parted shell to resize partition
# ############################################

source ../common/storage_disk_lib.sh
function config_params() {
    LOG_INFO "Start loading data!"
    check_free_disk
    local_disk="${local_disk1}"
    LOG_INFO "Loading data is complete!"
}

function pre_test() {
    LOG_INFO "Start environment preparation."
    echo -e "m\np\nn\np\n1\n\n+500M\np\nw\n" | fdisk /dev/${local_disk}
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    echo -e "print\nresizepart 1 600MiB\nprint\nquit\n" | parted /dev/${local_disk} >testlog
    grep "primary" testlog | awk -F " " '{print$3}' | grep 6[0-5][0-9]MB
    CHECK_RESULT $?

    size=$(cat /proc/partitions | grep ${local_disk}1 | awk -F " " '{print$3}')
    [ $size -gt 630000 ] || [ $size -le 520000 ]
    CHECK_RESULT $? 1
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    SLEEP_WAIT 2
    echo -e "m\np\nd\nw\n" | fdisk /dev/${local_disk}
    rm -rf testlog
    LOG_INFO "Finish environment cleanup."
}

main "$@"
