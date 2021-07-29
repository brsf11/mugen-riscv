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

    ACT_SERVICE

    LOG_INFO "End to prepare the test environment."
}

function pre_test() {
    LOG_INFO "Start to prepare the test environment."

    mv ${SYS_CONF_PATH}/conf.yaml ${SYS_CONF_PATH}/conf.yaml.bak
    cp -p ../../common_lib/openEuler.yaml ${SYS_CONF_PATH}/conf.yaml
    chown pkgshipuser:pkgshipuser ${SYS_CONF_PATH}/conf.yaml
     
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    # Set dbname as empty
    MODIFY_CONF dbname ""
    pkgship init | grep "format of the initial database configuration file is incorrect" >/dev/null
    CHECK_RESULT $? 0 0 "Init while dbname is empty unexpectly."

    # Set dbname is too long
    MODIFY_CONF dbname "yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy"
    pkgship init | grep "format of the initial database configuration file is incorrect" >/dev/null
    CHECK_RESULT $? 0 0 "Init while dbname is too long unexpectly."

    # Set dbname is lower&upper
    MODIFY_CONF dbname "OPENEULER"
    pkgship init | grep "format of the initial database configuration file is incorrect" >/dev/null
    CHECK_RESULT $? 0 0 "Init while dbname is lower&upper unexpectly."

    # Delete dbname
    sed -i '/dbname/d' ${SYS_CONF_PATH}/conf.yaml
    pkgship init | grep "format of the initial database configuration file is incorrect" >/dev/null
    CHECK_RESULT $? 0 0 "Init while dbname is deleted unexpectly."

    cp -p ../../common_lib/openEuler.yaml ${SYS_CONF_PATH}/conf.yaml

    # Set dbname to lower&upper
    sed -i "s#dbname#dbName#g" ${SYS_CONF_PATH}/conf.yaml
    pkgship init | grep "The initialized configuration file is incorrectly formatted and lacks the necessary dbname field" >/dev/null
    CHECK_RESULT $? 0 0 "Init while dbname is lower&upper unexpectly."
    
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    rm -f ${SYS_CONF_PATH}/conf.yaml
    mv ${SYS_CONF_PATH}/conf.yaml.bak ${SYS_CONF_PATH}/conf.yaml
    REVERT_ENV
    
    LOG_INFO "End to restore the test environment."
}

main $@
