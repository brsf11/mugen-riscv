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
#@Desc          :   Prepare scripts for different versions of python3-wheel
####################################
source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_env_old_version() {

    DNF_INSTALL "python3-pyxdg python3-keyring"
    pip3 install keyrings.alt

}

function run_new_version() {
    LOG_INFO "Start to run run_new_version()."

    wheel-3 convert "${testpath}"/dist/wjfpkg-1.0-py"${wheelpy}".egg
    whlpy=$(echo "${wheelpy}" | awk -F '.' '{print $1""$2}')
    [ -e wjfpkg-1.0-py"${whlpy}"-none-any.whl ]
    CHECK_RESULT $? 0 0 "wheel-3 convert execution failed."
    wheel-3 unpack wjfpkg-1.0-py"${whlpy}"-none-any.whl
    [ -d wjfpkg-1.0 ]
    CHECK_RESULT $? 0 0 "wheel-3 unpack execution failed."
    rm -rf wjfpkg-1.0-py"${whlpy}"-none-any.whl
    wheel-3 pack wjfpkg-1.0
    [ -e wjfpkg-1.0-py"${whlpy}"-none-any.whl ]
    CHECK_RESULT $? 0 0 "wheel-3 pack execution failed."

    LOG_INFO "End to run run_new_version()."
}

function run_old_version() {
    LOG_INFO "Start to run run_old_version()."

    wheel-3 convert "${testpath}"/dist/wjfpkg-1.0-py"${wheelpy}".egg
    [ -e wjfpkg-1.0-py"${wheelpy}"-none-any.whl ]
    CHECK_RESULT $? 0 0 "wheel-3 convert execution failed."
    wheel-3 keygen | grep "Trusting"
    CHECK_RESULT $? 0 0 "wheel-3 keygen execution failed."
    wheel-3 sign wjfpkg-1.0-py"${wheelpy}"-none-any.whl
    wheel-3 unpack wjfpkg-1.0-py"${wheelpy}"-none-any.whl
    [ -e ./wjfpkg-1.0/wjfpkg-1.0.dist-info/RECORD.jws ]
    CHECK_RESULT $? 0 0 "wheel-3 sign execution failed."
    rm -rf wjfpkg-1.0
    wheel-3 unsign wjfpkg-1.0-py"${wheelpy}"-none-any.whl
    wheel-3 unpack wjfpkg-1.0-py"${wheelpy}"-none-any.whl
    [ ! -e ./wjfpkg-1.0/wjfpkg-1.0.dist-info/RECORD.jws ]
    CHECK_RESULT $? 0 0 "wheel-3 unsign execution failed."
    wheel-3 sign wjfpkg-1.0-py"${wheelpy}"-none-any.whl
    wheel-3 verify wjfpkg-1.0-py"${wheelpy}"-none-any.whl | grep "hash"
    CHECK_RESULT $? 0 0 "wheel-3 verify execution failed."
    wheel-3 install wjfpkg-1.0-py"${wheelpy}"-none-any.whl
    pip3 list | grep "wjfpkg"
    CHECK_RESULT $? 0 0 "wheel-3 install execution failed."
    wheel-3 unpack wjfpkg-1.0-py"${wheelpy}"-none-any.whl
    [ -d wjfpkg-1.0 ]
    CHECK_RESULT $? 0 0 "wheel-3 unpack execution failed."
    wheel-3 install-scripts wjfpkg
    wjfexe | grep "wheel-3 test"
    CHECK_RESULT $? 0 0 "wheel-3 install-scripts execution failed."

    LOG_INFO "End to run run_old_version()."
}

function clean_old_version() {
    LOG_INFO "Start to run clean_old_version()."

    pip3 uninstall keyrings.alt -y
    rm -rf "$(which wjfexe)"
    pip3 uninstall wjfpkg -y
    rm -rf wjfpkg-1.0-py"${wheelpy}"-none-any.whl

    LOG_INFO "End to run clean_old_version()."
}

function clean_new_version() {
    LOG_INFO "Start to run clean_new_version()."

    rm -rf wjfpkg-1.0-py"${whlpy}"-none-any.whl

    LOG_INFO "End to run clean_new_version()."
}
