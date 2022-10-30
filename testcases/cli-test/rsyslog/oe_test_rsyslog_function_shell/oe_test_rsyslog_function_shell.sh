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
# @Author    :   wangshan
# @Contact   :   wangshan@163.com
# @Date      :   2020-08-03
# @License   :   Mulan PSL v2
# @Desc      :   Shell execution support
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL rsyslog
    cat >/opt/log_rotation_script <<EOF
#!/usr/bin/bash
mv -f /var/log/test  /var/log/test.1
EOF
    test -f /opt/log_rotation_script || exit 1
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    cat >/etc/rsyslog.d/test.conf <<EOF
    \$outchannel log_rotation,/var/log/test,5120,bash /opt/log_rotation_script
    local7.* :omfile:\$log_rotation
EOF
    systemctl restart rsyslog
    CHECK_RESULT $?
    time=$(date +%s%N)
    size=0
    until [ $size -gt 5120 ]; do
        logger -t local7 -p local7.error "local7test$time"
        size=$(ls -l "/var/log/test" | awk '{print $5}')
    done
    CHECK_RESULT $?
    logger -t local7 -p local7.error "local7test$time"
    SLEEP_WAIT 3
    test -f /var/log/test.1
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf /etc/rsyslog.d/test.conf /opt/log_rotation_script /var/log/test /var/log/test.1
    systemctl restart rsyslog
    LOG_INFO "End to restore the test environment."
}
main "$@"
