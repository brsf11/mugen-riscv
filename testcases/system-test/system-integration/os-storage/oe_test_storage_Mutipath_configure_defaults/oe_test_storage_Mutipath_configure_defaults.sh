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
# @Date      :   2020-04-27
# @License   :   Mulan PSL v2
# @Desc      :   Configure the defaults section
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start environment preparation."
    local_lang=$LANG
    export LANG=en_US.utf-8
    DNF_INSTALL multipath-tools
    mpathconf --enable --with_multipathd y
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase."
    mv /etc/multipath.conf /etc/multipath.conf.bak
    CHECK_RESULT $?
    cp ../common/multipath_007.conf /etc/multipath.conf
    CHECK_RESULT $?
    systemctl reload multipathd.service
    CHECK_RESULT $?
    systemctl status multipathd | grep "invalid key"
    CHECK_RESULT $? 1
    LOG_INFO "End of testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf /etc/multipath.conf
    mv /etc/multipath.conf.bak /etc/multipath.conf
    systemctl reload multipathd.service
    multipath -F
    DNF_REMOVE
    export LANG=${local_lang}
    LOG_INFO "Finish environment cleanup."
}

main $@
