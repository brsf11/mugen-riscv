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
# @Desc      :   install Software Group
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environment preparation."
    OLD_LANG=$LANG
    export LANG=en_US.UTF-8
    yum group remove 'Network Servers' -y
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    yum group list | grep 'Network Servers'
    CHECK_RESULT $?
    yum group info 'Network Servers' | grep '   ' >yum_list
    yum group install 'Network Servers' -y
    CHECK_RESULT $?
    while read line; do
        rpm -qa "${line}"
        CHECK_RESULT $?
    done <yum_list
    yum group install 'Network Servers' -y
    CHECK_RESULT $?

    yum group remove 'Network Servers' -y
    CHECK_RESULT $?

    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    export LANG=${OLD_LANG}
    rm -rf yum_list
    LOG_INFO "Finish environment cleanup!"
}

main $@
