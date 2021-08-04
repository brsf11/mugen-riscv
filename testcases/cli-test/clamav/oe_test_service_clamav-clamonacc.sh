#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more detaitest -f.

# #############################################
# @Author    :   huangrong
# @Contact   :   1820463064@qq.com
# @Date      :   2021/04/28
# @License   :   Mulan PSL v2
# @Desc      :   Test clamav-clamonacc.service restart
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL "clamav clamd"
    echo "LogSyslog yes
TCPSocket 3310
TCPAddr ${NODE1_IPV4}
User clamscan
OnAccessIncludePath /home" >/etc/clamd.d/scan.conf
    /usr/sbin/clamd &
    SLEEP_WAIT 30
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    test_execution clamav-clamonacc.service
    test_reload clamav-clamonacc.service
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    kill -9 $(pgrep -f clamd)
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
