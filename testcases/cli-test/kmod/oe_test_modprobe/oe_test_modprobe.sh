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
# @Author    :   liujuan
# @Contact   :   lchutian@163.com
# @Date      :   2020/10/29
# @License   :   Mulan PSL v2
# @Desc      :   verify the uasge of modprobe command
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function run_test() {
    LOG_INFO "Start to run test."
    modprobe --help | grep -E "Usage:|modprobe"
    CHECK_RESULT $?
    modprobe --version | grep "kmod version"
    CHECK_RESULT $?
    SLEEP_WAIT 5 "lsmod | grep dm_log && modprobe dm_log" 2
    CHECK_RESULT $?
    SLEEP_WAIT 5 "lsmod | grep -E \"dm_log|dm_mirror\" && modprobe -a dm_log dm_mirror" 2
    CHECK_RESULT $?
    SLEEP_WAIT 5 "lsmod | grep dm_mirror && modprobe -r dm_mirror" 2
    CHECK_RESULT $?
    lsmod | grep dm_mirror
    CHECK_RESULT $? 1
    modprobe --remove-dependencies dm_log
    CHECK_RESULT $?
    modprobe -R dm_log | grep "dm_log"
    CHECK_RESULT $?
    modprobe --first-time dm_cache
    CHECK_RESULT $?
    lsmod | grep dm_cache
    CHECK_RESULT $?
    modprobe -r dm_cache
    CHECK_RESULT $?
    modprobe -f dm_cache
    CHECK_RESULT $?
    modprobe -r -f dm_cache
    CHECK_RESULT $?
    lsmod | grep dm_cache
    CHECK_RESULT $? 1
    modprobe -D dm_log | grep "insmod"
    CHECK_RESULT $?
    modprobe -c | grep "alias symbol"
    CHECK_RESULT $?
    modprobe --show-config | grep "alias symbol:"
    CHECK_RESULT $?
    dmPath=$(find /usr/lib/modules/ -name dm-log.ko)
    modprobe --show-modversions $dmPath | grep "[0-9]"
    CHECK_RESULT $?
    modprobe --dump-modversions $dmPath | grep "[0-9]"
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

main "$@"
