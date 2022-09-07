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
    LOG_INFO "Start to prepare the test environment."

    id -u usertest1 || useradd testuser1
    umask_1=$(su testuser1 -c "umask")

    LOG_INFO "End to prepare the test environment."
}
function run_test() {
    LOG_INFO "Start to run test."
    bashrcFile="/etc/bashrc"
    if [ ! -e ${bashrcFile} ]; then 
        bashrcFile="/etc/skel/.bashrc"
    fi
    grep -i -B 1 umask ${bashrcFile}
    CHECK_RESULT $? 0 0 "no umask set in bashrc"
    [ -z ${umask_1} ]
    CHECK_RESULT $? 0 1 "run umask fail"
    echo 'umask 227' >>/home/testuser1/.bashrc
    source /home/testuser1/.bashrc >/dev/null
    su testuser1 -c "umask" | grep 227
    CHECK_RESULT $? 0 0 "umask set value check fail"

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    userdel -rf testuser1

    LOG_INFO "End to restore the test environment."
}

main $@
