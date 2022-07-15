#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# ##################################
# @Author    :   zengcongwei
# @Contact   :   735811396@qq.com
# @Date      :   2020/5/12
# @License   :   Mulan PSL v2
# @Desc      :   Random installing a package, Test "dnf provides" command, Test "-q, --quiet" & "-R <minutes>,--randomwait=<minutes>" & "--refresh" option
# ##################################

source "common/common_dnf.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    DNF_INSTALL time
    dnf list --available | grep "arch\|x86_64" | awk '{print $1}' | awk -F . 'OFS="."{$NF="";print}' | awk '{print substr($0, 1, length($0)-1)}' >pkg_list
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    pkg_name=$(shuf -n1 pkg_list)
    dnf install -y ${pkg_name} | grep "Complete!"
    CHECK_RESULT $?
    rpm -ql ${pkg_name} >file_list
    file=$(shuf -n1 file_list)
    dnf provides ${file} | grep ${pkg_name}
    CHECK_RESULT $?
    dnf -q repoquery tree 2>&1 | grep check
    CHECK_RESULT $? 1 0
    dnf --quiet repoquery tree 2>&1 | grep check
    CHECK_RESULT $? 1 0
    /usr/bin/time -f "time-%U" -o time.log dnf -R 3 repoquery | grep "${NODE1_FRAME}"
    CHECK_RESULT $?
    ret=$(echo "$(cat time.log | awk -F - '{print $2}') < 3" | bc)
    CHECK_RESULT ${ret} 1 0
    dnf --refresh repoquery 2>&1 | grep kB
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    rm -rf pkg_list file_list time.log
    DNF_REMOVE 1 "$pkg_name time"
    LOG_INFO "End of restore the test environment."
}

main "$@"
