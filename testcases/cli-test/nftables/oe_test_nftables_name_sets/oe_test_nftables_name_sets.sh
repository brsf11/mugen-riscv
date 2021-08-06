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
# @Date      :   2021/08/03
# @License   :   Mulan PSL v2
# @Desc      :   Use named sets in nftable
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function config_params() {
    LOG_INFO "Start to config params of the case."
    table_name=sec009
    chain_name=sec009_chain
    nft add table inet $table_name
    nft add chain inet $table_name $chain_name { type filter hook input priority 0 \; policy accept \; }
    LOG_INFO "End to config params of the case."
}

function run_test() {
    LOG_INFO "Start executing testcase."
    nft add set inet $table_name individual_set { type ipv4_addr \; }
    nft add set inet $table_name multi_set { type ipv4_addr \; flags interval \; }
    nft add rule inet $table_name $chain_name ip saddr @individual_set drop
    nft list table inet $table_name | grep individual_set
    CHECK_RESULT $? 0 0 "exec add individual_set failed"
    
    nft add rule inet $table_name $chain_name ip saddr @multi_set drop
    nft list table inet $table_name | grep multi_set
    CHECK_RESULT $? 0 0 "exec add multi_set failed"

    nft add element inet $table_name individual_set { 192.0.2.1, 192.0.2.2}
    nft list table inet $table_name | grep "192.0.2.1"
    CHECK_RESULT $? 0 0 "exec add element individual_set failed"
    
    nft add element inet $table_name multi_set { 192.0.2.0-192.0.2.255 }
    nft list table inet $table_name | grep "192.0.2.0/24"
    CHECK_RESULT $? 0 0 "exec add element multi_set failed"
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    nft delete table inet $table_name
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
