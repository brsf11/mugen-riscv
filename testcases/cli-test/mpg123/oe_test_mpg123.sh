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
#@Author        :   lemonslice
#@Contact       :   lemonslice@foxmail.com
#@Date          :   2021-05-30 09:39:43
#@License       :   Mulan PSL v2
#@Version       :   1.0
#@Desc          :   mpg123 is a audio player/decoder
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test()
{
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL mpg123
    LOG_INFO "End to prepare the test environment."
}

function run_test()
{
    LOG_INFO "Start to run test."
    mpg123 mess.mp3 2>&1 | grep "Decoding of mess.mp3 finished."
    CHECK_RESULT $? 0 0 "mpg123 player failed"
    mpg123 -v mess.mp3 2>&1 | grep "Decoding of mess.mp3 finished."
    CHECK_RESULT $? 0 0 "mpg123 player verbosity failed"
    mpg123 -q mess.mp3
    CHECK_RESULT $? 0 0 "mpg123 player quiet failed"
    mpg123 -w mess.wav mess.mp3
    ls mess.wav | grep mess.wav
    CHECK_RESULT $? 0 0 "convert mp3 to wav failed"
    mpg123-id3dump -n mess.mp3 2>&1 | grep "APIC type(6, media) mime(image/jpeg) size(19726)"
    CHECK_RESULT $? 0 0 "dump ID3 meta failed"
    mpg123-id3dump -p mess.mp3 | grep "writing mess.mp3.media.jpeg"
    CHECK_RESULT $? 0 0 "writing jpeg failed"
    LOG_INFO "End to run test."
}

function post_test()
{
    LOG_INFO "Start to restore the test environment."
    rm -rf mess.wav mess.mp3.media.jpeg
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
