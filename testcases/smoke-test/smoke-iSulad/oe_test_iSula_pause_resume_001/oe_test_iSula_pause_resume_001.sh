#!/usr/bin/bash
#copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Casename  :   oe_test_iSula_pause_resume_001
# @Author    :   duanxuemin
# @Contact   :   duanxuemin@163.com
# @Date      :   2020-06-09
# @License   :   Mulan PSL v2
# @Desc      :   Pause and resume container / query isula information
# ############################################

source ../common/prepare_isulad.sh
function pre_test() {
    LOG_INFO "Start environment preparation."
    pre_isulad_env
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    isula run -itd ${Images_name}
    CHECK_RESULT $?  
    container_name=$(isula ps -a | grep ${Images_name} | awk '{print$NF}')
    isula inspect -f {{.State.Status}} ${container_name} | grep running
    CHECK_RESULT $?

    isula pause ${container_name}
    CHECK_RESULT $?
    isula inspect -f {{.State.Status}} ${container_name} | grep paused
    CHECK_RESULT $?

    isula unpause ${container_name}
    CHECK_RESULT $?
    isula inspect -f {{.State.Status}} ${container_name} | grep running
    CHECK_RESULT $?

    isula version | grep -i version
    CHECK_RESULT $?

    isula info | grep "/var/lib/isula"
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    clean_isulad_env
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup."
}

main $@
