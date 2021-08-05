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
#@Author    	:   guochenyang
#@Contact   	:   377012421@qq.com
#@Date      	:   2020-10-10 09:30:43
#@License   	:   Mulan PSL v2
#@Desc      	:   verification opencc‘s command
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL opencc
    result="sim_chinese55.txt not found or not accessible."
    LOG_INFO "End to prepare the test environment."
}
function run_test() {
    LOG_INFO "Start to run test."
    CHECK_RESULT "$(ls /usr/share/opencc | grep -cE 'hk2s|s2hk|s2t|s2tw|s2twp|t2hk|t2s|t2tw|tw2s|tw2sp')" 10
    echo "测试工程师"　 >./sim_chinese.txt
    opencc -i sim_chinese.txt -o ./sim_chinese_zh.txt -c s2t.json
    CHECK_RESULT "$(grep -cE '測試工程師' ./sim_chinese_zh.txt)" 1
    opencc -i sim_chinese_zh.txt -o sim_chinese1.txt -c t2s.json
    CHECK_RESULT "$(grep -cE '测试工程师' ./sim_chinese1.txt)" 1
    echo "毕竟"　 >./sim_chinese.txt
    opencc -i ./sim_chinese.txt -o ./sim_chinese_zhw.txt -c s2tw.json
    CHECK_RESULT "$(grep -cE '畢竟' ./sim_chinese_zhw.txt)" 1
    opencc -i ./sim_chinese.txt -o ./sim_chinese_zhhk.txt -c s2hk.json
    CHECK_RESULT "$(grep -cE '畢竟' ./sim_chinese_zhhk.txt)" 1
    opencc -i .sim_chinese.txt -o .sim_chinese_zh.txt -c s2t.json
    CHECK_RESULT $?
    CHECK_RESULT "$(ls | grep -cE "sim_chinese55.txt")" 0
    CHECK_RESULT "$(opencc -i sim_chinese55.txt -o sim_chinese_zhｗ.txt -c s2tw.json)" $result
    echo "123456"　 >./sim_chinese.txt
    opencc -i ./sim_chinese.txt -o ./sim_chinese_zh1.txt -c s2t.json
    CHECK_RESULT $?
    grep "123456" ./sim_chinese_zh1.txt
    CHECK_RESULT $?
    echo "abcd"　 >./sim_chinese.txt
    opencc -i ./sim_chinese.txt -o ./sim_chinese_zh2.txt -c s2t.json
    CHECK_RESULT $?
    grep "abcd" ./sim_chinese_zh2.txt
    CHECK_RESULT $?
    echo "$%^"　 >./sim_chinese.txt
    opencc -i ./sim_chinese.txt -o ./sim_chinese_zh3.txt -c s2t.json
    CHECK_RESULT $?
    grep "$%^" ./sim_chinese_zh3.txt
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf ./sim_*
    LOG_INFO "End to restore the test environment."
}
main "$@"
