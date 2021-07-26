#!/usr/bin/bash

# Copyright (c) 2021 Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   lutianxiong
# @Contact   :   lutianxiong@huawei.com
# @Date      :   2021-01-10
# @License   :   Mulan PSL v2
# @Desc      :   haproxy test
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
conf="/etc/httpd/conf/httpd.conf"
se_stat="Enforcing"

function pre_test() {
    LOG_INFO "Start environment preparation."
    DNF_INSTALL "httpd curl haproxy"
    se_stat=$(getenforce)
    getenforce | grep Enforcing && setenforce 0

    systemctl stop haproxy
    cp $conf httpd.conf
    sed -i s/"Listen 80"/"Listen 5001"/ $conf
    systemctl restart httpd
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    curl -o index.html localhost && return 1
    systemctl restart haproxy
    CHECK_RESULT $?
    curl -o index.html localhost
    CHECK_RESULT $?
    grep -q "openEuler" index.html
    CHECK_RESULT $?
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    systemctl stop haproxy
    systemctl stop httpd
    mv httpd.conf $conf
    setenforce "$se_stat"
    rm -rf index.html
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main $@
