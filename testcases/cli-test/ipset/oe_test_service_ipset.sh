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
# @Desc      :   Test ipset.service restart
# #############################################

source "../common/common_lib.sh"

function run_test() {
    LOG_INFO "Start testing..."
    test_execution ipset.service
    systemctl start ipset.service
    sed -i 's\IPSET_SAVE_ON_RESTART=no\IPSET_SAVE_ON_RESTART=yes\g' /usr/lib/systemd/system/ipset.service
    systemctl daemon-reload
    systemctl reload ipset.service
    CHECK_RESULT $? 0 0 "ipset.service reload failed"
    systemctl status ipset.service | grep "active (exited)"
    CHECK_RESULT $? 0 0 "ipset.service reload causes the service status to change"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    sed -i 's\IPSET_SAVE_ON_RESTART=yes\IPSET_SAVE_ON_RESTART=no\g' /usr/lib/systemd/system/ipset.service
    systemctl daemon-reload
    systemctl reload ipset.service
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
