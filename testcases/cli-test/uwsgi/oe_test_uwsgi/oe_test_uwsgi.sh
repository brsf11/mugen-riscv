#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   liujuan
# @Contact   :   lchutian@163.com
# @Date      :   2020/10/30
# @License   :   Mulan PSL v2
# @Desc      :   verify the uasge of uwsgi command
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL python3-uWSGI
    pip3 install uwsgitop
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    uwsgi --help | grep "Usage: /usr/bin/uwsgi \[options...\]"
    CHECK_RESULT $?
    pip3 | grep -E "Usage:|pip3 <command> \[options\]"
    CHECK_RESULT $?
    nohup uwsgi --http :9090 --wsgi-file test.py >/dev/null 2>&1 &
    CHECK_RESULT $?
    curl http://${NODE1_IPV4}:9090 -w '\n' | grep "Hello World"
    CHECK_RESULT $?
    curl http://127.0.0.1:9090 -w '\n' | grep "Hello World"
    CHECK_RESULT $?
    curl http:/0.0.0.0:9090 -w '\n' | grep "Hello World"
    CHECK_RESULT $?
    kill -9 $(pgrep -f 'uwsgi --http')
    SLEEP_WAIT 5
    nohup uwsgi --http :9090 --wsgi-file test.py --master --processes 4 --threads 2 >/dev/null 2>&1 &
    CHECK_RESULT $?
    curl http://${NODE1_IPV4}:9090 -w '\n' | grep "Hello World"
    CHECK_RESULT $?
    curl http://127.0.0.1:9090 -w '\n' | grep "Hello World"
    CHECK_RESULT $?
    curl http:/0.0.0.0:9090 -w '\n' | grep "Hello World"
    CHECK_RESULT $?
    kill -9 $(pgrep -f 'uwsgi --http')
    SLEEP_WAIT 5
    nohup uwsgi --http :9090 --wsgi-file test.py --master --processes 4 --threads 2 --stats 127.0.0.1:9191 >/dev/null 2>&1 &
    CHECK_RESULT $?
    curl http://${NODE1_IPV4}:9090 -w '\n' | grep "Hello World"
    CHECK_RESULT $?
    curl http://127.0.0.1:9090 -w '\n' | grep "Hello World"
    CHECK_RESULT $?
    curl http:/0.0.0.0:9090 -w '\n' | grep "Hello World"
    CHECK_RESULT $?
    expect <<EOF
        log_file log1
        spawn uwsgitop 127.0.0.1:9191
        expect eof
EOF
    pid=$(pgrep -f 'uwsgi --http' | head -n 1)
    grep $pid log1
    CHECK_RESULT $?
    kill -9 $(pgrep -f 'uwsgi --http')
    SLEEP_WAIT 5
    nohup uwsgi --socket 127.0.0.1:3031 --wsgi-file test.py --master --processes 4 --threads 2 --stats 127.0.0.1:9191 >/dev/null 2>&1 &
    CHECK_RESULT $?
    pid=$(pgrep -f 'uwsgi --socket' | head -n 1)
    expect <<EOF
        log_file log2
        spawn uwsgitop 127.0.0.1:9191
        expect eof
EOF
    grep $pid log2
    CHECK_RESULT $?
    kill -9 $(pgrep -f 'uwsgi --socket')
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf $(ls | grep -vE ".sh|.py")
    pip3 uninstall uwsgitop -y
    DNF_REMOVE
    LOG_INFO "Finish restoring the test environment."
}

main $@
