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
# @Author    :   duanxuemin
# @Contact   :   duanxuemin@163.com
# @Date      :   2020-05-26
# @License   :   Mulan PSL v2
# @Desc      :   Install JDK package
# ############################################
source ${OET_PATH}/libs/locallibs/common_lib.sh
function run_test() {
    LOG_INFO "Start executing testcase!"
    cd ~/.ssh
    CHECK_RESULT $?
    touch config
    CHECK_RESULT $?
    echo "
    Host *  
     	 	  ForwardAgent yes  
		      ForwardX11 yes
    " >>config
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

main $@
