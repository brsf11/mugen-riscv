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
# @Desc      :   Directory defaulr ACL rules
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function pre_test() {
    LOG_INFO "Start environmental preparation."
    grep "^example:" /etc/passwd && userdel -rf example
    local_umask=$(umask)
    umask | grep 0022 || umask 0022
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    useradd example
    passwd example <<EOF
${NODE1_PASSWORD}
${NODE1_PASSWORD}
EOF
    mkdir -p /home/test
    setfacl -d -m u:example:w /home/test
    echo '# file: home/test
# owner: root
# group: root
user::rwx
group::r-x
other::r-x
default:user::rwx
default:user:example:-w-
default:group::r-x
default:mask::rwx
default:other::r-x
' >diff_dir_log
    getfacl /home/test >tmp_dir
    diff diff_dir_log tmp_dir
    CHECK_RESULT  $? 0 0 "Comparison between diff_file_log and tmp_file failed"
    touch /home/test/file
    echo '# file: home/test/file
# owner: root
# group: root
user::rw-
user:example:-w-
group::r-x	#effective:r--
mask::rw-
other::r--
' >diff_file_log
    getfacl /home/test/file >tmp_file
    diff diff_file_log tmp_file
    CHECK_RESULT  $? 0 0 "Comparison between diff_file_log and tmp_file failed"
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf /home/test diff_file_log diff_dir_log tmp_file tmp_dir
    userdel -rf example
    umask $local_umask
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
