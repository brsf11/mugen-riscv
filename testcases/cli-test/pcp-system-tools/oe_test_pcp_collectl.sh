#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
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
#@Date          :   2020-10-26
#@License       :   Mulan PSL v2
#@Desc          :   (pcp-system-tools) (pcp-collectl)
#####################################

source "common/common_pcp-system-tools.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    archive_data=$(pcp -h "$host_name" | grep 'primary logger:' | awk -F: '{print $NF}')
    OLD_PATH=$PATH
    export PATH=/usr/libexec/pcp/bin/:$PATH
    VERSION_ID=$(grep 'VERSION_ID' /etc/os-release | awk -F '"' '{print $2}')
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    if [ $VERSION_ID != "22.03" ]; then
        pcp-collectl --version 2>&1 | grep "$pcp_version"
        CHECK_RESULT $?
        pcp-collectl -a $archive_data -c 10 -i 2 | grep 'CPU'
        CHECK_RESULT $?
        pmcollectl -a $archive_data -c 10 -i 2 | grep 'CPU'
        CHECK_RESULT $?
        pcp-collectl -h $host_name -c 10 | grep 'CPU'
        CHECK_RESULT $?
        pcp-collectl -v -c 10 | grep 'RECORD'
        CHECK_RESULT $?
        pcp-collectl -f FOLIO
        CHECK_RESULT $?
        grep 'PCPFolio' FOLIO
        CHECK_RESULT $?
        pcp-collectl -p FOLIO -c 10 | grep 'CPU'
        CHECK_RESULT $?
        pcp-collectl -R 10 | grep 'CPU'
        CHECK_RESULT $?
    else
        LOG_INFO "Obsolete version command"
    fi
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -f FOLIO
    clear_env
    PATH=${OLD_PATH}
    LOG_INFO "End to restore the test environment."
}

main "$@"
