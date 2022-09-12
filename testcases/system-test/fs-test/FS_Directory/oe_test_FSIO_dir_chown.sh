#!/usr/bin/bash

# Copyright (c) 2022 Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author    	:   @meitingli
#@Contact   	:   bubble_mt@outlook.com
#@Date      	:   2020-11-23
#@License   	:   Mulan PSL v2
#@Desc      	:   Take the test chown
#####################################

source ../common_lib/fsio_lib.sh

function pre_test() {
    LOG_INFO "Start environment preparation."
    cur_date=$(date +%Y%m%d%H%M%S)
    point_list=($(CREATE_FS))
    cp /etc/passwd /etc/passwd.bak
    user="test"$cur_date
    useradd $user
    echo $LOCAL_PASSWD | passwd $user --stdin
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start to run test."
    for i in $(seq 1 $((${#point_list[@]} - 1))); do
        var=${point_list[$i]}
        mkdir -p $var/tmp01$cur_date
        touch $var/tmp01$cur_date/testfile
        ls -l $var/tmp01$cur_date | tail -n 1 | awk '{print $3}' | grep "root"
        CHECK_RESULT $? 0 0 "Check dir user failed."
        ls -l $var/tmp01$cur_date | tail -n 1 | awk '{print $4}' | grep "root"
        CHECK_RESULT $? 0 0 "Check dir group failed."
        chown -R $user:$user $var/tmp01$cur_date
        CHECK_RESULT $? 0 0 "chown failed."
        ls -l $var/tmp01$cur_date | tail -n 1 | awk '{print $3}' | grep $user
        CHECK_RESULT $? 0 0 "Check user after chown failed."
        ls -l $var/tmp01$cur_date | tail -n 1 | awk '{print $4}' | grep $user
        CHECK_RESULT $? 0 0 "Check group agter chown failed."
    done
    chown --help | grep "Usage"
    CHECK_RESULT $? 0 0 "Check help failed."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    list=$(echo ${point_list[@]})
    REMOVE_FS "$list"
    userdel -r $user
    rm -rf /etc/passwd
    mv /etc/passwd.bak /etc/passwd
    LOG_INFO "End to restore the test environment."
}

main $@

