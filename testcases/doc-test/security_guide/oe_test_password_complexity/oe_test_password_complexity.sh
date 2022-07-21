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
# @Author    :   wangxiaoya
# @Contact   :   wangxiaoya@qq.com
# @Date      :   2022/6/9
# @License   :   Mulan PSL v2
# @Desc      :   Password complexity limit - reinforcement is not enabled by default
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function pre_test() {
    LOG_INFO "Start environmental preparation."
    useradd test1
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    expect -c "
        spawn passwd test1
        expect {
            \"New password*\" {
                send \"aaa\\r\"
                }
            \"Retype password*\" {
                send \"aaa\\r\"
                }
            eof
        }       
        expect eof {
            catch wait result
            exit [lindex \$result 3] 
        }
    "
    CHECK_RESULT $? 0 0 "The password complexity is secured, but it should not be secured here."
    expect -c "
        spawn passwd test1     
        expect {
            \"New password*\" {
                send \"123456789\\r\"
                }
            \"Retype password*\" {
                send \"123456789\\r\"
                }
            eof
        }
        expect eof {
            catch wait result
            exit [lindex \$result 3] 
        }
    "
    CHECK_RESULT $? 0 0 "The password complexity is secured, but it should not be secured here."
    expect -c "
        spawn passwd test1
        expect {
            \"New password*\" {
                send \"abcdef!@#\\r\"
                }

            \"Retype password*\" {
                send \"abcdef!@#\\r\"
                }
            eof
        }
        expect eof {
            catch wait result
            exit [lindex \$result 3] 
        }
    "
    CHECK_RESULT $? 0 0 "Password setting failed."

    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "Start cleanning environment."
    userdel -rf test1
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
