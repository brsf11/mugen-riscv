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
# @Author    :   huyahui
# @Contact   :   huyahui8@163.com
# @Modify    :   yang_lijin@qq.com
# @Date      :   2021/8/3
# @License   :   Mulan PSL v2
# @Desc      :   Create and debug nftable rules with counters
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function config_params() {
    LOG_INFO "Start to config params of the case."
    table_name=sec012
    chain_name=sec012_chain
    LOG_INFO "End to config params of the case."
}

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL httpd
    echo 'hello' >/var/www/html/hello.html
    chmod 777 /var/www/html/hello.html
    sudo systemctl start httpd
    nft add table inet $table_name
    nft add chain inet $table_name $chain_name { type filter hook input priority 0 \; policy accept \; }
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    nft add rule inet $table_name $chain_name tcp dport 80 counter accept
    counter_num=$(nft list ruleset | grep "tcp dport 80 counter packets" | awk '{print $6}')
    CHECK_RESULT $counter_num 0 0 "byte is not 0"
    curl 127.0.0.1/hello.html &
    SLEEP_WAIT 1
    counter_num=$(nft list ruleset | grep "tcp dport 80 counter packets" | awk '{print $6}')
    CHECK_RESULT $counter_num 0 1 "byte is 0"
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    nft delete table inet $table_name
    DNF_REMOVE
    rm -rf /var/www/html/hello.html
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
