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
#@Author    	:   yanglijin/limeiting
#@Contact   	:   1050472997@qq.com/244349477@qq.com
#@Date      	:   2021-02-19
#@License   	:   Mulan PSL v2
#@Desc      	:   Pkgship items normal function test
#####################################

source ../../common_lib/pkgship_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the database config."

    cp -p ${SYS_CONF_PATH}/package.ini ${SYS_CONF_PATH}/package.ini.bak
    ACT_SERVICE stop
    
    LOG_INFO "End to prepare the database config."
}

function run_test() {
    LOG_INFO "Start to run test."

    MODIFY_INI query_port ""
    systemctl start pkgship 2>&1 | grep "Job for pkgship.service failed because the control process exited with error code." &&
    journalctl -u pkgship -n 20 | grep "\[ERROR\] The value of below config names is None in: /etc/pkgship/package.ini, Please check these parameters:"
    ACT_SERVICE stop
    CHECK_RESULT $? 0 0 "Check start by systemctl failed when set query_port=''."
    su pkgshipuser -c "pkgshipd start 2>&1 | grep '\[ERROR\] The value of below config names is None in: /etc/pkgship/package.ini, Please check these parameters:
    query_port'"
    CHECK_RESULT $? 0 0 "Check start by pkgshipd failed when set query_port=''."

    sed -i '/query_port/d' ${SYS_CONF_PATH}/package.ini
    systemctl start pkgship 2>&1 | grep "Job for pkgship.service failed because the control process exited with error code." &&
    journalctl -u pkgship -n 20 | grep "\[ERROR\] CAN NOT find config name 'query_port' or 'query_ip_addr' in: /etc/pkgship/package.ini"
    ACT_SERVICE stop
    CHECK_RESULT $? 0 0 "Check start by systemctl failed when delete set query_port."
    su pkgshipuser -c "pkgshipd start 2>&1 | grep \"\[ERROR\] CAN NOT find config name 'query_port' or 'query_ip_addr' in: /etc/pkgship/package.ini,
    Please check the file.\""
    CHECK_RESULT $? 0 0 "Check start by pkgshipd failed when delete set query_port."
    
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    rm -f ${SYS_CONF_PATH}/package.ini
    mv ${SYS_CONF_PATH}/package.ini.bak ${SYS_CONF_PATH}/package.ini
    REVERT_ENV
    
    LOG_INFO "End to restore the test environment."
}

main $@

