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
# @Desc      :   Test garbd.service restart
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL "galera mariadb-server-galera mariadb"
    systemctl start mariadb
    mysqladmin -u root password 123456
    sed -i 's/#wsrep_cluster_address="dummy:\/\/"/wsrep_cluster_address="gcomm:\/\/"/g' /etc/my.cnf.d/galera.cnf
    sed -i 's/#wsrep_node_name=/wsrep_node_name=localhost.localdomain/g' /etc/my.cnf.d/galera.cnf
    sed -i "s/#wsrep_node_address=/wsrep_node_address=${NODE1_IPV4}/g" /etc/my.cnf.d/galera.cnf
    sed -i "s/wsrep_sst_auth=root:/wsrep_sst_auth=root:123456/g" /etc/my.cnf.d/galera.cnf
    sed -i "s/wsrep_on=0/wsrep_on=1/g" /etc/my.cnf.d/galera.cnf
    expect <<EOF
        spawn mysql -u root -p123456
        expect {
            "MariaDB*" {
                send "grant all privileges on *.* to 'root'@'localhost' identified by '123456';\\r"
            }
        }
        expect {
            "MariaDB*" {
                send "grant all privileges on *.* to 'root'@'%' identified by '123456';\\r"
            }
        }
         expect {
            "MariaDB*" {
                send "flush privileges;\\r"
            }
        }
        expect {
            "MariaDB*" {
                send "exit\\r"
            }
        }
        expect eof
EOF
    echo -e "GALERA_NODES=\"${NODE1_IPV4}:4567\"
GALERA_GROUP=\"my_wsrep_cluster\"
GALERA_OPTIONS=\"gmcast.listen_addr=tcp://0.0.0.0:4569\"
" >/etc/sysconfig/garb
    systemctl restart mariadb
    service=garbd.service
    log_time=$(date '+%Y-%m-%d %T')
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    test_restart ${service}
    test_enabled ${service}
    journalctl --since "${log_time}" -u "${service}" | grep -i "fail\|error" | grep -v -i "DEBUG\|INFO\|WARNING" \
    | grep -v "access file(./gvwstate.dat) failed(No such file or directory)"
    CHECK_RESULT $? 0 1 "There is an error message for the log of ${service}"
    test_reload ${service}
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    systemctl stop ${service}
    systemctl stop mariadb.service
    rm -rf /var/lib/mysql/*
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
