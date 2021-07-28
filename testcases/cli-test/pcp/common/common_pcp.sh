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
#@Author        :   zhujinlong
#@Contact       :   zhujinlong@163.com
#@Date          :   2020-10-23
#@License       :   Mulan PSL v2
#@Desc          :   Public class
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function deploy_env {
    DNF_INSTALL pcp
    systemctl enable pmcd
    systemctl start pmcd
    systemctl enable pmlogger
    systemctl start pmlogger
    SLEEP_WAIT 10
    host_name=$(hostname)
    pcp_version=$(rpm -qa pcp | awk -F '-' '{print $2}')
}
