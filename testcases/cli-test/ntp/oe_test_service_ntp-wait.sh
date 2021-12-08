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
# @Date      :   2020/10/23
# @License   :   Mulan PSL v2
# @Desc      :   Test ntp-wait.service restart
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL "ntp ntp-perl"
    echo "server 127.127.1.0 iburst prefer maxpoll 4 minpoll 4" >> /etc/ntp.conf
    sed -i "s/restrict default nomodify notrap nopeer noepeer noquery/#restrict default nomodify notrap nopeer noepeer noquery/" \
/etc/ntp.conf
    systemctl start ntpd.service
    SLEEP_WAIT 5
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    test_execution ntp-wait.service
    test_reload ntp-wait.service
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    systemctl stop ntp-wait.service
    systemctl stop ntpd.service
    sed -i "/server 127.127.1.0 iburst prefer maxpoll 4 minpoll 4/d" /etc/ntp.conf
    sed -i "s/#restrict default nomodify notrap nopeer noepeer noquery/restrict default nomodify notrap nopeer noepeer noquery/" \
/etc/ntp.conf
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
