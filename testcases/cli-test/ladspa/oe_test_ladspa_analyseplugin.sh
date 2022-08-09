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
#@Desc      	:   Test analyseplugin
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test()
{
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL 'ladspa'
    LOG_INFO "End to prepare the test environment."
}

function run_test()
{
    LOG_INFO "Start to run test."
    analyseplugin -h 2>&1 | grep 'Usage:[[:space:]]analyseplugin'
    CHECK_RESULT $? 0 0 "check -h failed"
    analyseplugin -l amp.so | grep -Poz 'amp_mono.*[[:digit:]].*Mono Amplifier\namp_stereo.*[[:digit:]].*Stereo Amplifier\n'
    CHECK_RESULT $? 0 0 "check -l failed"
    analyseplugin amp.so | grep -E '^(Plugin Name|Plugin Label|Plugin Unique ID|Maker|Copyright)'
    CHECK_RESULT $? 0 0 "check plugin file failed"
    analyseplugin amp.so amp_mono | grep 'Plugin Label: "amp_mono"'
    CHECK_RESULT $? 0 0 "check plugin label amp_mono failed"
    analyseplugin amp.so amp_stereo | grep 'Plugin Label: "amp_stereo"'
    CHECK_RESULT $? 0 0 "check plugin label amp_stereo failed"
    LOG_INFO "End to run test."
}

function post_test()
{
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"