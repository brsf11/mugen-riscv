#!/usr/bin/bash
# Copyright (c) [2021] Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
# @Author  : lemon-higgins
# @email   : lemon.higgins@aliyun.com
# @Date    : 2021-04-20 15:11:47
# @License : Mulan PSL v2
# @Version : 1.0
# @Desc    :
#####################################

python3 --version >/dev/null 2>&1
if [ $? -eq 0 ]; then
    source "$OET_PATH/libs/locallibs/common_lib_python.sh"
else
    source "$OET_PATH/libs/locallibs/common_lib_shell.sh"
fi

function CHECK_RESULT() {
    actual_result=$1
    expect_result=${2-0}
    mode=${3-0}
    error_log=$4

    if [ -z "$actual_result" ]; then
        LOG_ERROR "Missing actual error code."
        return 1
    fi

    if [ $mode -eq 0 ]; then
        test "$actual_result"x != "$expect_result"x && {
            test -n "$error_log" && LOG_ERROR "$error_log"
            ((exec_result++))
        }
    else
        test "$actual_result"x == "$expect_result"x && {
            test -n "$error_log" && LOG_ERROR "$error_log"
            ((exec_result++))
        }
    fi

    return 0
}

function CASE_RESULT() {
    case_re=$1

    test -z "$exec_result" && {
        test $case_re -eq 0 && {
            LOG_INFO "succeed to execute the case."
            exec_result=""
            exit 0
        }
        LOG_ERROR "failed to execute the case."
        exit $case_re
    }

    test $exec_result -gt 0 && {
        LOG_ERROR "failed to execute the case."
        exit $exec_result
    }
    LOG_INFO "succeed to execute the case."
    exit $exec_result
}

function POST_TEST_DEFAULT() {
    LOG_INFO "$0 post_test"
}

function main() {
    if [ -n "$(type -t post_test)" ]; then
        trap post_test EXIT INT HUP TERM || exit 1
    else
        trap POST_TEST_DEFAULT EXIT INT HUP TERM || exit 1
    fi

    if ! rpm -qa | grep expect >/dev/null 2>&1; then
        dnf -y install expect
    fi

    if [ -n "$(type -t config_params)" ]; then
        config_params
    fi

    if [ -n "$(type -t pre_test)" ]; then
        pre_test
    fi

    if [ -n "$(type -t run_test)" ]; then
        run_test
        CASE_RESULT $?
    fi
}
