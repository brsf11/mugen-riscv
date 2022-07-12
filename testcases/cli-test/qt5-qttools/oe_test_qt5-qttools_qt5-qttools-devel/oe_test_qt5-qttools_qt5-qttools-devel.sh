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
# @Date      :   2020/10/20
# @License   :   Mulan PSL v2
# @Desc      :   The usage of commands in qt5-qttools-devel binary package
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "qt5-qttools qt5-qttools-devel"
    qt5_version=$(rpm -qa qt5-qttools | awk -F '-' '{print $3}')
    example_so=/usr/lib64/qt5/plugins/printsupport/libcupsprintersupport.so
    cp ../assistant.qhp ./
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    qcollectiongenerator-qt5 -o help.qhc help.qhcp | grep "Documentation successfully"
    CHECK_RESULT $?
    grep -a "Documentation" help.qhc
    CHECK_RESULT $?
    qcollectiongenerator-qt5 -v | grep -E "Collection Generator|${qt5_version}"
    CHECK_RESULT $?
    qtplugininfo-qt5 --full-json $example_so | grep "QCupsPrinterSupportPlugin"
    CHECK_RESULT $?
    qtplugininfo-qt5 -f indented $example_so | grep "cupsprintersupport"
    CHECK_RESULT $?
    qtplugininfo-qt5 -p classname $example_so | grep "class QCupsPrinterSupportPlugin"
    CHECK_RESULT $?
    qtplugininfo-qt5 -h | grep -E "qtplugininfo-qt5|help"
    CHECK_RESULT $?
    qtplugininfo-qt5 -v | grep "qplugininfo ${qt5_version}"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf ./actul_result* example_so ./assistant* help.qhc
    LOG_INFO "End to restore the test environment."
}

main "$@"


