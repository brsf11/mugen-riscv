#!/usr/bin/bash

#Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
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
# @Date      :   2020-04-09
# @License   :   Mulan PSL v2
# @Desc      :   Common network command test-scp
# #############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to pre test."
    testfile=$(mktemp)
    testdir=$(mktemp -d)
    LOG_INFO "Start to pre test."
}
function run_test() {
    LOG_INFO "Start to run test."
    SSH_SCP "${testfile}" "root@${NODE2_IPV4}:/tmp" "${NODE2_PASSWORD}"
    CHECK_RESULT $?
    SSH_CMD "test -f ${testfile}" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    CHECK_RESULT $?
    SSH_SCP "${testdir}" "root@${NODE2_IPV4}:/tmp" "${NODE2_PASSWORD}"
    CHECK_RESULT $?
    SSH_CMD "test -d ${testdir}" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf ${testdir} ${testfile}
    SSH_CMD "rm -rf ${testfile}" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    LOG_INFO "End to restore the test environment."
}

main "$@"
