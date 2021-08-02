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
# @Desc      :   High load reads and writes on VOD volumes
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
    vdo create --name=vdo1 --device="${free_disk}" --vdoLogicalSize=130G --force
    CHECK_RESULT $?
    mkfs.xfs -K /dev/mapper/vdo1
    CHECK_RESULT $?
    mount /dev/mapper/vdo1 /mnt/
    CHECK_RESULT $?
    for ((i = 1; i < 6; i++)); do
        dd if=/dev/zero of=/mnt/test"${i}" bs=25M count=1024
        CHECK_RESULT $?
    done
    \cp /mnt/test1 /mnt/test2 2>cp_result1 &
    \cp /mnt/test1 /mnt/test3 2>cp_result2 &
    \cp /mnt/test1 /mnt/test4 2>cp_result3 &
    \cp /mnt/test1 /mnt/test5 2>cp_result4 &
    for ((i = 1; i < 600; i++)); do
        if [ -z "$(pgrep -f cp_result)" ]; then
            break
        fi
        SLEEP_WAIT 5
    done
    for ((i = 1; i < 6; i++)); do
        num_tmp=$(wc -l cp_result"{$i}" | awk '{print $1}')
        CHECK_RESULT "${num_tmp}" 0
    done
    LOG_INFO "Finish testcase execution."
}
function post_test() {
    LOG_INFO "start environment cleanup."
    kill -9 $(pgrep -f cp_result)
    rm -rf /mnt/./*
    vdo remove --name=vdo1
    DNF_REMOVE 1
    rm -rf cp_result*
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
