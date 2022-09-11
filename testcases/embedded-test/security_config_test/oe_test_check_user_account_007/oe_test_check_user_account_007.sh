#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   saarloos
# @Contact   :   9090-90-90-9090@163.com
# @Modify    :   9090-90-90-9090@163.com
# @Date      :   2022/04/25
# @License   :   Mulan PSL v2
# @Desc      :   check set TMOUT value
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function run_test()
{
    LOG_INFO "Start to run test."

    egrep "^\s*(export\s+)?TMOUT=" /etc/profile
    CHECK_RESULT $? 0 0 "not set TMOUT in /etc/profile"

    getValue=$(egrep "^\s*(export\s+)?TMOUT=" /etc/profile | awk -F '=' '{print $2}')
    test $getValue -eq 0
    CHECK_RESULT $? 0 1 "set TMOUT is 0"

    bashrcFile="/etc/bashrc"
    if [ ! -e ${bashrcFile} ]; then 
        bashrcFile="/etc/skel/.bashrc"
    fi

    egrep "^\s*(export\s+)?TMOUT=" ${bashrcFile}
    CHECK_RESULT $? 0 0 "not set TMOUT in ${bashrcFile}"

    getValue=$(egrep "^\s*(export\s+)?TMOUT=" ${bashrcFile} | awk -F '=' '{print $2}')
    test $getValue -eq 0
    CHECK_RESULT $? 0 1 "set TMOUT is 0"

    LOG_INFO "End to run test."
}

main "$@"
