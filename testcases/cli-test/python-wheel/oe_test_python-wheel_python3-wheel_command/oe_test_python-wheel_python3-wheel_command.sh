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
#@Author        :   wangjingfeng
#@Contact       :   1136232498@qq.com
#@Date          :   2020/12/17
#@License       :   Mulan PSL v2
#@Desc          :   python3-wheel command parameter automation use case
####################################
source ./python3-wheel_pre.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."

    srcpath="/tmp/testwheel/wjfpkg"
    testpath="/tmp/testwheel"
    mkdir -p "${srcpath}"
    touch "${srcpath}"/__init__.py
    cp wjf.py "${srcpath}"
    cp setup.py "${testpath}"
    (
        cd "${testpath}" || exit 1
        python3 setup.py bdist_egg
    )
    DNF_INSTALL "python3-wheel"
    if [ "$(expr $(rpm -q python3-wheel | awk -F '-' '{print $3}' | awk -F '.' '{print $1"."$2}') \>= 0.32)" -eq 0 ]; then
        pre_env_old_version
    fi
    wheelpy=$(python3 -V | awk '{print $2}' | awk -F '.' '{print $1"."$2}')

    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    wheel-3 -h | grep "usage"
    CHECK_RESULT $? 0 0 "wheel-3 -h execution failed."
    wheel-3 --help | grep "usage"
    CHECK_RESULT $? 0 0 "wheel-3 --help execution failed."
    wheel-3 help | grep "usage"
    CHECK_RESULT $? 0 0 "wheel-3 help execution failed."
    wheel-3 version | grep $(rpm -q python3-wheel | awk -F '-' '{print $3}')
    CHECK_RESULT $? 0 0 "wheel-3 version execution failed."
    if [ "$(expr $(rpm -q python3-wheel | awk -F '-' '{print $3}' | awk -F '.' '{print $1"."$2}') \>= 0.32)" -eq 0 ]; then
        run_old_version
    else
        run_new_version
    fi

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    if [ "$(expr $(rpm -q python3-wheel | awk -F '-' '{print $3}' | awk -F '.' '{print $1"."$2}') \>= 0.32)" -eq 0 ]; then
        clean_old_version
    else
        clean_new_version
    fi
    DNF_REMOVE
    rm -rf "${testpath}" wjfpkg-1.0

    LOG_INFO "End to restore the test environment."
}

main "$@"
