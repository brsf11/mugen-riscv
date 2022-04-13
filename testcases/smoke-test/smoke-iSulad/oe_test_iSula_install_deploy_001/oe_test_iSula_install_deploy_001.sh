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
# @Author    :   duanxuemin
# @Contact   :   duanxuemin@163.com
# @Date      :   2020-06-09
# @License   :   Mulan PSL v2
# @Desc      :   install and deploy iSula container
# ############################################

source ../common/prepare_isulad.sh
function pre_test() {
    LOG_INFO "Start environment preparation."
    DNF_INSTALL iSulad
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    systemctl status isulad | grep running
    CHECK_RESULT $?

    sed -i "/registry-mirrors/a\"https:\/\/${Image_address}\"" /etc/isulad/daemon.json
    systemctl restart isulad
    CHECK_RESULT $?

    systemctl status isulad | grep running
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf /etc/isulad/daemon.json
    sed -i "/${Image_address}/d" /etc/isulad/daemon.json
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup."
}

main $@
