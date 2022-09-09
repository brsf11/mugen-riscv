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
# @Author    :   geyaning
# @Contact   :   geyaning@uniontech.com
# @Date      :   2022.9.09
# @License   :   Mulan PSL v2
# @Desc      :   add test umask
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environment preparation."
    cur_lang=$(echo $LANG)
    export LANG=zh_CN.UTF-8    
    DNF_INSTALL "expect"
    useradd -d /home/euler euler
    LOG_INFO "End of environmental preparation!"

}
function run_test() {
    LOG_INFO "Start testing..."
    umask | grep 0022
    CHECK_RESULT $? 0 0 "The umask permission of the root is incorrect"
    su - euler -c "umask | grep 0022"
    CHECK_RESULT $? 0 0 "The umask permission of common users is incorrect"
    mkdir testdir && ls -ld testdir | grep 'drwxr-xr-x.'
    CHECK_RESULT $? 0 0 "The root user has incorrect permission to create a folder."
    touch testfile && ls -lh testfile | grep 'rw-r--r--.'
    CHECK_RESULT $? 0 0 "The root user has incorrect permission to create files."
    su - euler -c "mkdir testdir && ls -ld testdir | grep 'drwxr-xr-x.'"
    CHECK_RESULT $? 0 0 "Common users have incorrect permission to create folders."
    su - euler -c "touch testfile && ls -lh testfile | grep 'rw-r--r--.'"
    CHECK_RESULT $? 0 0 "The permission for common users to create files is incorrect."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    userdel -rf euler
    rm -rf testdir testfile
    DNF_REMOVE
    export LANG=$cur_lang
    LOG_INFO "Finish environment cleanup!"
}

main $@
