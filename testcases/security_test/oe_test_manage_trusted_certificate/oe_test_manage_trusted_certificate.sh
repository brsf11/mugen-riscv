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
# @Author    :   huyahui
# @Contact   :   huyahui8@163.com
# @Modify    :   yang_lijin@qq.com
# @Date      :   2021/08/10
# @License   :   Mulan PSL v2
# @Desc      :   Manage trusted system certificates
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function run_test() {
    LOG_INFO "Start executing testcase."
    trust --help
    CHECK_RESULT $? 0 0 "exec 'trust --help' failed"
    trust list
    CHECK_RESULT $? 0 0 "exec 'trust list' failed"
    old_kit=$(ls /etc/pki/ca-trust/source/*kit | wc -l)
    trust anchor /etc/pki/tls/certs/ca-bundle.trust.crt
    new_kit=$(ls /etc/pki/ca-trust/source/*kit | wc -l)
    test $new_kit -gt $old_kit
    CHECK_RESULT $? 0 0 "exec 'trust anchor /etc/pki/tls/certs/ca-bundle.trust.crt' failed"
    trust anchor --remove /etc/pki/tls/certs/ca-bundle.trust.crt
    new_kit2=$(ls /etc/pki/ca-trust/source/*kit | wc -l)
    test $new_kit2 -lt $new_kit
    CHECK_RESULT $? 0 0 "exec 'trust anchor --remove /etc/pki/tls/certs/ca-bundle.trust.crt' failed"
    LOG_INFO "Finish testcase execution."
}

main "$@"
