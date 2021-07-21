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
# @Author    :   liujingjing
# @Contact   :   liujingjing25812@163.com
# @Date      :   2020/10/30
# @License   :   Mulan PSL v2
# @Desc      :   The usage of commands in libwbxml package
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL libwbxml
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    xml2wbxml -o input.wbxml input.xml
    wbxml2xml -o output.xml input.wbxml
    CHECK_RESULT $?
    grep -i "Polic" output.xml
    CHECK_RESULT $?
    diff -w input.xml output.xml
    CHECK_RESULT $?
    cp output.xml output.xml-bak
    wbxml2xml -m 0 -o output.xml input.wbxml
    CHECK_RESULT $?
    grep "><" output.xml
    CHECK_RESULT $?
    wbxml2xml -m 1 -o output.xml input.wbxml
    CHECK_RESULT $?
    diff output.xml output.xml-bak
    CHECK_RESULT $?
    wbxml2xml -m 2 -o output.xml input.wbxml
    CHECK_RESULT $?
    grep "><" output.xml
    CHECK_RESULT $?
    wbxml2xml -i 8 -o output.xml input.wbxml
    CHECK_RESULT $?
    wc -c output.xml | grep "321"
    CHECK_RESULT $?
    rm -rf output.xml
    wbxml2xml -k -o output.xml input.wbxml
    CHECK_RESULT $?
    test -f output.xml
    CHECK_RESULT $?
    wbxml2xml -l WML10 -o output.xml input.wbxml
    CHECK_RESULT $?
    grep "WML 1.0" output.xml
    CHECK_RESULT $?
    wbxml2xml -l WML11 -o output.xml input.wbxml
    CHECK_RESULT $?
    grep "WML 1.1" output.xml
    CHECK_RESULT $?
    wbxml2xml -l WML12 -o output.xml input.wbxml
    CHECK_RESULT $?
    grep "WML 1.2" output.xml
    CHECK_RESULT $?
    wbxml2xml -l WML13 -o output.xml input.wbxml
    CHECK_RESULT $?
    grep "WML 1.3" output.xml
    CHECK_RESULT $?
    wbxml2xml -l CSP11 -o output.xml input.wbxml
    CHECK_RESULT $?
    grep "CSP 1.1" output.xml
    CHECK_RESULT $?
    wbxml2xml -l CSP12 -o output.xml input.wbxml
    CHECK_RESULT $?
    grep "CSP 1.2" output.xml
    CHECK_RESULT $?
    wbxml2xml -l WTA10 -o output.xml input.wbxml
    CHECK_RESULT $?
    grep "WTA 1.0" output.xml
    CHECK_RESULT $?
    wbxml2xml -l WTAWML12 -o output.xml input.wbxml
    CHECK_RESULT $?
    grep "WTA-WML 1.2" output.xml
    CHECK_RESULT $?
    wbxml2xml -l CHANNEL11 -o output.xml input.wbxml
    CHECK_RESULT $?
    grep "CHANNEL 1.1" output.xml
    CHECK_RESULT $?
    wbxml2xml -l CHANNEL12 -o output.xml input.wbxml
    CHECK_RESULT $?
    grep "CHANNEL 1.2" output.xml
    CHECK_RESULT $?
    wbxml2xml -l SI10 -o output.xml input.wbxml
    CHECK_RESULT $?
    grep "SI 1.0" output.xml
    CHECK_RESULT $?
    wbxml2xml -l SL10 -o output.xml input.wbxml
    CHECK_RESULT $?
    grep "SL 1.0" output.xml
    CHECK_RESULT $?
    wbxml2xml -l CO10 -o output.xml input.wbxml
    CHECK_RESULT $?
    grep "CO 1.0" output.xml
    CHECK_RESULT $?
    wbxml2xml -l PROV10 -o output.xml input.wbxml
    CHECK_RESULT $?
    grep "PROV 1.0" output.xml
    CHECK_RESULT $?
    wbxml2xml -l EMN10 -o output.xml input.wbxml
    CHECK_RESULT $?
    grep "EMN 1.0" output.xml
    CHECK_RESULT $?
    wbxml2xml -l DRMREL10 -o output.xml input.wbxml
    CHECK_RESULT $?
    grep "DRMREL 1.0" output.xml
    CHECK_RESULT $?
    wbxml2xml -l SYNCML10 -o output.xml input.wbxml
    CHECK_RESULT $?
    grep "SyncML 1.0" output.xml
    CHECK_RESULT $?
    wbxml2xml -l DEVINF10 -o output.xml input.wbxml
    CHECK_RESULT $?
    grep "DevInf 1.0" output.xml
    CHECK_RESULT $?
    wbxml2xml -l SYNCML11 -o output.xml input.wbxml
    CHECK_RESULT $?
    grep "SyncML 1.1" output.xml
    CHECK_RESULT $?
    wbxml2xml -l DEVINF11 -o output.xml input.wbxml
    CHECK_RESULT $?
    grep "DevInf 1.1" output.xml
    CHECK_RESULT $?
    wbxml2xml -l METINF11 -o output.xml input.wbxml
    CHECK_RESULT $?
    grep "MetInf 1.1" output.xml
    CHECK_RESULT $?
    wbxml2xml -l SYNCML12 -o output.xml input.wbxml
    CHECK_RESULT $?
    grep "SyncML 1.2" output.xml
    CHECK_RESULT $?
    wbxml2xml -l DEVINF12 -o output.xml input.wbxml
    CHECK_RESULT $?
    grep "DevInf 1.2" output.xml
    CHECK_RESULT $?
    wbxml2xml -l METINF12 -o output.xml input.wbxml
    CHECK_RESULT $?
    grep "MetInf 1.2" output.xml
    CHECK_RESULT $?
    wbxml2xml -l DMDDF12 -o output.xml input.wbxml
    CHECK_RESULT $?
    grep "DM-DDF 1.2" output.xml
    CHECK_RESULT $?
    wbxml2xml -l OTA -o output.xml input.wbxml
    CHECK_RESULT $?
    grep "SYSTEM" output.xml
    CHECK_RESULT $?
    wbxml2xml -l AIRSYNC -o output.xml input.wbxml
    CHECK_RESULT $?
    grep "AirSync" output.xml
    CHECK_RESULT $?
    wbxml2xml -l ACTIVESYNC -o output.xml input.wbxml
    CHECK_RESULT $?
    grep "ActiveSync" output.xml
    CHECK_RESULT $?
    wbxml2xml -l CONML -o output.xml input.wbxml
    CHECK_RESULT $?
    grep "ConML" output.xml
    CHECK_RESULT $?
    rm -rf output.xml
    wbxml2xml -c ASCII -o output.xml input.wbxml
    CHECK_RESULT $?
    test -f output.xml
    CHECK_RESULT $?
    diff -w input.xml output.xml
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    del_file=$(ls | grep -vE ".sh|input.xml")
    rm -rf ${del_file}
    LOG_INFO "End to restore the test environment."
}

main "$@"
