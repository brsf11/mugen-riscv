#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
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
# @Desc      :   Test systemd-journal-remote.service restart
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL systemd-journal-remote
    sed -i "s\listen-https=-3\listen-http=-3\g" /usr/lib/systemd/system/systemd-journal-remote.service
    systemctl daemon-reload
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    test_execution systemd-journal-remote.service
    test_reload systemd-journal-remote.service
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "Start environment cleanup."
    sed -i "s\listen-http=-3\listen-https=-3\g" /usr/lib/systemd/system/systemd-journal-remote.service
    systemctl daemon-reload
    systemctl stop systemd-journal-remote.service
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
