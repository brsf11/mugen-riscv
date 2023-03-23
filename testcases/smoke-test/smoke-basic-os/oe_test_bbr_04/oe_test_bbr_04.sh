#!/usr/bin/bash

# Copyright (c) 2023. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author    	:   dingjiao
#@Contact   	:   15829797643@163.com
#@Date      	:   2022-07-06
#@License   	:   Mulan PSL v2
#@Desc      	:   modprobe/rmmod sch_fq
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test() {
    LOG_INFO "Start to run test."
    modinfo sch_fq | grep "sch_fq.ko"
    CHECK_RESULT $? 0 0 "Display sch_fq info: failed!"
    modprobe sch_fq
    CHECK_RESULT $? 0 0 "Modprobe sch_fq: failed!"
    lsmod | grep -w sch_fq
    CHECK_RESULT $? 0 0 "Check sch_fq exist: failed!"
    rmmod sch_fq
    CHECK_RESULT $? 0 0 "Remove sch_fq: failed!"
    lsmod | grep -w sch_fq
    CHECK_RESULT $? 1 0 "Check sch_fq not exist: failed!"
    LOG_INFO "End to run test."
}

main "$@"
