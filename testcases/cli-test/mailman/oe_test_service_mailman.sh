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
# @Desc      :   Test mailman.service restart
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL "mailman postfix"
    old_LANG=${LANG}
    export LANG=en_US.UTF-8
    expect <<EOF
        spawn /usr/lib/mailman/bin/newlist mailman
        expect {
            "running the list:" {
                send "test@test.com\\r"
            }
        }
        expect {
            "password:" {
                send "123456\\r"
            }
        }
        expect eof
EOF
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    test_execution mailman.service
    systemctl start mailman.service
    sed -i 's\ExecStart=/usr/lib/mailman/bin/mailmanctl\ExecStart=/usr/lib/mailman/bin/mailmanctl -q\g' /usr/lib/systemd/system/mailman.service
    systemctl daemon-reload
    systemctl reload mailman.service
    CHECK_RESULT $? 0 0 "mailman.service reload failed"
    systemctl status mailman.service | grep "Active: active"
    CHECK_RESULT $? 0 0 "mailman.service reload causes the service status to change"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    sed -i 's\ExecStart=/usr/lib/mailman/bin/mailmanctl -q\ExecStart=/usr/lib/mailman/bin/mailmanctl\g' /usr/lib/systemd/system/mailman.service
    systemctl daemon-reload
    systemctl reload mailman.service
    systemctl stop mailman.service
    /usr/lib/mailman/bin/rmlist mailman
    export LANG=${old_LANG}
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
