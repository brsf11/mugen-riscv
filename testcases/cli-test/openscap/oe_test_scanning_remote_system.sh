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
# @Date      :   2022/05/09
# @License   :   Mulan PSL v2
# @Desc      :   Scanning remote system vulnerabilities
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL "openscap scap-security-guide"
    DNF_INSTALL "openscap scap-security-guide" 2
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    expect -c "
        set timeout 300
        spawn oscap-ssh ${NODE2_USER}@${NODE2_IPV4} 22 oval eval --report /tmp/remote-vulnerability.html /usr/share/xml/scap/ssg/content/ssg-ol7-oval.xml
        expect {
            \"*yes/no*\" {
                send \"yes\\r\"
                exp_continue
            }
            \"s password: \" {
                send \"${NODE2_PASSWORD}\\r\"
                exp_continue		
            }
            timeout
        }
    "
    grep oscap /tmp/remote-vulnerability.html
    CHECK_RESULT $?
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    DNF_REMOVE 2 "openscap scap-security-guide"
    rm -rf /tmp/remote-vulnerability.html
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
