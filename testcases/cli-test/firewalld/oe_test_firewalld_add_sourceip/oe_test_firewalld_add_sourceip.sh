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
# @Desc      :   Configure all traffic from specific sources in the specified area as allow and remove sources
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    sudo systemctl start firewalld
    zone_name=$(sudo firewall-cmd --get-zones | awk '{print $1}')
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."

    sudo firewall-cmd --zone="${zone_name}" --add-source=9.82.227.222 | grep success
    CHECK_RESULT $?
    sudo firewall-cmd --zone="${zone_name}" --remove-source=9.82.227.222 | grep success
    CHECK_RESULT $?
    LOG_INFO "Finish testcase execution."
}

main "$@"
