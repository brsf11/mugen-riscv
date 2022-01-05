#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more detaitest -f.

# #############################################
# @Author    :   huangrong
# @Contact   :   1820463064@qq.com
# @Date      :   2020/10/23
# @License   :   Mulan PSL v2
# @Desc      :   Test ipmievd.service restart
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    modprobe ipmi_watchdog
    modprobe ipmi_poweroff
    modprobe ipmi_devintf
    modprobe ipmi_si 
    modprobe ipmi_msghandler
    DNF_INSTALL ipmitool
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    test_execution ipmievd.service
    test_reload ipmievd.service
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    modprobe -r ipmi_watchdog
    modprobe -r ipmi_poweroff
    modprobe -r ipmi_devintf
    modprobe -r ipmi_si 
    modprobe -r ipmi_msghandler
    systemctl stop ipmievd.service
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
