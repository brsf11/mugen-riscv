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
# @Author    :   huyahui
# @Contact   :   huyahui8@163.com
# @modify    :   wangxiaoya@qq.com
# @Date      :   2022/05/07
# @License   :   Mulan PSL v2
# @Desc      :   Overwrite previous rules
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function run_test() {
    LOG_INFO "Start executing testcase."
    setcap cap_dac_override=eip /usr/bin/less
    CHECK_RESULT $? 0 0 "Failed to set cap"
    getcap /usr/bin/less | grep "/usr/bin/less" | grep "cap_dac_override.eip"
    CHECK_RESULT $? 0 0 "Failed to get cap"
    setcap cap_dac_read_search=eip /usr/bin/less
    CHECK_RESULT $? 0 0 "Failed to set cap"
    getcap /usr/bin/less | grep "/usr/bin/less" | grep "cap_dac_read_search.eip"
    CHECK_RESULT $? 0 0 "Failed to get cap"
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    setcap -r /usr/bin/less
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
