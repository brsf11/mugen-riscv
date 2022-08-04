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
#@Date          :   2020-11-17
#@License       :   Mulan PSL v2
#@Desc          :   Oemaker is a tool for building DVD ISO, including standard ISO, debug ISO and source ISO.
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function config_params() {
    LOG_INFO "Start to config params of the case."
    EXECUTE_T="60m"
    LOG_INFO "End to config params of the case."
}

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    OLD_LANG=$LANG
    export LANG=en_US.UTF-8
    os_name=$(grep '^NAME=' /etc/os-release | awk -F '=' '{print $NF}' | tr -d '"')
    os_version=$(grep '^VERSION_ID=' /etc/os-release | awk -F '=' '{print $NF}' | tr -d '"')
    repo_address=$(grep -i 'everything' /etc/yum.repos.d/*.repo | grep -v name | grep 'baseurl' | awk -F '=' '{print $NF}')
    if yum list | grep oemaker; then
        DNF_INSTALL oemaker
    else
        echo "Not found oemaker package in repo source."
        exit 0
    fi
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    oemaker -h | grep 'Usage'
    CHECK_RESULT $?
    oemaker -t standard -p ${os_name} -v ${os_version} -r '' -s ${repo_address}
    CHECK_RESULT $?
    test -f /result/${os_name}-${os_version}-${NODE1_FRAME}-dvd.iso
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    export LANG=${OLD_LANG}
    DNF_REMOVE
    rm -rf /result
    LOG_INFO "End to restore the test environment."
}

main "$@"
