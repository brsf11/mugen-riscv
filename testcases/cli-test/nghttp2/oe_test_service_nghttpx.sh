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
# @Desc      :   Test nghttpx.service restart
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL nghttp2
    mkdir /etc/nghttpx/
    echo "frontend=0.0.0.0,4433;no-tls
backend=127.0.0.1,3128
http2-proxy=yes
workers=2
no-ocsp=yes" >/etc/nghttpx/nghttpx.conf
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    test_execution nghttpx.service
    systemctl start nghttpx.service
    sed -i 's\ExecStart=/usr/bin/nghttpx\ExecStart=/usr/bin/nghttpx -D\g' /usr/lib/systemd/system/nghttpx.service
    systemctl daemon-reload
    systemctl reload nghttpx.service
    CHECK_RESULT $? 0 0 "nghttpx.service reload failed"
    systemctl status nghttpx.service | grep "Active: active"
    CHECK_RESULT $? 0 0 "nghttpx.service reload causes the service status to change"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    sed -i 's\ExecStart=/usr/bin/nghttpx -D\ExecStart=/usr/bin/nghttpx\g' /usr/lib/systemd/system/nghttpx.service
    systemctl daemon-reload
    systemctl reload nghttpx.service
    systemctl stop nghttpx.service
    rm -rf /etc/nghttpx/
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
