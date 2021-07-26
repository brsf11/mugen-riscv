#!/usr/bin/bash

# Copyright (c) 2021 Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   xuchunlin
# @Contact   :   xcl_job@163.com
# @Date      :   2020-04-09
# @License   :   Mulan PSL v2
# @Desc      :   Locale setting test
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function run_test() {
    LOG_INFO "Start testing..."
    localectl list-locales | grep "UTF-8"
    CHECK_RESULT $?
    localectl status | grep -i 'system locale'
    CHECK_RESULT $?
    now_LANG=$(localectl status | grep -i 'system locale' | awk -F ': ' '{print $2}')
    set_LANG=$(localectl list-locales | grep -v "${now_LANG}" | head -1)
    localectl set-locale LANG="${set_LANG}"
    localectl status | grep -i 'system locale' | awk -F "=" '{print$2}' | grep "${set_LANG}"
    CHECK_RESULT $?
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    localectl set-locale "${now_LANG}"
    LOG_INFO "Finish environment cleanup!"
}

main $@
