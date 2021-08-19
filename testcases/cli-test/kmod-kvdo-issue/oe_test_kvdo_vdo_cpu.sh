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
# @Author    :   huyahui
# @Contact   :   huyahui8@163.com
# @Date      :   2021/02/04
# @License   :   Mulan PSL v2
# @Desc      :   View the CPU load of the indexw kernel thread when the VDO volume is not in use
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL "vdo kmod-kvdo"
    free_disks=$(TEST_DISK 1)
    free_disk=/dev/$(echo "${free_disks}" | awk -F " " '{for(i=1;i<=NF;i++) if ($i!~/[0-9]/)j=i;print $j}')
    test -z "${free_disk}" && exit 1
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    vdo create --name=vdo1 --device="${free_disk}" --vdoLogicalSize=1T --force
    CHECK_RESULT $?
    top -n 10 -bw >/tmp/top_result
    grep indexW /tmp/top_result | awk '{print $9}' | awk '{if($1 > 1.0) print 1}' | grep 1
    CHECK_RESULT $? 0 1
    LOG_INFO "Finish testcase execution."
}
function post_test() {
    LOG_INFO "start environment cleanup."
    vdo remove --name=vdo1
    DNF_REMOVE 1
    rm -rf /tmp/top_result
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
