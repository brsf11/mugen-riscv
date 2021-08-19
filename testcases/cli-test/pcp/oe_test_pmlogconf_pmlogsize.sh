#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author        :   zhujinlong
#@Contact       :   zhujinlong@163.com
#@Date          :   2020-10-19
#@License       :   Mulan PSL v2
#@Desc          :   pcp testing(pmlogconf,pmlogsize)
#####################################

source "common/common_pcp.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    archive_data=$(pcp -h "$host_name" | grep 'primary logger:' | awk -F: '{print $NF}')
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    pmlogconf -c configfile
    CHECK_RESULT $?
    grep 'log advisory on default' configfile
    CHECK_RESULT $?
    rm -f configfile
    pmlogconf -d . configfile
    CHECK_RESULT $?
    grep 'allow local' configfile
    CHECK_RESULT $?
    rm -f configfile
    pmlogconf -h $host_name configfile
    CHECK_RESULT $?
    test -f configfile
    CHECK_RESULT $?
    rm -f configfile 
    pmlogconf -qrv configfile | grep '/var/lib/pcp/config/pmlogconf'
    CHECK_RESULT $?
    test -f configfile
    CHECK_RESULT $?
    rm -f configfile
    pmlogsize -d $archive_data | grep 'data'
    CHECK_RESULT $?
    pmlogsize -r $archive_data | grep 'dups'
    CHECK_RESULT $?
    pmlogsize -v $archive_data | grep 'PMID'
    CHECK_RESULT $?
    pmlogsize -x 60 $archive_data | grep 'index'
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
