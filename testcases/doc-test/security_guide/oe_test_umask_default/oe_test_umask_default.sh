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
# @Date      :   2022/6/10
# @License   :   Mulan PSL v2
# @Desc      :   User default umask value limit - enable reinforcement by default
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function pre_test() {
    LOG_INFO "Start environmental preparation."
    useradd test1
    mkdir /tmp/test_dir1
    touch /tmp/test_file1
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    umask | grep 0022
    CHECK_RESULT $? 0 0 "The default value of umask is not 0022."
    ls -l /tmp | grep 'test_dir1' | grep -e 'drwxr-xr-x'
    CHECK_RESULT $? 0 0 "The default permission of the folder is not 'drwxr-xr-x'."
    ls -l /tmp | grep 'test_file1' | grep -e '-rw-r--r--'
    CHECK_RESULT $? 0 0 "The default permission of the file is not '-rw-r--r--'."
    expect -c "
        log_file testlog1
        spawn su test1
        expect {
            \"*test1@*\" {
                send \"umask | grep 0002\\r\"
                }
            eof
        }
        expect eof {
            catch wait result
            exit [lindex \$result 3] 
        }          
        expect {
            \"*test1@*\" {
                send \"mkdir /tmp/test_dir2;touch /tmp/test_file2\\r\"
                }
        }
        expect {                              
            \"*test1@*\" {
                send \"exit\\r\"
                }
        }   
                     
    "
    ls -l /tmp | grep 'test_dir2' | grep -e 'drwxrwxr-x'
    CHECK_RESULT $? 0 0 "The permission of the folder is not 'drwxrwxr-x'."
    ls -l /tmp | grep 'test_file2' | grep -e '-rw-rw-r--'
    CHECK_RESULT $? 0 0 "The permission of the file is not '-rw-rw-r--'."

    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "Start cleanning environment."
    rm -rf testlog* /tmp/test*
    userdel -rf test1
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
