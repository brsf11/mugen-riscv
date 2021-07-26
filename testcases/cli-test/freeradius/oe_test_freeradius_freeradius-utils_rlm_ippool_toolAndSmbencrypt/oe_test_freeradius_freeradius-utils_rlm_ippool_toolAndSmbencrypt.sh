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
#@Author        :   wangjingfeng
#@Contact       :   1136232498@qq.com
#@Date          :   2020/12/24
#@License       :   Mulan PSL v2
#@Desc          :   freeradius-utils command parameter automation use case
####################################
source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."

    DNF_INSTALL "freeradius freeradius-utils"
    ln -s /etc/raddb/mods-available/ippool /etc/raddb/mods-enabled/ippool
    sed -i '/main_pool/a main_pool' /etc/raddb/sites-enabled/default
    systemctl start radiusd
    SLEEP_WAIT 1

    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    rlm_ippool_tool -n /etc/raddb/db.ippool /etc/raddb/db.ipindex 192.0.2.131 127.0.0.1 0 | grep Allocated
    CHECK_RESULT $? 0 0 "rlm_ippool_tool -n execution failed."
    rlm_ippool_tool -a /etc/raddb/db.ippool /etc/raddb/db.ipindex | grep "192.0.2.131"
    CHECK_RESULT $? 0 0 "rlm_ippool_tool -a execution failed."
    [ "$(rlm_ippool_tool -c /etc/raddb/db.ippool /etc/raddb/db.ipindex)" -eq 1 ]
    CHECK_RESULT $? 0 0 "rlm_ippool_tool -c execution failed."
    rlm_ippool_tool -r /etc/raddb/db.ippool /etc/raddb/db.ipindex
    [ "$(rlm_ippool_tool -c /etc/raddb/db.ippool /etc/raddb/db.ipindex)" -eq 0 ]
    CHECK_RESULT $? 0 0 "rlm_ippool_tool -r execution failed."
    rlm_ippool_tool -v /etc/raddb/db.ippool /etc/raddb/db.ipindex | grep "KEY"
    CHECK_RESULT $? 0 0 "rlm_ippool_tool -v execution failed."
    rlm_ippool_tool -vo /etc/raddb/db.ippool /etc/raddb/db.ipindex | grep "NAS"
    CHECK_RESULT $? 0 0 "rlm_ippool_tool -o execution failed."
    rlm_ippool_tool -u /etc/raddb/db.ippool /etc/raddb/db_new.ippool
    [ -e /etc/raddb/db_new.ippool ]
    CHECK_RESULT $? 0 0 "rlm_ippool_tool -u execution failed."
    systemctl stop radiusd
    smbencrypt test 2>&1 | grep "Hash"
    CHECK_RESULT $? 0 0 "smbencrypt execution failed."

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    DNF_REMOVE
    rm -rf /etc/raddb
    rm -rf /var/log/radius

    LOG_INFO "End to restore the test environment."
}

main "$@"
