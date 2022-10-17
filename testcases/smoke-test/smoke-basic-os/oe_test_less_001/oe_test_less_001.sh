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
# @Date      :   2022-08-02
# @License   :   Mulan PSL v2
# @Desc      :   smoke basic os test-less
# ############################################
source "$OET_PATH/libs/locallibs/common_lib.sh"


function run_test() {
    LOG_INFO "Start testing..."
    less --help > /dev/null 2>&1
    CHECK_RESULT $? 0 0 "less not install"
    command -v less | grep "/usr/bin/less"
    CHECK_RESULT $? 0 0 "check version failed"
    LOG_INFO "Finish test!"
}


main $@
