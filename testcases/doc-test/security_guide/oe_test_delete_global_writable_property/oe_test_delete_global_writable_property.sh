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
# @Author    :   yanglijin
# @Contact   :   yang_lijin@qq.com
# @Date      :   2021/7/23
# @License   :   Mulan PSL v2
# @Desc      :   Delete global writable property of unauthorized file
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function run_test() {
    LOG_INFO "Start executing testcase."
    find / -type d \( -perm -o+w \) | grep -v proc > temp
    while read line
    do
	ls -ld $line | grep 'drwxrwxrwt'
    	CHECK_RESULT $? 0 0 "check $line failed"
    done<temp
    find / -type f \( -perm -o+w \) 2>/dev/null | grep -vE 'proc|cgroup|selinux'
    CHECK_RESULT $? 0 1 "check global writable file failed"
    LOG_INFO "Finish testcase execution."
}

function post_test(){
    LOG_INFO "Start cleanning environment."
    rm -rf temp
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
