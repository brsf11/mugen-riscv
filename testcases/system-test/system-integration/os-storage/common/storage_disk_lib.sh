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
# @Author    :   Classicriver_jia
# @Contact   :   classicriver_jia@foxmail.com
# @Date      :   2020-04-10
# @License   :   Mulan PSL v2
# @Desc      :   Enable periodic block discard
# ############################################
source ${OET_PATH}/libs/locallibs/common_lib.sh
function check_free_disk() {
    num_disk=$1
    disks=$(python3 ${OET_PATH}/libs/locallibs/get_test_device.py --node 1 --device disk)
    disk_list=($disks)
    [ ${#disk_list[@]} -ge ${num_disk} ] || exit 1
    shuf -e ${disk_list[@]} | head -n ${num_disk}
}
