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
    LOG_INFO "Start to prepare the database config."

    mv ${SYS_CONF_PATH}/package.ini ${SYS_CONF_PATH}/package.ini.bak
    cp -p ./package.ini ${SYS_CONF_PATH}/package.ini
    mv ${SYS_CONF_PATH}/conf.yaml ${SYS_CONF_PATH}/conf.yaml.bak
    cp -p ../../common_lib/openEuler.yaml ${SYS_CONF_PATH}/conf.yaml
    chown pkgshipuser:pkgshipuser ${SYS_CONF_PATH}/package.ini
    chown pkgshipuser:pkgshipuser ${SYS_CONF_PATH}/conf.yaml

    LOG_INFO "Finish to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    ACT_SERVICE
    pkgship init >/dev/null
    pkgship dbs | grep "openeuler-lts"
    CHECK_RESULT $? 0 0 "database init failed."

    pkgship init -filepath
    cat ${LOG_PATH}/pkgship/log_info.log | grep ERROR >/dev/null
    CHECK_RESULT $? 0 0 "The log doesn't show ERROR msg."

    ACT_SERVICE stop

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    rm -rf /home/pkgshipuser/uwsgi.log ${SYS_CONF_PATH}/conf.yaml
    mv ${SYS_CONF_PATH}/package.ini.bak ${SYS_CONF_PATH}/package.ini
    mv ${SYS_CONF_PATH}/conf.yaml.bak ${SYS_CONF_PATH}/conf.yaml
    REVERT_ENV
    
    LOG_INFO "End to restore the test environment."
}

main $@
