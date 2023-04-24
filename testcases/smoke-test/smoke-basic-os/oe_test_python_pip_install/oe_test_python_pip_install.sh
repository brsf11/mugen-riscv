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
# @Author    :   liujingjing
# @Contact   :   liujingjing25812@163.com
# @Date      :   2022/06/24
# @License   :   Mulan PSL v2
# @Desc      :   Test the basic functions of pip3
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test() {
    LOG_INFO "Start to run test."
    pip3 install --user requests
    CHECK_RESULT $? 0 0 "Failed to execute pip3 install --user"
    test -d /root/.local/lib/python*/site-packages/requests
    CHECK_RESULT $? 0 0 "Failed to find site-packages/requests in /root"
    pip3 uninstall requests -y
    pip3 install --root /tmp requests
    CHECK_RESULT $? 0 0 "Failed to execute pip3 install --root"
    test -d /tmp/usr/local/lib/python*/site-packages/requests
    CHECK_RESULT $? 0 0 "Failed to find site-packages/requests in /tmp"
    rm -rf /tmp/usr
    pip3 install --prefix /tmp requests
    CHECK_RESULT $? 0 0 "Failed to execute pip3 install --prefix"
    ls -R /tmp | grep requests
    CHECK_RESULT $? 0 0 "Failed to find requests in /tmp"
    pip3 list | grep "charset-normalizer"
    CHECK_RESULT $? 0 0 "Failed to execute pip3 list"
    pip3 uninstall -y requests charset-normalizer
    pip3 install --no-deps requests
    CHECK_RESULT $? 0 0 "Failed to execute pip3 install --no-deps"
    pip3 list | grep "charset-normalizer"
    CHECK_RESULT $? 0 1 "Succeed to execute pip3 list"
    pip3 install --force-reinstall requests | grep Successfully
    CHECK_RESULT $? 0 0 "Failed to execute pip3 install --force-reinstall"
    pip3 install --upgrade requests | grep already
    CHECK_RESULT $? 0 0 "Failed to execute pip3 install --upgrade"
    pip3 uninstall -y requests
    pip3 install --upgrade requests | grep Successfully
    CHECK_RESULT $? 0 0 "Failed to repead execute pip3 install --upgrade"
    pip3 install --ignore-installed requests | grep "Installing collected packages" | grep certifi | grep idna | grep charset-normalizer | grep urllib3 | grep requests
    CHECK_RESULT $? 0 0 "Failed to execute pip3 install --ignore-installed"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf /tmp/lib /tmp/local
    pip3 uninstall -y requests urllib3 idna charset-normalizer certifi
    LOG_INFO "End to restore the test environment."
}

main "$@"
