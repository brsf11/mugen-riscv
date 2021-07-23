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
#@Date          :   2021/5/31
#@License       :   Mulan PSL v2
#@Desc          :   Geos command line and basic function verification
####################################
source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."

    DNF_INSTALL "gcc-c++ libstdc++-devel geos geos-devel"

    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    geos-config --prefix | grep "/usr"
    CHECK_RESULT $? 0 0 "geos-config --prefix execution failed."
    geos-config --version | grep "$(rpm -q geos | awk -F '-' '{print $2}')"
    CHECK_RESULT $? 0 0 "geos-config --version execution failed."
    geos-config --libs | grep "\-lgeos"
    CHECK_RESULT $? 0 0 "geos-config --libs execution failed."
    geos-config --clibs | grep "\-lgeos_c"
    CHECK_RESULT $? 0 0 "geos-config --clibs execution failed."
    geos-config --cclibs | grep "\-lgeos"
    CHECK_RESULT $? 0 0 "geos-config --cclibs execution failed."
    geos-config --static-clibs | grep "\-lgeos_c \-lgeos \-lm"
    CHECK_RESULT $? 0 0 "geos-config --static-clibs execution failed."
    geos-config --static-cclibs | grep "\-lgeos \-lm"
    CHECK_RESULT $? 0 0 "geos-config --static-cclibs execution failed."
    geos-config --cflags | grep "\-I/usr/include"
    CHECK_RESULT $? 0 0 "geos-config --cflags execution failed."
    geos-config --ldflags | grep "\-L/usr/lib64"
    CHECK_RESULT $? 0 0 "geos-config --ldflags execution failed."
    geos-config --includes | grep "/usr/include"
    CHECK_RESULT $? 0 0 "geos-config --includes execution failed."
    g++ geos_test.cpp -o geos_test
    ./geos_test >/tmp/geosfile
    grep "$(rpm -q geos | awk -F '-' '{print $2}')" /tmp/geosfile
    CHECK_RESULT $? 0 0 "geos-config base func execution failed."
    grep "$(geos-config --jtsport)" /tmp/geosfile
    CHECK_RESULT $? 0 0 "geos-config --jtsport execution failed."

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    DNF_REMOVE
    rm -rf ./geos_test /tmp/geosfile

    LOG_INFO "End to restore the test environment."
}

main "$@"
