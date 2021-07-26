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
# @Desc      :   The usage of commands in qt5-qttools package
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL qt5-qttools
    qt5_version=$(rpm -qa qt5-qttools | awk -F '-' '{print $3}')
    mkdir -p ~/Documents/qt5dir
    test -d ~/Documents/qt5dir
    touch ~/Documents/qtfile
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    qtpaths -h | grep -E "qtpaths|help"
    CHECK_RESULT $?
    qtpaths -v | grep "qtpaths"
    CHECK_RESULT $?
    qtpaths --types Documents | grep "Location"
    CHECK_RESULT $?
    qtpaths --paths DocumentsLocation Documents | grep "/root/Documents"
    CHECK_RESULT $?
    qtpaths --writable-path DocumentsLocation Documents | grep "/root/Documents"
    CHECK_RESULT $?
    qtpaths --locate-dir DocumentsLocation qt5dir | grep "/root/Documents/qt5dir"
    CHECK_RESULT $?
    qtpaths --locate-dirs DocumentsLocation qt5dir | grep "/root/Documents/qt5dir"
    CHECK_RESULT $?
    qtpaths --locate-file DocumentsLocation qtfile | grep "/root/Documents/qtfile"
    CHECK_RESULT $?
    qtpaths --locate-files DocumentsLocation qtfile | grep "/root/Documents/qtfile"
    CHECK_RESULT $?
    qtpaths --find-exe mkdir | grep "/usr/bin/mkdir"
    CHECK_RESULT $?
    qtpaths --display DocumentsLocation qtfile | grep "Documents"
    CHECK_RESULT $?
    qtpaths --qt-version | grep "${qt5_version}"
    CHECK_RESULT $?
    qtpaths --install-prefix | grep "/usr"
    CHECK_RESULT $?
    qtpaths --binaries-dir | grep "/usr/lib64/qt5/bin"
    CHECK_RESULT $?
    qtpaths --plugin-dir | grep "/usr/lib64/qt5/plugins"
    CHECK_RESULT $?
    qtpaths --testmode --paths DocumentsLocation Documents | grep "/root/Documents"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf ~/Documents
    LOG_INFO "End to restore the test environment."
}

main "$@"
