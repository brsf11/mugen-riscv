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
#@Date      	:   2020-08-25
#@License   	:   Mulan PSL v2
#@Desc      	:   Pkgship items normal function test
#####################################

source ../../common_lib/pkgship_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."

    mv ${SYS_CONF_PATH}/conf.yaml ${SYS_CONF_PATH}/conf.yaml.bak
    ACT_SERVICE
   
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    cp -p ./error1.yaml ${SYS_CONF_PATH}/conf.yaml
    chown pkgshipuser:pkgshipuser ${SYS_CONF_PATH}/conf.yaml
    pkgship init 2>&1 | grep "The initialized configuration file is incorrectly formatted and lacks the necessary dbname field" >/dev/null
    CHECK_RESULT $? 0 0 "Check init msg failed when set error1.yaml."

    # Set conf.yaml with some error dbs
    for i in $(seq 2 5); do
        cp -p ./"error"$i".yaml" ${SYS_CONF_PATH}/conf.yaml
        chown pkgshipuser:pkgshipuser ${SYS_CONF_PATH}/conf.yaml
        pkgship init 2>&1 | grep "The format of the yaml configuration file is wrong please check and try again" >/dev/null
        CHECK_RESULT $? 0 0 "Check init msg failed when set error$i.yaml."
    done

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
