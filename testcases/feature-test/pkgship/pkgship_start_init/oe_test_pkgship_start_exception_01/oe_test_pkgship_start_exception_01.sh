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

    MODIFY_INI init_conf_path "/home/conf.yaml"
    ACT_SERVICE start >/dev/null
    pkgship init | grep "system initialization configuration file does not exist"
    CHECK_RESULT $? 0 0 "The error msg is false or not exist when init_conf_path doesn't exist."
    
    LOG_INFO "Start to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    ACT_SERVICE stop >/dev/null

    rm -f ${SYS_CONF_PATH}/package.ini
    mv ${SYS_CONF_PATH}/package.ini.bak ${SYS_CONF_PATH}/package.ini
    REVERT_ENV
    
    LOG_INFO "End to restore the test environment."
}

main $@

