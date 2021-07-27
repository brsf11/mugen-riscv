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
    cp -p ${SYS_CONF_PATH}/conf.yaml ${SYS_CONF_PATH}/conf.bak
    cp -p ../../common_lib/openEuler.yaml ${SYS_CONF_PATH}/conf.yaml
    chown pkgshipuser:pkgshipuser ${SYS_CONF_PATH}/conf.yaml
    
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    MODIFY_CONF src_db_file ''
    pkgship init 2>&1 | grep "expected string or bytes-like object" >/dev/null
    CHECK_RESULT $? 0 0 "Init unexpectly or mesg error when set src_db_file=''."

    para=('file:///etc/pkgship/repo/openEuler_20.09/bin' 'https://sssssss' 'https://mirrors.huaweicloud.com/openeuler/openEuler-20.03-LTS/everything/')
    for i in $(seq 0 $((${#para[@]} - 1))); do
        MODIFY_CONF src_db_file ${para[$i]}
        pkgship init 2>&1 | grep "initialize failed" >/dev/null
        CHECK_RESULT $? 0 0 "Init unexpectly or mesg error when set src_db_file=${para[$i]}."
    done

    MODIFY_CONF src_db_file ${SYS_CONF_PATH}/package.ini
    pkgship init 2>&1 | grep "src_db_file" | grep "has an incorrect value" >/dev/null
    CHECK_RESULT $? 0 0 "Init unexpectly or mesg error when set src_db_file=${SYS_CONF_PATH}/package.ini."

    # Set src_db_file conf as upper
    sed -i "s#src_db_file#SRC_DB_FILE#g" ${SYS_CONF_PATH}/conf.yaml
    pkgship init 2>&1 | grep "src_db_file" | grep "has an incorrect value" >/dev/null
    CHECK_RESULT $? 0 0 "Init unexpectly or mesg error when set SRC_DB_FILE."

    # Delete src_db_file
    sed -i '/src_db_file/d' ${SYS_CONF_PATH}/conf.yaml
    pkgship init 2>&1 | grep "src_db_file" | grep "has an incorrect value" >/dev/null
    CHECK_RESULT $? 0 0 "Init unexpectly or mesg error when delete src_db_file."
    
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
