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
# @Author    :   Classicriver_jia
# @Contact   :   classicriver_jia@foxmail.com
# @Date      :   2020-4-9
# @License   :   Mulan PSL v2
# @Desc      :   Set Squid to a cache proxy without authentication
# #############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "squid firewalld"
    systemctl start firewalld
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    sed -i 's/#cache_dir ufs \/var\/spool\/squid 100 16 256/cache_dir ufs \/var\/spool\/squid 100 16 256/g' /etc/squid/squid.conf
    CHECK_RESULT $?
    count_line=$(grep -rn "http_access deny all" /etc/squid/squid.conf | awk -F : '{print$1}')
    test -n ${count_line} && sed -i "${count_line}s/deny/allow/g" /etc/squid/squid.conf
    firewall-cmd --permanent --add-port=3128/tcp
    CHECK_RESULT $?
    firewall-cmd --reload
    CHECK_RESULT $?
    systemctl enable --now squid
    CHECK_RESULT $?
    SLEEP_WAIT 2
    curl -o baidu -L "https://news.baidu.com" -x "${NODE1_IPV4}:3128" --insecure
    CHECK_RESULT $?
    ls -l baidu
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf baidu
    test -n ${count_line} && sed -i "${count_line}s/allow/deny/g" /etc/squid/squid.conf
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main $@
