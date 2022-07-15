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
# @Author    :   Classicriver_jia
# @Contact   :   classicriver_jia@foxmail.com
# @Date      :   2020-4-9
# @License   :   Mulan PSL v2
# @Desc      :   The system supports monitoring and testing each process
# #############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test() {
    LOG_INFO "Start to run test."

    ps -eo 'rsz,pid,comm,args,pcpu' | sort -nrk1
    CHECK_RESULT $? 0 0 "check ps -eo 'rsz,pid,comm,args,pcpu' fail"
    ps -eo 'pcpu,pid,comm,args' | sort -rk1
    CHECK_RESULT $? 0 0 "check ps -eo 'pcpu,pid,comm,args' fail"
    ps -eo 'pmem,pid,comm,args' | sort -rk1
    CHECK_RESULT $? 0 0 "check ps -eo 'pmem,pid,comm,args' fail"
    ps -eo 'stat,pid,comm,args,pcpu'
    CHECK_RESULT $? 0 0 "check ps -eo 'stat,pid,comm,args,pcpu' fail"
    ipcs -m
    CHECK_RESULT $? 0 0 "run ipcs -m fail"

    LOG_INFO "End to run test."
}

main $@
