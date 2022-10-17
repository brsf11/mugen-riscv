#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author    	:   @meitingli
#@Contact   	:   bubble_mt@outlook.com
#@Date      	:   2020-11-18
#@License   	:   Mulan PSL v2
#@Desc      	:   Take the test access of /bin
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test() {
    LOG_INFO "Start to run test."
    ls -l /bin | grep -q "/bin -> usr/bin"
    CHECK_RESULT $? 0 0 "/bin is not soft link of /usr/bin "
    diff /bin /usr/bin
    CHECK_RESULT $? 0 0 "The /bin doesn't same with /usr/bin."
    LOG_INFO "End to run test."
}

main "$@"

