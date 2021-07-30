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
# @Author    :   yanglijin
# @Contact   :   yang_lijin@qq.com
# @Date      :   2021/7/23
# @License   :   Mulan PSL v2
# @Desc      :   Add sticky bit attribute for global writable directory
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function run_test() {
    LOG_INFO "Start executing testcase."
    find / -type d -perm -0002 ! -perm -1000 -ls | grep -v proc | wc -l
    CHECK_RESULT $? 0 0 "find global writable directory failed"
    testdir=$(mktemp -d)
    test -d ${testdir}
    CHECK_RESULT $? 0 0 "exec mktemp failed"
    chmod 777 ${testdir}
    ls -al ${testdir} | awk 'NR==2' | grep "drwxrwxrwx"
    CHECK_RESULT $? 0 0 "exec chmod failed"
    find /tmp -type d -perm -0002 ! -perm -1000 -ls | grep -v proc | grep ${testdir}
    CHECK_RESULT $? 0 0 "find global writable directory(${testdir}) failed"
    chmod +t ${testdir}
    ls -al ${testdir} | awk 'NR==2' | grep "drwxrwxrwt"
    CHECK_RESULT $? 0 0 "add sticky bit attribute failed"
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "Start cleanning environment."
    rm -rf ${testdir}
    LOG_INFO "Finish environment cleanup!"
}

main "$@"

