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
# @Desc      :   check password life time
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function run_test()
{
    LOG_INFO "Start to run test."

    grep ^PASS_MAX_DAYS /etc/login.defs
    CHECK_RESULT $? 0 0 "not set password PASS_MAX_DAYS"

    grep ^PASS_MIN_DAYS /etc/login.defs
    CHECK_RESULT $? 0 0 "not set password PASS_MIN_DAYS"

    grep ^PASS_WARN_AGE /etc/login.defs
    CHECK_RESULT $? 0 0 "not set password PASS_WARN_AGE"

    egrep "^\s*account\s+\[\s*success=1\s+new_authtok_reqd=done\s+default=ignore\s*\]\s+pam_unix.so" /etc/pam.d/common-account 2>/dev/null
    CHECK_RESULT $? 0 0 "check PMA fail"

    LOG_INFO "End to run test."
}

main "$@"
