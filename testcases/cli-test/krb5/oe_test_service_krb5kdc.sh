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
# @Desc      :   Test krb5kdc.service restart
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL krb5-server
    host_name=$(hostname)
    sed -i "s\kdc = nfs-server.example.com\kdc = nfs.server.com\g" /etc/krb5.conf
    sed -i "s\admin_server = nfs-server.example.com\admin_server = nfs.server.com\g" /etc/krb5.conf
    hostname nfs.server.com
    expect <<EOF
        spawn kdb5_util create -s
        expect {
            "master key:" {
                send "database\\r"
            }
        }
        expect {
            "master key to verify:" {
                send "database\\r"
            }
        }
        expect eof
EOF
    echo -e 'root\nroot' | kadmin.local -q 'addprinc root\admin'
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    test_execution krb5kdc.service
    systemctl start krb5kdc.service
    sed -i 's\ExecStart=/usr/sbin/krb5kdc\ExecStart=/usr/sbin/krb5kdc -m\g' /usr/lib/systemd/system/krb5kdc.service
    systemctl daemon-reload
    systemctl reload krb5kdc.service
    CHECK_RESULT $? 0 0 "krb5kdc.service reload failed"
    systemctl status krb5kdc.service | grep "Active: active"
    CHECK_RESULT $? 0 0 "krb5kdc.service reload causes the service status to change"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    sed -i 's\ExecStart=/usr/sbin/krb5kdc -m\ExecStart=/usr/sbin/krb5kdc\g' /usr/lib/systemd/system/krb5kdc.service
    systemctl daemon-reload
    systemctl reload krb5kdc.service
    systemctl stop krb5kdc.service
    rm -rf /var/kerberos/krb5kdc/principal*
    sed -i "s\kdc = nfs.server.com\kdc = nfs-server.example.com\g" /etc/krb5.conf
    sed -i "s\admin_server = nfs.server.com\admin_server = nfs-server.example.com\g" /etc/krb5.conf
    hostname "${host_name}"
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
