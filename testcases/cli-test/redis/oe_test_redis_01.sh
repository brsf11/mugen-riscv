#!/usr/bin/bash

# Copyright (c) 2022 Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   duanxuemin
# @Contact   :   duanxuemin_job@163.com
# @Date      :   2020-04-09
# @License   :   Mulan PSL v2
# @Desc      :   Test redis command
# ############################################
source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment!"
    rm -rf /var/lib/redis/dump.rdb
    DNF_INSTALL redis
    systemctl start redis
    LOG_INFO "End to prepare the test environment!"
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    systemctl status redis | grep running
    CHECK_RESULT $?
    redis-benchmark -t set -n 1000000 -r 100000000
    CHECK_RESULT $?
    redis-benchmark -t ping,set,get -n 100000 --csv
    CHECK_RESULT $?
    redis-benchmark -r 10000 -n 10000 eval 'return redis.call("ping")' 0
    CHECK_RESULT $?
    redis-benchmark -r 10000 -n 10000 lpush mylist __rand_int__
    CHECK_RESULT $?
    cat /etc/passwd | redis-cli -x set mypasswd | grep "OK"
    CHECK_RESULT $?
    redis-cli get mypasswd
    CHECK_RESULT $?
    redis-cli -r 100 lpush mylist x
    CHECK_RESULT $?
    redis-cli -r 100 -i 1 info | grep used_memory_human: | grep "used_memory_human"
    CHECK_RESULT $?
    redis-cli --scan --pattern '*:12345*'
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "Start environment cleanup."
    systemctl stop redis
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup."
}

main $@
