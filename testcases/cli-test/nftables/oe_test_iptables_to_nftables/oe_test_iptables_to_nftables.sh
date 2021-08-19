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
# Modify     :   yang_lijin@qq.com
# @Date      :   2021/8/2
# @License   :   Mulan PSL v2
# @Desc      :   Convert iptables rules to nftables rules
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL iptables-nft
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    iptables-translate -A INPUT -j CHECKSUM --checksum-fill | grep 'nft # -A INPUT -j CHECKSUM --checksum-fill'
    CHECK_RESULT $? 0 0 "use iptables-translate failed" 
    iptables-restore-translate -f /etc/sysconfig/iptables | grep 'Translated by iptables-restore-translate'
    CHECK_RESULT $? 0 0 "exec 'iptables-restore-translate -f /etc/sysconfig/iptables' failed"
    iptables-save > /tmp/iptables.dump
    iptables-restore-translate -f /tmp/iptables.dump | grep 'Translated by iptables-restore-translate'
    CHECK_RESULT $? 0 0 "exec 'ptables-restore-translate -f /tmp/iptables.dump' failed"
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    rm -rf /tmp/iptables.dump
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
