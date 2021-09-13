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
# @Desc      :   Backup and restore nftable rules
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    nft add table inet example_table
    nft add chain inet example_table example_chain { type filter hook input priority 0 \; policy accept \; }
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start executing testcase."
    nft list ruleset >file.nft
    grep -nr "type filter hook input priority filter; policy accept;" file.nft
    CHECK_RESULT $? 0 0 "backup to file.nft failed"
    nft -j list ruleset >file.json
    grep -nr "{\"chain\": {\"family\": \"inet\", \"table\": \"example_table\", \"name\": \"example_chain\", \"handle\": 1, \"type\": \"filter\", \"hook\": \"input\", \"prio\": 0, \"policy\": \"accept\"}}" file.json
    CHECK_RESULT $? 0 0 "backup to file.json failed"
    nft delete table inet example_table
    nft list chains | grep example_chain
    CHECK_RESULT $? 1 0 "exec 'nft delete table inet example_table' failed"
    
    nft -f file.nft
    nft list chains | grep example_chain
    CHECK_RESULT $? 0 0 "restores from file.nft failed"
    nft delete table inet example_table
    nft list chains | grep example_chain
    CHECK_RESULT $? 1 0 "exec 'nft delete table inet example_table' failed"

    nft -j -f file.json
    nft list chains | grep example_chain
    CHECK_RESULT $? 0 0 "restores from file.json failed"
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    nft delete table inet example_table
    rm -rf file.json file.nft
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
