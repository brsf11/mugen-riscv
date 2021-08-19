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
#@Author    	:   guochenyang
#@Contact   	:   377012421@qq.com
#@Date      	:   2021-08-04 09:30:43
#@License   	:   Mulan PSL v2
#@Desc      	:   verification kf5-kconfig-core‘s command
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "kf5-kconfig-core"
    LOG_INFO "End to prepare the test environment."
}
function run_test() {
    LOG_INFO "Start to run test."
    kwriteconfig5 | grep -E "Usage:|Options:"
    CHECK_RESULT $?
    kreadconfig5 | grep -E "Usage:|Options:"
    CHECK_RESULT $?
    test -f /usr/share/kde-settings/kde-profile/default/share/config/kglobalshortcutsrc
    CHECK_RESULT $?
    kreadconfig5 --file /usr/share/kde-settings/kde-profile/default/share/config/kglobalshortcutsrc | grep -E "Usage:|Options:"
    CHECK_RESULT $?
    kreadconfig5 --file /usr/share/kde-settings/kde-profile/default/share/config/kglobalshortcutsrc --group ksmserver | grep -E "Usage:|Options:"
    CHECK_RESULT $?
    grep -E "Lock Session|ksmserver" /usr/share/kde-settings/kde-profile/default/share/config/kglobalshortcutsrc
    CHECK_RESULT $? 1 0
    kwriteconfig5 --file /usr/share/kde-settings/kde-profile/default/share/config/kglobalshortcutsrc --group ksmserver --key "Lock Session" "abc"
    CHECK_RESULT $?
    kreadconfig5 --file /usr/share/kde-settings/kde-profile/default/share/config/kglobalshortcutsrc --group ksmserver --key "Lock Session" | grep "abc"
    CHECK_RESULT $?
    kwriteconfig5 --file /usr/share/kde-settings/kde-profile/default/share/config/kglobalshortcutsrc --group ksmserver --key "Lock Session" "Meta+L\tCtrl+Alt+L\tScreensaver,Meta+L\tScreensaver,Lock Session"
    CHECK_RESULT $?
    kreadconfig5 --file /usr/share/kde-settings/kde-profile/default/share/config/kglobalshortcutsrc --group ksmserver --key "Lock Session" | grep "Meta"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}
main "$@"
