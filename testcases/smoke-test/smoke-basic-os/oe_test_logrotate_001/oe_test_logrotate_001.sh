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
# @Date      :   2022-11-08
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
    test -f /etc/logrotate.d/logrotate_test3 && rm -rf /etc/logrotate.d/logrotate_test3
    cat >>/etc/logrotate.d/logrotate_test3<<EOF
/var/log/logrotate_test3.log
{
    maxage 365
    compress
    rotate 3
    notifempty
    copytruncate
    missingok
    size +1M
    sharedscripts
    postrotate
        /usr/bin/systemctl kill -s HUP rsyslog.service >/dev/null 2>&1 || true
    endscript
}
EOF


    echo "test" >> /var/log/logrotate_test3.log
    logrotate --force /etc/logrotate.d/logrotate_test3
    CHECK_RESULT $? 0 0 "logrotate --force failed"

    test -f /var/log/logrotate_test3.log.1.gz
    CHECK_RESULT $? 0 0 "file no exit"
    LOG_INFO "Finish test!"
}

function post_test()
{
    LOG_INFO "start environment cleanup.   "
    rm -rf /etc/logrotate.d/logrotate_test3 && rm -rf /var/log/logrotate_test3
    DNF_REMOVE
    LOG_INFO "Finsh environment cleanup! "
}

main $@
