#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author    	:   @meitingli
#@Contact   	:   244349477@qq.com
#@Date      	:   2020-11-30
#@License   	:   Mulan PSL v2
#@Desc      	:   Take the test touch file without inode
#####################################

source ../common_lib/fsio_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the database config."
    cur_date=$(date +%Y%m%d%H%M%S)
    normal="normal"$cur_date
    useradd $normal
    echo $normal | passwd --stdin $normal
    cp /home/$normal/.bashrc /home/$normal/.bashrc.bak
    LOG_INFO "Finish to prepare the database config."
}

function run_test() {
    LOG_INFO "Start to run test."
    su $normal <<EOF
        echo "alias add='touch'" >>/home/$normal/.bashrc
        source /home/$normal/.bashrc
        alias | grep "alias add='touch'"
EOF
    CHECK_RESULT $? 0 0 "Add alias or create file failed."
    su $normal <<EOF
        sed -i "s/touch/mv/g" /home/$normal/.bashrc
        source /home/$normal/.bashrc
        alias | grep "alias add='mv'"
EOF
    CHECK_RESULT $? 0 0 "Modify alias or mv file failed."
    su $normal <<EOF
        mv /home/$normal/.bashrc.bak /home/$normal/.bashrc
        source /home/$normal/.bashrc
        alias | grep "alias add='mv'"
EOF
    CHECK_RESULT $? 1 0 "Remove alias failed."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    userdel -r $normal
    LOG_INFO "End to restore the test environment."
}

main "$@"

