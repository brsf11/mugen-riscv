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
# @Author    :   liujingjing
# @Contact   :   liujingjing25812@163.com
# @Date      :   2020/11/10
# @License   :   Mulan PSL v2
# @Desc      :   The usage of commands in pcp-import-ganglia2pcp binary package
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "pcp-import-ganglia2pcp httpd ganglia ganglia-gmetad ganglia-gmond ganglia-web rrdtool"
    DNF_INSTALL "ganglia-gmond" 2
    setenforce 0
    systemctl stop firewalld
    sed -i "s/data_source \"my cluster\" localhost/data_source \"cluster01\" ${NODE1_IPV4}/g" /etc/ganglia/gmetad.conf
    SLEEP_WAIT 10
    service gmond restart
    service httpd restart
    service gmetad restart
    ls /var/lib/ganglia/rrds/unspecified/
    P_SSH_CMD --node 2 --cmd "
        systemctl stop firewalld;
        setenforce 0;
        sed -i '/ name / s/unspecified/cluster01/' /etc/ganglia/gmond.conf;
        service gmond restart;"
    SLEEP_WAIT 60
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ganglia2pcp -f gangpcp -d ./ -Z UTC -h localhost /var/lib/ganglia/rrds/unspecified/${NODE2_IPV4}/
    CHECK_RESULT $?
    grep -aE "localhost|UTC" gangpcp.index
    CHECK_RESULT $?
    test -f gangpcp.0 -a -f gangpcp.meta && rm -rf gangpcp.0 gangpcp.meta gangpcp.index
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf /var/lib/ganglia
    LOG_INFO "End to restore the test environment."
}

main "$@"
