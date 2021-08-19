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
#@Contact   	:   244349477@qq.com
#@Date      	:   2021-02-20
#@License   	:   Mulan PSL v2
#@Desc      	:   Pkgship items normal function test
#####################################

source ../../common_lib/pkgship_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."

    cp -p ${SYS_CONF_PATH}/conf.yaml ${SYS_CONF_PATH}/conf.bak
    cp -p ../../common_lib/openEuler.yaml ${SYS_CONF_PATH}/conf.yaml 
    chown pkgshipuser:pkgshipuser ${SYS_CONF_PATH}/conf.yaml
    ACT_SERVICE
    
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    # Set priority as 101
    para=('101' '-1')
    for i in $(seq 0 $((${#para[@]} - 1))); do
        MODIFY_CONF priority ${para[$i]}
        pkgship init 2>&1 | grep "priority range of the database can only be between 1 and 100" >/dev/null
        CHECK_RESULT $? 0 0 "Check init msg failed when set priority = ${para[$i]}."
    done

    MODIFY_CONF priority ' '
    pkgship init 2>&1 | grep "The database priority of openeuler-lts does not exist" >/dev/null
    CHECK_RESULT $? 0 0 "Check init msg failed when set priority =''."

    MODIFY_CONF priority 'hello'
    pkgship init 2>&1 | grep "priority of database openeuler-lts must be a integer number" >/dev/null
    CHECK_RESULT $? 0 0 "Check init msg failed when set priority ='hello'."

    MODIFY_CONF priority '1.1'
    pkgship init 2>&1 | grep "priority of database openeuler-lts must be a integer number" >/dev/null
    CHECK_RESULT $? 0 0 "Check init msg failed when set priority ='1.1'."

    # Set PRIORITY
    sed -i "s#priority#PRIORITY#g" ${SYS_CONF_PATH}/conf.yaml
    pkgship init 2>&1 | grep "The database priority of openeuler-lts does not exist" >/dev/null
    CHECK_RESULT $? 0 0 "Check init msg failed when set priority to be upper."

    # Delete priority
    sed -i '/PRIORITY/d' ${SYS_CONF_PATH}/conf.yaml
    pkgship init 2>&1 | grep "The database priority of openeuler-lts does not exist" >/dev/null
    CHECK_RESULT $? 0 0 "Check init msg failed when delete priority."

    ACT_SERVICE STOP
    
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
 
    rm -f ${SYS_CONF_PATH}/conf.yaml
    mv ${SYS_CONF_PATH}/conf.bak ${SYS_CONF_PATH}/conf.yaml
    REVERT_ENV
    
    LOG_INFO "End to restore the test environment."
}

main $@
