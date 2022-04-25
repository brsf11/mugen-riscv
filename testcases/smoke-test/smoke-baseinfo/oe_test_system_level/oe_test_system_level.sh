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
# @Date      :   2022/04/19
# @License   :   Mulan PSL v2
# @Desc      :   Test system level
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    default_target="poweroff.target rescue.target multi-user.target graphical.target reboot.target"
    target=$(systemctl get-default)
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    case $target in
    poweroff.target)
        LOG_INFO "default target is poweroff "
        ;;
    rescue.target)
        LOG_INFO "default target is rescue"
        ;;
    multi-user.target)
        LOG_INFO "default target is multi-user"
        ;;
    graphical.target)
        LOG_INFO "default target is graphical"
        ;;
    reboot.target)
        LOG_INFO "default target is reboot"
        ;;
    esac
    for i in $default_target; do
        systemctl set-default $i && LOG_INFO "set-default $i success"
    done
    systemctl set-default $target
    CHECK_RESULT $? 0 0 "set-default execution failed"
    systemctl list-units --type target | egrep "multi-user.target|graphical.target"
    CHECK_RESULT $? 0 0 "list-units execution failed"
    systemctl isolate graphical.target
    CHECK_RESULT $? 0 0 "isolate execution failed"
    systemctl list-units --type target | grep graphical
    CHECK_RESULT $? 0 0 "list-units execution failed"
    systemctl isolate multi-user.target
    CHECK_RESULT $? 0 0 "isolate execution failed"
    systemctl list-units --type target | grep graphical
    CHECK_RESULT $? 1 0 "list-units execution failed"
    LOG_INFO "End to run test."
}

main "$@"
