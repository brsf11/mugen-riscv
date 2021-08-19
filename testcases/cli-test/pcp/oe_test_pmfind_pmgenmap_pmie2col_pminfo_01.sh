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
#@Date          :   2020-10-15
#@License       :   Mulan PSL v2
#@Desc          :   pcp testing(pmfind,pmgenmap,pmie2col,pminfo)
#####################################

source "common/common_pcp.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    archive_data=$(pcp -h "$host_name" | grep 'primary logger:' | awk -F: '{print $NF}')
    metric_name=disk.dev.write
    cat >mo.txt <<EOF
    mystats {
    kernel.percpu.cpu.idle     IDLE
    kernel.percpu.cpu.sys      SYS
    kernel.percpu.cpu.user     USER
    hinv.ncpu                  NCPU
}
EOF
    cat >config <<EOF
    loadav = kernel.all.load #'1 minute';
    '%usr' = kernel.all.cpu.user;
    '%sys' = kernel.all.cpu.sys;
    '%wio' = kernel.all.cpu.wait.total;
    '%idle' = kernel.all.cpu.idle;
    'max-iops' = max_inst(disk.dev.total);
EOF
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    pmfind --version 2>&1 | grep "$pcp_version"
    CHECK_RESULT $?
    pmgenmap mo.txt | grep 'char'
    CHECK_RESULT $?
    timeout 30 pmie -v -t 3 <config | pmie2col -w 8 -p 2 -d '*'
    CHECK_RESULT $?
    pminfo --version 2>&1 | grep "$pcp_version"
    CHECK_RESULT $?
    pminfo -a $archive_data $metric_name | grep "$metric_name"
    CHECK_RESULT $?
    pminfo -h $host_name | grep "$metric_name"
    CHECK_RESULT $?
    pminfo --container=busybox vfs.inodes.count | grep 'vfs.inodes.count'
    CHECK_RESULT $?
    pminfo -L $metric_name | grep "$metric_name"
    CHECK_RESULT $?
    pminfo -K del,60 $metric_name | grep "$metric_name"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -f mo.txt config
    LOG_INFO "End to restore the test environment."
}

main "$@"
