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
# @Author    :   doraemon2020
# @Contact   :   xcl_job@163.com
# @Date      :   2020/10/30
# @License   :   Mulan PSL v2
# @Desc      :   command func
# ############################################
source "${OET_PATH}"/libs/locallibs/common_lib.sh
function RANDOM_IP() {
    while true; do
        random_ip=${NODE1_IPV4[0]%.*}.$(shuf -e $(seq 1 254) | head -n 1)
        ping -c 3 "${random_ip}" &>/dev/nul || {
            printf "%s" "$random_ip"
            break
        }
    done
}
