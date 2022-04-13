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
# @Author    :   huyahui
# @Contact   :   huyahui8@163.com
# @Date      :   2022/04/22
# @License   :   Mulan PSL v2
# @Desc      :   Without providing any information, it completely prevents the opening of ICMP requests and ICMP requests
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    sudo systemctl start firewalld
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    for line in $(sudo firewall-cmd --get-icmptypes); do
        sudo firewall-cmd --permanent --set-target=DROP | grep success
        CHECK_RESULT $?
        sudo firewall-cmd --add-icmp-block-inversion | grep success
        CHECK_RESULT $?
        sudo firewall-cmd --add-icmp-block="${line}" | grep success
        CHECK_RESULT $?
        sudo firewall-cmd --runtime-to-permanent | grep success
        CHECK_RESULT $?
        sudo firewall-cmd --permanent --set-target=default | grep success
        CHECK_RESULT $?
        sudo firewall-cmd --remove-icmp-block-inversion | grep success
        CHECK_RESULT $?
        sudo firewall-cmd --remove-icmp-block="${line}" | grep success
        CHECK_RESULT $?
        sudo firewall-cmd --runtime-to-permanent | grep success
        CHECK_RESULT $?
    done

    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    sudo firewall-cmd --reload
    sudo systemctl start firewalld
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
