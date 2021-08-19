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

    cp -p ${SYS_CONF_PATH}/conf.yaml ${SYS_CONF_PATH}/conf.bak
    cp -p ../../common_lib/openEuler.yaml ${SYS_CONF_PATH}/conf.yaml
    chown pkgshipuser:pkgshipuser ${SYS_CONF_PATH}/conf.yaml
    ACT_SERVICE

    para=('https://hhhhhh' 'file:///etc/pkgship/repo/openEuler-20.09/src' 'https://repo.openeuler.org/openEuler-20.03-LTS/source/')

    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    for i in $(seq 0 $((${#para[@]} - 1))); do
        MODIFY_CONF bin_db_file ${para[$i]}
        pkgship init 2>&1 | grep "initialize failed" >/dev/null
        CHECK_RESULT $? 0 0 "Check init msg failed when set bin_db_file=${para[$i]}"
    done
    MODIFY_CONF bin_db_file '/etc/pkgship/package.ini'
    pkgship init 2>&1 | grep "The 'bin_db_file' configuration item in the openeuler-lts database has an incorrect value" >/dev/null
    CHECK_RESULT $? 0 0 "Check init msg failed when set bin_db_file=/etc/pkgship/package.ini"

    MODIFY_CONF bin_db_file ' '
    pkgship init 2>&1 | grep "expected string or bytes-like object" >/dev/null
    CHECK_RESULT $? 0 0 "Check init msg failed when set bin_db_file empty"

    sed -i "s#bin_db_file#BIN_DB_FILE#g" ${SYS_CONF_PATH}/conf.yaml
    pkgship init 2>&1 | grep "The 'bin_db_file' configuration item in the openeuler-lts database has an incorrect value ." >/dev/null
    CHECK_RESULT $? 0 0 "Check init msg failed when set bin_db_file as BIN_DB_FILE"

    # Delete bin_db_file
    sed -i '/bin_db_file/d' ${SYS_CONF_PATH}/conf.yaml
    pkgship init 2>&1 | grep "The 'bin_db_file' configuration item in the openeuler-lts database has an incorrect value" >/dev/null
    CHECK_RESULT $? 0 0 "Check init msg failed when delete bin_db_file"

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
