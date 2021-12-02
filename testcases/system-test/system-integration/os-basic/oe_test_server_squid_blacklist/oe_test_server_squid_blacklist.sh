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
# @Desc      :   Configuring the domain blacklist in Squid
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
    sed -i 's/#cache_dir ufs \/var\/spool\/squid 120 16 256/cache_dir ufs \/var\/spool\/squid 100 16 256/g' /etc/squid/squid.conf
    CHECK_RESULT $?
    echo 'acl domain_blacklist dstdomain "/tmp/squid/domain_blacklist.txt" http_access deny all domain_blacklist' >>/etc/squid/squid.conf
    CHECK_RESULT $?
    mkdir /tmp/squid
    echo "new.baidu.com" >/tmp/squid/domain_blacklist.txt
    CHECK_RESULT $?
    firewall-cmd --permanent --add-port=3128/tcp
    CHECK_RESULT $?
    firewall-cmd --reload
    CHECK_RESULT $?
    systemctl enable --now squid
    CHECK_RESULT $?
    curl -o baidu -L "https://news.baidu.com" -x "${NODE1_IPV4}:3128" --insecure
    CHECK_RESULT $? 7
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf /tmp/squid baidu
    sed -i "/domain_blacklist.txt/d" /etc/squid/squid.conf
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main $@
