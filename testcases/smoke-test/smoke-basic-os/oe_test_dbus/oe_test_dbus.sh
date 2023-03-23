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
# @Date      :   2022/06/08
# @License   :   Mulan PSL v2
# @Desc      :   Test the basic functions of dbus
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test() {
    LOG_INFO "Start to run test."
    systemctl status dbus | grep running
    CHECK_RESULT $? 0 0 "Failed to run dbus service"
    kill -9 $(pgrep dbus)
    CHECK_RESULT $? 0 0 "Failed to kill the dbus process"
    ps -ef | grep dbus
    CHECK_RESULT $? 0 0 "Failed to exist dbus service"
    dbus-send --system --print-reply --dest=org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus.ListActivatableNames | grep array
    CHECK_RESULT $? 0 0 "Failed to execute dbus-send"
    systemctl status dbus | grep running
    CHECK_RESULT $? 0 0 "Failed to check dbus service"
    LOG_INFO "End to run test."
}

main "$@"
