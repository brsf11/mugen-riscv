#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   duanxuemin
# @Contact   :   duanxuemin@163.com
# @Date      :   2020-06-09
# @License   :   Mulan PSL v2
# @Desc      :   attach and rename containers
# ############################################

source ../common/prepare_isulad.sh
function pre_test() {
    LOG_INFO "Start environment preparation."
    pre_isulad_env
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    run_isulad_container
    expect -c "
    log_file testlog
    spawn isula attach ${containerId}
    sleep 1
    expect {
    \"\" {send \"\r\";
     expect \"*\[#|/\]*\" {send \"exit\r\"}
}
}
expect eof
"
    grep -iE 'error|fail' testlog
    CHECK_RESULT $? 1
    
    if [ $Images_name == busybox ];then
        CHECK_RESULT $(grep -c "exit" testlog) 1
    else
        CHECK_RESULT $(grep -c "exit" testlog) 2
    fi

    container_name=$(isula ps -a | grep ${Images_name} | awk '{print$NF}')
    CHECK_RESULT $?

    isula rename ${container_name} ${container_name}_test
    CHECK_RESULT $?

    isula ps -a | grep "${container_name}_test"
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    clean_isulad_env
    DNF_REMOVE
    rm -rf testlog
    LOG_INFO "Finish environment cleanup."
}

main $@
