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
#@Date      	:   2021-02-20
#@License   	:   Mulan PSL v2
#@Desc      	:   Pkgship items normal function test
#####################################

source  ../../common_lib/pkgship_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."

    cp -p ${SYS_CONF_PATH}/conf.yaml ${SYS_CONF_PATH}/conf.yaml.bak
    cp -p  ../../common_lib/openEuler.yaml ${SYS_CONF_PATH}/conf.yaml 
    chown pkgshipuser:pkgshipuser ${SYS_CONF_PATH}/conf.yaml
    ACT_SERVICE

    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    mv ${SYS_CONF_PATH}/repo/openEuler-20.09/bin/repodata/openEuler-20.09-bin-filelists.sqlite.bz2 ${SYS_CONF_PATH}/repo/openEuler-20.09/bin/repodata/openEuler-20.09-bin-filelists.sqlite.bz2.bak
    CHECK_RESULT $? 0 0 "Move bin filelist failed."
    pkgship init | grep "initialize failed"
    CHECK_RESULT $? 0 0 "Initialize pkgship unexpectly."

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
 
    rm -f ${SYS_CONF_PATH}/conf.yaml
    mv ${SYS_CONF_PATH}/conf.yaml.bak ${SYS_CONF_PATH}/conf.yaml
    mv ${SYS_CONF_PATH}/repo/openEuler-20.09/bin/repodata/openEuler-20.09-bin-filelists.sqlite.bz2.bak ${SYS_CONF_PATH}/repo/openEuler-20.09/bin/repodata/openEuler-20.09-bin-filelists.sqlite.bz2   
    
    REVERT_ENV
    
    LOG_INFO "End to restore the test environment."
}

main $@
