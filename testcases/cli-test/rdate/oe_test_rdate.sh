#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

###################################
#@Author    :   qinhaiqi
#@Contact   :   2683064908@qq.com
#@Date      :   2022/2/16
#@License   :   Mulan PSL v2
#@Desc      :   Test "rdate" command
###################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL rdate
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start to run testcase."
    for ((i = 1; i <= 10; i ++))
      do rdate -p time.nist.gov 2>&1 | grep "time.nist.gov"
      if [[ $? -eq 0 ]]; then   
         break
      else
         if [[ $i == 10 ]]; then
            CHECK_RESULT $? 0 1 "Failed option: -p"
         fi
      fi
    done    
    for ((i = 1; i <= 10; i ++))
      do rdate -s time.nist.gov
      if [[ $? -eq 0  ]]; then
         break
      else
         if [[ $i == 10 ]]; then
            CHECK_RESULT $? 0 1 "Failed option: -s"
         fi
      fi
    done
    for ((i = 1; i <= 10; i ++))
      do rdate -u time.nist.gov 2>&1 | grep "time.nist.gov"
      if [[ $? -eq 0 ]]; then
         break
      else
         if [[ $i == 10 ]];then
            CHECK_RESULT $? 0 1 "Failed option: -u"
         fi
      fi
    done
    for ((i = 1; i <= 10; i ++))
      do rdate -a time.nist.gov 2>&1 | grep "time.nist.gov"
      if [[ $? -eq 0 ]]; then
         break
      else
         if [[ $i == 10 ]];then
            CHECK_RESULT $? 0 1 "Failed option: -a"
         fi
      fi
    done
    for ((i = 1; i <= 10; i ++))
      do rdate -l time.nist.gov 2>&1 | grep "time.nist.gov"
      if [[ $? -eq 0 ]]; then
         break
      else
         if [[ $i == 10 ]];then
            CHECK_RESULT $? 0 1 "Failed option: -l"
         fi
      fi
    done
    for ((i = 1; i <= 10; i ++))
      do rdate -t 10 time.nist.gov 2>&1 | grep "time.nist.gov"
      if [[ $? -eq 0 ]]; then
         break
      else
         if [[ $i == 10 ]];then
            CHECK_RESULT $? 0 1 "Failed option: -t"
         fi
      fi
    done
    LOG_INFO "End to run testcase."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE 
    LOG_INFO "End to restore the test environment." 
}

main "$@"
