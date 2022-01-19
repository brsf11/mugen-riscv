#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more detaitest -f.

# #############################################
# @Author    :   zhanglu626
# @Contact   :   m18409319968@163.com
# @Date      :   2022/01/18
# @License   :   Mulan PSL v2
# @Desc      :   A c++ SDK
# ############################################
source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment!"
    DNF_INSTALL "libdap-devel"
    LOG_INFO "End to prepare the test environment!"
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    dap-config --help | grep "Usage: dap-config"
    CHECK_RESULT $? 0 0 "Help message is misprinted"
    dap-config --cc 2>&1 | grep "gcc"
    CHECK_RESULT $? 0 0 "GCC open failed"
    dap-config --cxx 2>&1 | grep "g++"
    CHECK_RESULT $? 0 0 "G++ open failed"
    dap-config --cflags 2>&1 | grep "libxml2"
    CHECK_RESULT $? 0 0 "Preprocessor and compiler flags failed to open"
    dap-config --libs 2>&1 | grep "ldap"
    CHECK_RESULT $? 0 0 "Failed to open lib library link information for libdap"
    dap-config --server-libs 2>&1 | grep "ldapserver"
    CHECK_RESULT $? 0 0 "Description The server- liBS server library fails to be started"
    dap-config --client-libs 2>&1 | grep "ldapclient"
    CHECK_RESULT $? 0 0 "Description The client-liBS client library fails to be started"
    dap-config --prefix 2>&1 | grep "/usr"
    CHECK_RESULT $? 0 0 "OPeNDAP failed to install the prefix"
    dap-config --version 2>&1 | grep "libdap"
    CHECK_RESULT $? 0 0 "Version message is misprinted"
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "Start environment cleanup."
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup."
}

main $@
