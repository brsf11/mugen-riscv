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
#@Date      	:   2021-02-20
#@License   	:   Mulan PSL v2
#@Desc      	:   Pkgship items normal function test
#####################################

source ../../common_lib/pkgship_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."

    cp -p ${SYS_CONF_PATH}/package.ini ${SYS_CONF_PATH}/package.ini.bak
    ACT_SERVICE

    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    MODIFY_INI init_conf_path "/etc/pkgship/package.ini"
    pkgship init | grep "The format of the yaml configuration file is wrong"
    CHECK_RESULT $? 0 0 "Check init while set file as package.ini unexpectly."

    MODIFY_INI init_conf_path "./empty.yaml"
    pkgship init | grep "content of the database initialization configuration file cannot be empty"
    CHECK_RESULT $? 0 0 "Check init while set file as empty.yaml unexpectly."

    MODIFY_INI init_conf_path "./over.yaml"
    pkgship init | grep "The initialized configuration file is incorrectly formatted and lacks the necessary dbname field"
    CHECK_RESULT $? 0 0 "Check init while set file as over.yaml unexpectly."

    MODIFY_INI init_conf_path "./duplicate.yaml"
    pkgship init | grep "There is a duplicate initialization configuration database name"
    CHECK_RESULT $? 0 0 "Check init while set file as duplicate.ini unexpectly."

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
