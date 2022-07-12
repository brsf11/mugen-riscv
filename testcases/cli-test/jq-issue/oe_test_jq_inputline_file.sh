#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
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
# @Date      :   2021/02/04
# @License   :   Mulan PSL v2
# @Desc      :   Print file line number
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL jq
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    echo 'jq -n "[inputs[].data.user.videos.edges[]]|reverse|unique_by(.node.id)" f1.json f2.json | jq .[].node.lengthSeconds
jq -n "[inputs[].data.user.videos.edges[]]|sort_by(.node.viewCount)|unique_by(.node.id)" f1.json f2.json | jq .[].node.lengthSeconds
jq -n "now|strflocaltime(\"%Y-%m-%dT%H%M%S\")"' >/tmp/tlist.txt
    echo '1
2
3' >/tmp/diff_result
    jq -R input_line_number /tmp/tlist.txt >/tmp/jq_result
    CHECK_RESULT $?
    diff /tmp/diff_result /tmp/jq_result
    CHECK_RESULT $?
}
function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    rm -rf /tmp/tlist.txt /tmp/jq_result /tmp/diff_result
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
