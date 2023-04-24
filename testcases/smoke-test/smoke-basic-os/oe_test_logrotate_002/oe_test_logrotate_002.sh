#!/usr/bin/bash

# Copyright (c) 2022 Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   chengweibin
# @Contact   :   chengweibin@uniontech.com
# @Date      :   2023-01-28
# @License   :   Mulan PSL v2
# @Desc      :   smoke basic os test-logrotate
# ############################################
source "$OET_PATH/libs/locallibs/common_lib.sh"


function pre_test()
{
    LOG_INFO "Start environment preparation."
    DNF_INSTALL "logrotate"
    LOG_INFO "End of environmental preparation!"
}

function run_test()
{
    LOG_INFO "Start testing..."
    test -f /etc/logrotate.d/logrotate_test4 && rm -rf /etc/logrotate.d/logrotate_test4
    cat >>/etc/logrotate.d/logrotate_test4<<EOF
/var/log/logrotate_test4.log
{
    maxage 365
    rotate 3
    notifempty
    copytruncate
    missingok
    size +10M
    sharedscripts
    postrotate
        /usr/bin/systemctl kill -s HUP rsyslog.service >/dev/null 2>&1 || true
    endscript
}
EOF
    echo "test" >> /var/log/logrotate_test4.log
    logrotate /etc/logrotate.d/logrotate_test4
    CHECK_RESULT $? 0 0 "logrotate failed"

    test -f /var/log/logrotate_test4.log.1
    CHECK_RESULT $? 0 1 "file exit" 

    head -c 10M < /dev/urandom > /var/log/logrotate_test4.log
    CHECK_RESULT $? 0 0 "file limit failed"

    logrotate /etc/logrotate.d/logrotate_test4
    CHECK_RESULT $? 0 0 "logrotate failed"

    test -f /var/log/logrotate_test4.log.1
    CHECK_RESULT $? 0 0 "file not exit"
    LOG_INFO "Finish test!"
}

function post_test()
{
    LOG_INFO "start environment cleanup."   
    DNF_REMOVE
    rm -rf /etc/logrotate.d/logrotate_test4 && rm -rf /var/log/logrotate_test4*
    LOG_INFO "Finsh environment cleanup! "
}

main $@
