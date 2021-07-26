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
#@Author    	:   doraemon2020
#@Contact   	:   xcl_job@163.com
#@Date      	:   2020-10-09
#@License   	:   Mulan PSL v2
#@Desc      	:   command test-nginx
#####################################
source "${OET_PATH}"/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL nginx
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    systemctl start nginx
    systemctl status nginx | grep "running"
    CHECK_RESULT 0
    nginx -? 2>&1 | grep -i "usage"
    CHECK_RESULT 0
    nginx -h 2>&1 | grep -i "usage"
    CHECK_RESULT 0
    test "$(nginx -v 2>&1 | grep -Eo '[0-9]*\.[0-9]*\.[0-9]*')" == \
        "$(rpm -qi nginx | grep 'Version' | awk '{print$3}')"
    CHECK_RESULT 0
    test "$(nginx -V 2>&1 | grep "version" | grep -Eo "[0-9]*\.[0-9]*\.[0-9]*")" == \
        "$(rpm -qi nginx | grep 'Version' | awk '{print$3}')"
    CHECK_RESULT 0
    test "$(nginx -V 2>&1 | grep 'GCC' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+[a-z]*')" == \
        "$(rpm -qi gcc | grep 'Version' | awk '{print$3}')"
    CHECK_RESULT 0
    test "$(nginx -V 2>&1 | grep 'OpenSSL' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+[a-z]*')" == \
        "$(rpm -qi openssl | grep 'Version' | awk '{print$3}')"
    CHECK_RESULT 0
    nginx -t | grep "ok"
    CHECK_RESULT 0
    nginx -T | grep "successful"
    CHECK_RESULT 0
    nginx -t -q
    CHECK_RESULT 0
    echo "hello world1" >/usr/share/nginx/html/index.html
    curl localhost 2>&1 | grep "hello"
    CHECK_RESULT 0
    nginx -s stop
    CHECK_RESULT 0
    SLEEP_WAIT 1
    pgrep nginx
    CHECK_RESULT $? 1
    systemctl start nginx
    SLEEP_WAIT 1
    nginx -s quit
    SLEEP_WAIT 1
    pgrep nginx
    CHECK_RESULT $? 1
    systemctl start nginx
    mv /var/log/nginx/access.log /var/log/nginx/access.log.0
    ls /var/log/nginx/access.log
    CHECK_RESULT $? 0 1
    nginx -s reopen
    ls /var/log/nginx/access.log
    CHECK_RESULT 0
    echo "abc" >>/etc/nginx/nginx.conf
    nginx -s reload
    CHECK_RESULT $? 1
    SLEEP_WAIT 1
    sed -i '/abc/d' /etc/nginx/nginx.conf
    nginx -s reload
    CHECK_RESULT 0
    nginx -s quit
    cp /etc/nginx/nginx.conf /root/ -rf
    sed -i 's/80/81/g' /root/nginx.conf
    SLEEP_WAIT 1
    nginx -c /root/nginx.conf
    CHECK_RESULT 0
    echo "hello world2" >/usr/share/nginx/html/index.html
    curl localhost:81 2>&1 | grep "hello"
    CHECK_RESULT 0
    nginx -p /root/
    test $(ps -aux | grep nginx | grep -c master) -eq 2
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    pkill -9 nginx
    DNF_REMOVE nginx
    rm -rf /root/nginx.conf
    LOG_INFO "Finish restoring the test environment."
}

main "$@"
