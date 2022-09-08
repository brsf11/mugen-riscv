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
# @Author    :   xuchunlin
# @Contact   :   xcl_job@163.com
# @Date      :   2020-04-10
# @License   :   Mulan PSL v2
# @Desc      :   File system common command test-cat
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test() {
    LOG_INFO "Start to run test."

    grep "root:x:0:0:root:/root:/bin/" /etc/passwd
    CHECK_RESULT $? 0 0 "check passwd output fail"
    cat /etc/passwd | grep "root:x:0:0:root:/root:/bin/"
    CHECK_RESULT $? 0 0 "check cat commond fail"

    cat --help 2>&1 | grep -i "Usage"
    CHECK_RESULT $? 0 0 "check cat help fail"

    LOG_INFO "End to run test."
}

main $@