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
# @Author    :   Classicriver_jia
# @Contact   :   classicriver_jia@foxmail.com
# @Date      :   2020-06-08
# @License   :   Mulan PSL v2
# @Desc      :   data copy between the container and the host
# ############################################

source ../common/prepare_docker.sh
function pre_test() {
    LOG_INFO "Start environment preparation."
    pre_docker_env
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase."
    run_docker_container

    test -d testdir && rm -rf testdir
    mkdir testdir
    touch testdir/mytest.txt
    docker cp testdir ${containers_id}:/root
    CHECK_RESULT $?

    docker exec -i ${containers_id} /bin/sh >testlog <<EOF
ls /root/testdir
exit
EOF
    grep "mytest.txt" testlog
    CHECK_RESULT $?
    test -d root && rm -rf root
    docker cp ${containers_id}:/root .
    CHECK_RESULT $?
    test -f root/testdir/mytest.txt
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    clean_docker_env
    DNF_REMOVE
    rm -rf testdir root testlog
    LOG_INFO "Finish environment cleanup."
}

main $@
