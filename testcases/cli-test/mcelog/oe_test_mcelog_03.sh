#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author        :   zhujinlong
#@Contact       :   zhujinlong@163.com
#@Date          :   2021-1-5
#@License       :   Mulan PSL v2
#@Desc          :   mcelog is a tool used to check for hardware error on x86 Linux.
#####################################

if [ "${NODE1_FRAME}" != "x86_64" ]; then
    echo "Non X86 architecture,this function is not supported"
else
    source ${OET_PATH}/libs/locallibs/common_lib.sh

    function pre_test() {
        LOG_INFO "Start to prepare the test environment."
        DNF_INSTALL mcelog
        LOG_INFO "End to prepare the test environment."
    }

    function run_test() {
        LOG_INFO "Start to run test."
        mcelog --no-dmi
        CHECK_RESULT $?
        mcelog --filter
        CHECK_RESULT $?
        mcelog --no-filter
        CHECK_RESULT $?
        nohup mcelog --daemon --foreground &
        CHECK_RESULT $?
        kill -9 $(pgrep -f "mcelog --daemon --foreground")
        mcelog --num-errors N
        CHECK_RESULT $?
        mcelog --no-imc-log
        CHECK_RESULT $?
        mcelog --is-cpu-supported
        CHECK_RESULT $?
        LOG_INFO "End to run test."
    }

    function post_test() {
        LOG_INFO "Start to restore the test environment."
        DNF_REMOVE
        LOG_INFO "End to restore the test environment."
    }

    main "$@"
fi
