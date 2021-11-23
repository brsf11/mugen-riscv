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
#@Author    	:   Li, Meiting
#@Contact   	:   244349477@qq.com
#@Date      	:   2021-02-25
#@License   	:   Mulan PSL v2
#@Desc      	:   Pkgship auto start
#####################################

source ../../common_lib/pkgship_lib.sh

function run_test() {
    LOG_INFO "Start to run test."

    systemctl start pkgship.service
    logrotate_pnum=$(ps -ef | grep "uwsgi_logrotate" | wc -l)
    if [[ $logrotate_pnum == 2 ]]; then
        CHECK_RESULT 0
    else
        CHECK_RESULT 1 0 0 "The uwsgi_logrotate start failed by systemctl."
    fi

    systemctl stop pkgship.service 
    logrotate_pnum=$(ps -ef | grep "uwsgi_logrotate" | wc -l)
    if [[ $logrotate_pnum == 1 ]]; then
        CHECK_RESULT 0
    else
        CHECK_RESULT 1 0 0 "The uwsgi_logrotate doesn't stop by systemctl."
    fi

    su pkgshipuser -c "pkgshipd start >/dev/null"
    logrotate_pnum=$(ps -ef | grep "uwsgi_logrotate" | wc -l)
    if [[ $logrotate_pnum == 2 ]]; then
        CHECK_RESULT 0
    else
        CHECK_RESULT 1 0 0 "The uwsgi_logrotate start failed by pkgshipd."
    fi

    su pkgshipuser -c "pkgshipd stop >/dev/null"
    logrotate_pnum=$(ps -ef | grep "uwsgi_logrotate" | wc -l)
    if [[ $logrotate_pnum == 1 ]]; then
        CHECK_RESULT 0
    else
        CHECK_RESULT 1 0 0 "The uwsgi_logrotate doesn't stop by pkgshipd."
    fi
    
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    REVERT_ENV

    LOG_INFO "End to restore the test environment."
}

main $@

