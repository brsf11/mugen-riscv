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
#@Author        :   zhujinlong
#@Contact       :   zhujinlong@163.com
#@Date          :   2021-1-6
#@License       :   Mulan PSL v2
#@Desc          :   service related
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function config_params() {
    LOG_INFO "Start to config params of the case."
    EXECUTE_T="90m"
    LOG_INFO "End to config params of the case."
}

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "obs-server httpd"
    sed -i "s/seq 600/seq 30/" /usr/sbin/obsscheduler
    echo -e "<productdefinition>\n</productdefinition>" >1.xml
    echo "hello world" >1.txt
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    obs_productconvert 1.xml . | grep "parsing product definition... success!"
    CHECK_RESULT $?
    obs_serverstatus 1.txt
    CHECK_RESULT $?
    obsscheduler --help | grep "Usage"
    CHECK_RESULT $?
    obsscheduler start
    CHECK_RESULT $?
    obsscheduler_id=$(pgrep -f bs_sched)
    [ -n "$obsscheduler_id" ]
    CHECK_RESULT $?
    SLEEP_WAIT 35 "obsscheduler stop" 2
    CHECK_RESULT $?
    obsscheduler_id=$(pgrep -f bs_sched)
    [ -z "$obsscheduler_id" ]
    CHECK_RESULT $?
    obsworker | grep "Usage"
    CHECK_RESULT $?
    nohup obsworker start >obsworker.log 2>&1 &
    SLEEP_WAIT 3 "grep 'http://localhost:5252/getworkercode' obsworker.log" 2
    CHECK_RESULT $?
    kill -9 $(pgrep -f obsworker)
    CHECK_RESULT $?

    command_list=$(rpm -ql obs-server | grep bin | grep rcobs*)
    for command in $command_list; do
        $command 2>&1 | grep 'Usage'
        CHECK_RESULT $?
        $command --status-all
        CHECK_RESULT $?
        $command httpd start
        CHECK_RESULT $?
        SLEEP_WAIT 15 "$command httpd status | grep 'active (running)'" 2
        CHECK_RESULT $?
        $command httpd restart
        CHECK_RESULT $?
        SLEEP_WAIT 15 "$command httpd status | grep 'active (running)'" 2
        CHECK_RESULT $?
        $command httpd stop
        CHECK_RESULT $?
        SLEEP_WAIT 15 "$command httpd status | grep 'inactive (dead)'" 2
        CHECK_RESULT $?
        $command httpd try-restart
        CHECK_RESULT $?
        SLEEP_WAIT 15 "$command httpd status | grep 'inactive (dead)'" 2
        CHECK_RESULT $?
        $command httpd start
        CHECK_RESULT $?
        SLEEP_WAIT 15 "$command httpd try-restart" 2
        CHECK_RESULT $?
        SLEEP_WAIT 15 "$command httpd status | grep 'active (running)'" 2
        CHECK_RESULT $?
        sed -i 's/Listen 80/Listen 8000/g' /etc/httpd/conf/httpd.conf
        CHECK_RESULT $?
        $command httpd reload
        CHECK_RESULT $?
        SLEEP_WAIT 15 "$command httpd status | grep 'active (running)\|reloading (reload)'" 2
        CHECK_RESULT $?
        sed -i 's/Listen 8000/Listen 8001/g' /etc/httpd/conf/httpd.conf
        CHECK_RESULT $?
        $command httpd force-reload
        CHECK_RESULT $?
        SLEEP_WAIT 15 "$command httpd status | grep 'active (running)\|reloading (reload)'" 2
        CHECK_RESULT $?
        sed -i 's/Listen 8001/Listen 8002/g' /etc/httpd/conf/httpd.conf
        CHECK_RESULT $?
        $command httpd reload-or-restart
        CHECK_RESULT $?
        SLEEP_WAIT 15 "$command httpd status | grep 'active (running)\|reloading (reload)'" 2
        CHECK_RESULT $?
        sed -i 's/Listen 8002/Listen 8003/g' /etc/httpd/conf/httpd.conf
        CHECK_RESULT $?
        $command httpd try-reload-or-restart
        CHECK_RESULT $?
        SLEEP_WAIT 15 "$command httpd status | grep 'active (running)\|reloading (reload)'" 2
        CHECK_RESULT $?
        $command httpd condrestart
        CHECK_RESULT $?
        SLEEP_WAIT 15 "$command httpd status | grep 'active (running)'" 2
        CHECK_RESULT $?
        sed -i 's/Listen 8003/Listen 80/g' /etc/httpd/conf/httpd.conf
        CHECK_RESULT $?
    done
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -f 1.txt 1.xml obsworker.log
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
