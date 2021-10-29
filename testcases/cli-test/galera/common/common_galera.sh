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
# @Author    :   zhanglu626
# @Contact   :   m18409319968@163.com
# @Date      :   2021/10/23
# @License   :   Mulan PSL v2
# @Desc      :   galera prepare
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function galera_pre() {
    systemctl stop firewalld
    systemctl disable firewalld
    setenforce 0
    DNF_INSTALL "galera openssl"
    mkdir galera_zl
    touch galera_zl/log1 galera_zl/log2 galera_zl/log3
    openssl genrsa 2048 > galera_zl/ca-key.pem
    /usr/bin/expect <<-EOF
    spawn openssl req -new -x509 -nodes -days 3600 -key galera_zl/ca-key.pem -out galera_zl/ca.pem
    expect {
    "*\[AU\]:" { send "\n"; exp_continue }
    "*\[Some-State\]:" { send "\n"; exp_continue }
    "*(eg, city) \[\]:" { send "\n"; exp_continue }
    "*Ltd\]:" { send "\n"; exp_continue }
    "*(eg, section) \[\]:" { send "\n"; exp_continue }
    "*name) \[\]:" { send "\n"; exp_continue }
    "*Address \[\]:" { send "\n"; exp_continue }
}
    spawn openssl req -newkey rsa:2048 -days 3600 -nodes -keyout galera_zl/server-key.pem -out galera_zl/server-req.pem
    expect {
    "*\[AU\]:" { send "\n"; exp_continue }
    "*\[Some-State\]:" { send "\n"; exp_continue }
    "*(eg, city) \[\]:" { send "\n"; exp_continue }
    "*Ltd\]:" { send "\n"; exp_continue }
    "*(eg, section) \[\]:" { send "\n"; exp_continue }
    "*name) \[\]:" { send "\n"; exp_continue }
    "*Address \[\]:" { send "\n"; exp_continue }
    "*password \[\]:" { send "\n"; exp_continue }
    "*name \[\]:" { send "\n"; exp_continue }
}
    expect eof
EOF
    SLEEP_WAIT 5
    openssl rsa -in galera_zl/server-key.pem -out galera_zl/server-key.pem
    openssl x509 -req -in galera_zl/server-req.pem -days 3600 -CA galera_zl/ca.pem -CAkey galera_zl/ca-key.pem -set_serial 01 -out galera_zl/server-cert.pem
    /usr/bin/expect <<-EOF
    spawn openssl req -newkey rsa:2048 -days 3600 -nodes -keyout galera_zl/client-key.pem -out galera_zl/client-req.pem
    expect {
    "*\[AU\]:" { send "\n"; exp_continue }
    "*\[Some-State\]:" { send "\n"; exp_continue }
    "*(eg, city) \[\]:" { send "\n"; exp_continue }
    "*Ltd\]:" { send "\n"; exp_continue }
    "*(eg, section) \[\]:" { send "\n"; exp_continue }
    "*name) \[\]:" { send "\n"; exp_continue }
    "*Address \[\]:" { send "\n"; exp_continue }
    "*password \[\]:" { send "\n"; exp_continue }
    "*name \[\]:" { send "\n"; exp_continue }
}
    expect eof
EOF
    openssl rsa -in galera_zl/client-key.pem -out galera_zl/client-key.pem
    openssl x509 -req -in galera_zl/client-req.pem -days 3600 -CA galera_zl/ca.pem -CAkey galera_zl/ca-key.pem -set_serial 01 -out galera_zl/client-cert.pem
    echo "name = node_name
    address = gcomm://0.0.0.0
    group = grabd_name" >> galera_zl/galera_cfg
}
