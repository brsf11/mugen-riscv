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
# @Date      :   2021/12/31
# @License   :   Mulan PSL v2
# @Desc      :   View ACL rules for newly created files
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function pre_test() {
    LOG_INFO "Start environmental preparation."
    local_umask=$(umask)
    umask | grep 0022 || umask 0022
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    touch /tmp/my_pwd
    ls -l /tmp/my_pwd | grep '\-rw\-r\-\-r\-\-.'
    getfacl /tmp/my_pwd >tmp_log
    echo '# file: tmp/my_pwd
# owner: root
# group: root
user::rw-
group::r--
other::r--
' >diff_file
    diff tmp_log diff_file
    CHECK_RESULT  $? 0 0 "Comparison between tmp_log and diff_file failed"
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf tmp_log diff_file /tmp/my_pwd
    umask $local_umask
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
