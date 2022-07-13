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
# @Author    :   zhaorunqi
# @Contact   :   runqi@isrc.iscas.ac.cn
# @Date      :   2022/1/15
# @License   :   Mulan PSL v2
# @Desc      :   Test lsyncd -direct
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL lsyncd
    mkdir -p /var/source_dir /var/target_dir
    cat >> /etc/lsyncd.conf << EOF
settings {
    logfile = "/var/log/lsyncd/lsyncd.log",
    statusFile = "/var/log/lsyncd/lsyncd.status"
}
sync {
    default.direct,
    source = "/var/source_dir/",
    target = "/var/target_dir/",
    delete = true,
    delay = 0,
    exclude={
        ".txt"
    },
    rsync = {
    binary = "/usr/bin/rsync",
    archive = true,
    compress = true,
    verbose = true,
    owner = true,
    perms = true,
    _extra = {"--bwlimit=2000"},
    }
}
EOF
    echo "This is to test the direct function of lsyncd" >>/var/source_dir/test.lua
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    lsyncd -direct /var/source_dir/ /var/target_dir/
    SLEEP_WAIT 5
    test -f /var/target_dir/test.lua
    CHECK_RESULT $? 0 0 "This is to test the direct function of lsyncd"
    LOG_INFO "End to run test."
}
function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf /var/source_dir /var/target_dir /var/log/lsyncd /etc/lsyncd.conf
    kill -9 $(ps -ef | grep "lsyncd" | grep -Ev "grep|bash" | awk '{print $2}')
    LOG_INFO "End to restore the test environment."
}

main "$@"
