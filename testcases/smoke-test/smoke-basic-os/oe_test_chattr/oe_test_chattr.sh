#!/usr/bin/bash
  
# Copyright (c) 2021 Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   wangpeng
# @Contact   :   wangpengb@uniontech.com
# @Date      :   2021-09-07
# @License   :   Mulan PSL v2
# @Desc      :   File system common command test-chattr
# ############################################
source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test(){
    LOG_INFO "Start environment preparation."
    touch ./test.txt
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    chattr +i ./test.txt
    lsattr ./test.txt | grep '\-i\-'
    CHECK_RESULT $? 0 0 "lsattr failed"
    rm ./test.txt
    CHECK_RESULT $? 1 0 "rm success"
    mv ./test.txt ./test1.txt
    CHECK_RESULT $? 1 0 "mv success"
    LOG_INFO "Finish test!"
}

function post_test(){
    LOG_INFO "start environment cleanup."
    chattr -i test.txt
    rm -f ./test.txt
    LOG_INFO "Finish environment cleanup!"

}
main $@
