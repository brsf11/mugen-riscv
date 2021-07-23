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
#@Desc          :   python2-wheel command parameter automation use case
####################################
source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."

    srcpath="/tmp/testwheel/wjfpkg"
    testpath="/tmp/testwheel"
    mkdir -p "${srcpath}"
    touch "${srcpath}"/__init__.py
    cp wjf2.py "${srcpath}"
    cp setup2.py "${testpath}"
    (
        cd "${testpath}" || exit 1
        python2 setup2.py bdist_egg
    )
    DNF_INSTALL "python2-wheel python2-pyxdg python2-keyring"
    pip2 install keyrings.alt
    wheelpy=$(python2 -V 2>&1 | awk '{print $2}' | awk -F '.' '{print $1"."$2}')

    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    wheel-2 -h | grep "usage"
    CHECK_RESULT $? 0 0 "wheel-2 -h execution failed."
    wheel-2 --help | grep "usage"
    CHECK_RESULT $? 0 0 "wheel-2 --help execution failed."
    wheel-2 help | grep "usage"
    CHECK_RESULT $? 0 0 "wheel-2 help execution failed."
    wheel-2 version | grep $(rpm -q python2-wheel | awk -F '-' '{print $3}')
    CHECK_RESULT $? 0 0 "wheel-2 version execution failed."
    wheel-2 convert "${testpath}"/dist/wjfpkg-1.0-py"${wheelpy}".egg
    [ -e wjfpkg-1.0-py"${wheelpy}"-none-any.whl ]
    CHECK_RESULT $? 0 0 "wheel-2 convert execution failed."
    wheel-2 keygen | grep "Trusting"
    CHECK_RESULT $? 0 0 "wheel-2 keygen execution failed."
    wheel-2 sign wjfpkg-1.0-py"${wheelpy}"-none-any.whl
    wheel-2 unpack wjfpkg-1.0-py"${wheelpy}"-none-any.whl
    [ -e ./wjfpkg-1.0/wjfpkg-1.0.dist-info/RECORD.jws ]
    CHECK_RESULT $? 0 0 "wheel-2 sign execution failed."
    rm -rf wjfpkg-1.0
    wheel-2 unsign wjfpkg-1.0-py"${wheelpy}"-none-any.whl
    wheel-2 unpack wjfpkg-1.0-py"${wheelpy}"-none-any.whl
    [ ! -e ./wjfpkg-1.0/wjfpkg-1.0.dist-info/RECORD.jws ]
    CHECK_RESULT $? 0 0 "wheel-2 unsign execution failed."
    wheel-2 sign wjfpkg-1.0-py"${wheelpy}"-none-any.whl
    wheel-2 verify wjfpkg-1.0-py"${wheelpy}"-none-any.whl | grep "hash"
    CHECK_RESULT $? 0 0 "wheel-2 verify execution failed."
    wheel-2 install wjfpkg-1.0-py"${wheelpy}"-none-any.whl
    pip2 list | grep "wjfpkg"
    CHECK_RESULT $? 0 0 "wheel-2 install execution failed."
    wheel-2 unpack wjfpkg-1.0-py"${wheelpy}"-none-any.whl
    [ -d wjfpkg-1.0 ]
    CHECK_RESULT $? 0 0 "wheel-2 unpack execution failed."
    wheel-2 install-scripts wjfpkg
    wjfexe | grep "wheel-2 test"
    CHECK_RESULT $? 0 0 "wheel-2 install-scripts execution failed."

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    pip2 uninstall keyrings.alt -y
    rm -rf "$(which wjfexe)"
    pip2 uninstall wjfpkg -y
    DNF_REMOVE
    rm -rf "${testpath}" wjfpkg-1.0-py"${wheelpy}"-none-any.whl wjfpkg-1.0

    LOG_INFO "End to restore the test environment."
}

main "$@"
