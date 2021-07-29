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
# @Desc      :   The usage of commands in pcp-import-collectl2pcp binary package
# ############################################
source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "pcp-import-collectl2pcp tar"
    wget -nd http://jaist.dl.sourceforge.net/sourceforge/collectl/collectl-3.1.3.src.tar.gz
    tar zxvf collectl-3.1.3.src.tar.gz
    cd collectl-3.1.3
    ./INSTALL
    cd -
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    collectl -c 5 -f collect &
    SLEEP_WAIT 20
    hostname=$(hostname | awk -F '.' '{print $1}')
    inputfile=$(ls | grep "${hostname}")
    test -f ${inputfile}
    CHECK_RESULT $?
    collectl2pcp -v ${inputfile} collectpcp | grep "New instance"
    CHECK_RESULT $?
    test -f collectpcp.0 -a -f collectpcp.index -a -f collectpcp.meta && rm -rf collectpcp.0 collectpcp.index collectpcp.meta
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf ./collect* ./wget-log* /opt/hp*
    LOG_INFO "End to restore the test environment."
}

main "$@"
