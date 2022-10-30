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
# @Desc      :   Loop configuration rsyslog to filter different Facility logs
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
	LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL rsyslog
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    facility_list=("auth" "daemon" "security" "lpr" "mail" "syslog" "news" "user" "uucp" "local1")
    for facility in "${facility_list[@]}"; do
        echo "$facility.*   /var/log/test" >/etc/rsyslog.d/test.conf
        systemctl restart rsyslog
        CHECK_RESULT $?
        time=$(date +%s%N | cut -c 9-13)
        logger -t $facility -p $facility.info "test$facility$time"
        SLEEP_WAIT 3
        grep test$facility$time /var/log/test
        CHECK_RESULT $?
    done
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf /var/log/test /etc/rsyslog.d/test.conf
    systemctl restart rsyslog
    LOG_INFO "End to restore the test environment."
}
main "$@"
