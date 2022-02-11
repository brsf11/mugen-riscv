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
# @Author    :   Classicriver_jia
# @Contact   :   classicriver_jia@foxmail.com
# @Date      :   2020.4.27
# @License   :   Mulan PSL v2
# @Desc      :   KDUMP configuration
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function run_test() {
    LOG_INFO "Start executing testcase."
    rpm -q kexec-tools
    CHECK_RESULT $?
    grub2-mkconfig -o /boot/grub2/grub.cfg
    CHECK_RESULT $?
    systemctl enable kdump.service
    systemctl start kdump.service
    systemctl status kdump.service | grep active
    CHECK_RESULT $?
    systemctl stop kdump.serviceactive
    systemctl disable kdump.service
    systemctl is-enabled kdump.service | grep disable
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    systemctl enable kdump.service
    systemctl start kdump.service
    LOG_INFO "Finish environment cleanup."
}

main $@
