#!/usr/bin/bash

# Copyright (c) 2022 Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   chengweibin
# @Contact   :   chengweibin@uniontech.com
# @Date      :   2022-10-28
# @License   :   Mulan PSL v2
# @Desc      :   Command test  sos
# ############################################
source "$OET_PATH/libs/locallibs/common_lib.sh"


function pre_test(){
    LOG_INFO "Start environment preparation."
    DNF_INSTALL "sos"
    rm -rf /var/tmp/*.tar.xz
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    sosreport -l
    CHECK_RESULT $? 0 0 "sosreport -l failed"
    sosreport -l | grep plugins
    CHECK_RESULT $? 0 0 "sosreport -l | grep plugins failed"
expect <<EOF
        set timeout 600
        spawn sosreport
        expect {
            "\退\出" {
                send "\\r"
            }
        }
        expect {
            "]:" {
                send "2021\\r"
            }
        }
expect eof
EOF
    test -f /var/tmp/sosreport-*.tar.xz
    CHECK_RESULT $? 0 0 "compression failed"
    xz -d /var/tmp/*.tar.xz
    CHECK_RESULT $? 0 0 "xz -d /var/tmp/*.tar.xz failed"
    LOG_INFO "Finish test!"
}
function post_test(){
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main $@

