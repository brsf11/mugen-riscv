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
# @Author    :   wangshan
# @Contact   :   wangshan@163.com
# @Date      :   2020-08-03
# @License   :   Mulan PSL v2
# @Desc      :   Support filter discard
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
	LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL rsyslog
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    echo "local3.*    ~" >/etc/rsyslog.d/test.conf
    systemctl restart rsyslog
    CHECK_RESULT $?
    logger -t local3 -p local3.error "local3test"
    CHECK_RESULT $?
    SLEEP_WAIT 5
    CHECK_RESULT "$(grep "local3test" /var/log/test)" 1
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf /etc/rsyslog.d/test.conf
    systemctl restart rsyslog
    LOG_INFO "End to restore the test environment."
}
main "$@"
