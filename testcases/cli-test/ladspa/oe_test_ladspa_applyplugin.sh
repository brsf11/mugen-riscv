#!/usr/bin/bash

# Copyright (c) 2020. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author    	:   songliying
#@Contact   	:   liying@isrc.iscas.ac.cn
#@Date      	:   2022-07-11
#@License   	:   Mulan PSL v2
#@Version   	:   1.0
#@Desc      	:   Test applyplugin and listplugins
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test()
{
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL 'ladspa espeak-ng'
    echo hello | espeak-ng --stdin -w input.wav
    LOG_INFO "End to prepare the test environment."
}

function run_test()
{
    LOG_INFO "Start to run test."
    applyplugin input.wav output.wav amp.so amp_mono 2 | grep "Peak output: 50878"
    CHECK_RESULT $? 0 0 "applyplugin check failed"
    applyplugin input.wav output.wav delay.so delay_5s 2 0.5 filter.so hpf 440 | grep "Peak output: 9892.93"
    CHECK_RESULT $? 0 0 "applyplugin multiple parameters check failed"
    applyplugin -s 20 input.wav output.wav amp.so amp_mono 2 | grep "Peak output: 50878"
    CHECK_RESULT $? 0 0 "applyplugin -s  check failed"    
    listplugins | grep '/usr/lib64/ladspa/.*'
    CHECK_RESULT $? 0 0 "listplugins check failed" 
    LOG_INFO "End to run test."
}

function post_test()
{
    LOG_INFO "Start to restore the test environment."
    rm -rf input.wav output.wav
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"