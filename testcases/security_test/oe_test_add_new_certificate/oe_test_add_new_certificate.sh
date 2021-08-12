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
# @Desc      :   Add new certificate
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function run_test() {
    LOG_INFO "Start executing testcase."
    pem_file_path=$(find / -name *.pem | tail -1)
    cp "${pem_file_path}" /usr/share/pki/ca-trust-source/anchors/
    CHECK_RESULT $? 0 0 "cp failed"
    update-ca-trust
    CHECK_RESULT $? 0 0 "exec 'update-ca-trust' failed"
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    pem_file=${pem_file_path##*/}
    rm -rf /usr/share/pki/ca-trust-source/anchors/"${pem_file}"
    update-ca-trust
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
