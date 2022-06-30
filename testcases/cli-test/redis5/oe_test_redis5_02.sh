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
# @Desc      :   Test redis5 command
# ############################################
source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment!"
    DNF_INSTALL redis5
    systemctl start redis
    LOG_INFO "End to prepare the test environment!"
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    systemctl status redis | grep running
    SLEEP_WAIT 5
    redis-cli -r 3 ping | grep "PONG"
    CHECK_RESULT $?
    redis-cli -r 3 -i 1 ping | grep "PONG"
    CHECK_RESULT $?
    echo "test" | redis-cli -x set hello | grep "OK"
    CHECK_RESULT $?
    redis-cli --version | grep "redis-cli"
    CHECK_RESULT $?
    expect -c "
    set timeout 10
    log_file testlog
    spawn redis-cli -h 127.0.0.1 -p 6379
    expect {
        \"127.0.0.1:6379>\" { send \"bgsave\r\"
	expect \"127.0.0.1:6379>\" {send \"exit\r\"}
}
}
expect eof
"
    grep -iE "error|failed" testlog
    CHECK_RESULT $? 1
    SLEEP_WAIT 5
    ls /var/lib/redis
    test -f /var/lib/redis/dump.rdb
    CHECK_RESULT $?
    redis-check-rdb /var/lib/redis/dump.rdb | grep "OK"
    CHECK_RESULT $?
    sed -i 's/appendonly no/appendonly yes/g' /etc/redis.conf
    CHECK_RESULT $?
    redis-cli config set appendonly yes | grep "OK"
    CHECK_RESULT $?
    redis-cli config set save "" | grep "OK"
    CHECK_RESULT $?
    SLEEP_WAIT 5
    cp /var/lib/redis/appendonly.aof /var/lib/redis/appendonly_bak.aof
    CHECK_RESULT $?
    redis-check-aof --fix /var/lib/redis/appendonly.aof
    CHECK_RESULT $?
    redis-server /etc/redis.conf >/dev/null 2>&1 &
    CHECK_RESULT $?
    PID=$(echo $!)
    ps -ef | grep ${PID}
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "Start environment cleanup."
    kill -9 ${PID}
    rm -rf testlog* /var/lib/redis/redis/appendonly_bak.aof
    systemctl stop redis
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup."
}

main $@
