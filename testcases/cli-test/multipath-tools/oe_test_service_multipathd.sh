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
# @Desc      :   Test multipathd.service restart
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL multipath-tools
    service=multipathd.service
    log_time=$(date '+%Y-%m-%d %T')
    disk_name=$(lsblk | grep disk | awk '{print $1}' | tr '\n' '|' | sed 's@|$@@')
    mv /etc/multipath.conf /etc/multipath.bak
    echo "defaults {
	user_friendly_names yes
	find_multipaths yes
}
blacklist_exceptions {
        property "\(SCSI_IDENT_\|ID_WWN\)"
}
blacklist {
	devnode \"^${disk_name}\"
}" >/etc/multipath.conf
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    test_restart "${service}"
    test_enabled "${service}"
    journalctl --since "${log_time}" -u "${service}" | grep -i "fail\|error" | grep -v -i "DEBUG\|INFO\|WARNING" | grep -v "failed to increase buffer size"
    CHECK_RESULT $? 0 1 "There is an error message for the log of ${service}"
    systemctl start multipathd.service
    sed -i 's\ExecStart=/sbin/multipathd\ExecStart=/usr/sbin/multipathd -v\g' /usr/lib/systemd/system/multipathd.service
    systemctl daemon-reload
    systemctl reload multipathd.service
    CHECK_RESULT $? 0 0 "multipathd.service reload failed"
    systemctl status multipathd.service | grep "Active: active"
    CHECK_RESULT $? 0 0 "multipathd.service reload causes the service status to change"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    sed -i 's\ExecStart=/usr/sbin/multipathd -v\ExecStart=/usr/sbin/multipathd\g' /usr/lib/systemd/system/multipathd.service
    systemctl daemon-reload
    systemctl reload multipathd.service
    mv /etc/multipath.bak /etc/multipath.conf
    systemctl stop multipathd.service
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"

