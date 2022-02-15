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
# @Author    :   Classicriver_jia
# @Contact   :   classicriver_jia@foxmail.com
# @Date      :   2021.4.27
# @License   :   Mulan PSL v2
# @Desc      :   Bashrc configuring umask
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    userdel -r testuser1 && useradd testuser1
    umask_1=$(su testuser1 -c "umask")
}
function run_test() {
    LOG_INFO "Start executing testcase."
    grep -i -B 1 umask /etc/bashrc
    CHECK_RESULT $?
    [ -z ${umask_1} ]
    CHECK_RESULT $? 0 1
    echo 'umask 227' >>/home/testuser1/.bashrc
    source /home/testuser1/.bashrc >/dev/null
    su testuser1 -c "umask" | grep 227
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    userdel -r /home/testuser1
    LOG_INFO "Finish environment cleanup."
}

main $@
