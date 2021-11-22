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
# @Desc      :   Test kprop.service restart
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
    mv /var/kerberos/krb5kdc/kadm5.acl /var/kerberos/krb5kdc/kpropd.acl
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    test_execution kprop.service
    test_reload kprop.service
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    systemctl stop kprop.service
    rm -rf /var/kerberos/krb5kdc/principal*
    mv -f /var/kerberos/krb5kdc/kpropd.acl /var/kerberos/krb5kdc/kadm5.acl
    sed -i "s\kdc = nfs.server.com\kdc = nfs-server.example.com\g" /etc/krb5.conf
    sed -i "s\admin_server = nfs.server.com\admin_server = nfs-server.example.com\g" /etc/krb5.conf
    hostname "${host_name}"
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
