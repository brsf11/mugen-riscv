#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author    	:   Li, Meiting
#@Contact   	:   244349477@qq.com
#@Date      	:   2021-01-18
#@License   	:   Mulan PSL v2
#@Desc      	:   Inject inode full on specified fs
#####################################

function inject_full_inode() {
    test_dir=$1
    mkdir $test_dir/testSpace
    i=0
    while [[ "$?" == "0" ]]; do
        i=$((i + 1))
        touch $test_dir/testSpace/testsFile$i
    done
}

function inject_full_inode_clean() {
    test_dir=$1
    rm -rf $test_dir/testSpace
}
