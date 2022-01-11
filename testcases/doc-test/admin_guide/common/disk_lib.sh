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
# @Author    :   Classicriver
# @Contact   :   classicriver_jia@foxmail.com
# @Date      :   2020.4.27
# @License   :   Mulan PSL v2
# @Desc      :   disk select
# ############################################

function check_free_disk() {
    num_disk=$1
    disk_list=($(lsblk | awk '{print$1" "$6}' | grep disk | awk '{print$1}'))
    for disk in ${disk_list[@]}; do
        lsblk | awk '{print$1}' | grep -w ${disk} -A 1 | grep -E "└─|├─" >/dev/nul || lsblk | awk '{print$1" "$6" "$7}' | grep / | awk '{print$1" "$2}' | grep -w ${disk} | awk '{print$2}' | grep disk >/dev/nul
        if [ $? -eq 0 ]; then
            disk_list=(${disk_list[@]/${disk}/})
        fi
    done
    [ ${#disk_list[@]} -ge ${num_disk} ] || exit 1
    shuf -e ${disk_list[@]} | head -n ${num_disk}
}
