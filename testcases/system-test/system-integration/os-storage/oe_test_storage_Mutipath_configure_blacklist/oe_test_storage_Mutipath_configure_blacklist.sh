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
# @Desc      :   Blacklist configuration
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start environment preparation."
    DNF_INSTALL multipath-tools
    mpathconf --enable --with_multipathd y
    line_num=$(grep -rn wwid ../common/multipath_006.conf | awk -F : '{print$1}')
    mv /etc/multipath.conf /etc/multipath.conf.bak
    cp ../common/multipath_006_1.conf /etc/multipath.conf
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase."
    systemctl reload multipathd.service
    CHECK_RESULT $?
    systemctl status multipathd | grep "invalid key"
    CHECK_RESULT $? 1

    rm -rf /etc/multipath.conf
    CHECK_RESULT $?
    cp ../common/multipath_006_2.conf /etc/multipath.conf
    CHECK_RESULT $?
    sed -i "${line_num}d" /etc/multipath.conf
    CHECK_RESULT $?
    sed -i "${line_num}i\\tdevnode \"^sd[a-z]\"" /etc/multipath.conf
    CHECK_RESULT $?
    systemctl reload multipathd.service
    CHECK_RESULT $?
    systemctl status multipathd | grep "invalid key"
    CHECK_RESULT $? 1

    rm -rf /etc/multipath.conf
    CHECK_RESULT $?
    cp ../common/multipath_006_1.conf /etc/multipath.conf
    CHECK_RESULT $?
    sed -i "${line_num}d" /etc/multipath.conf
    CHECK_RESULT $?
    sed -i "${line_num}i\\tdevnode \"^(ram|raw|loop|fd|md|dm-|sr|scd|st)[0-9]*\"" /etc/multipath.conf
    CHECK_RESULT $?
    sed -i "${line_num}a\\tdevnode \"^(td|ha)d[a-z]\"" /etc/multipath.conf
    CHECK_RESULT $?
    systemctl reload multipathd.service
    CHECK_RESULT $?
    systemctl status multipathd | grep "invalid key"
    CHECK_RESULT $? 1

    rm -rf /etc/multipath.conf
    CHECK_RESULT $?
    cp ../common/multipath_006_2.conf /etc/multipath.conf
    CHECK_RESULT $?
    systemctl reload multipathd.service
    CHECK_RESULT $?
    systemctl status multipathd | grep "invalid key"
    CHECK_RESULT $? 1
    LOG_INFO "End of testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf /etc/multipath*.conf
    mv /etc/multipath.conf.bak /etc/multipath.conf
    systemctl reload multipathd.service
    multipath -F
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup."
}

main $@
