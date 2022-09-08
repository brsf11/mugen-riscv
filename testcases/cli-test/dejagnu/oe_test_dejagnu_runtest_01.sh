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
# @Author    :   zhoulimin
# @Contact   :   limin@isrc.iscas.ac.cn 
# @Date      :   2022-09-07
# @License   :   Mulan PSL v2
# @Desc      :   The test of dejagnu package 
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function config_params(){
    LOG_INFO "Start to config params of the case."

    mailAddress1=${USER}@localhost
    anotherUser=mufiyemailuser
    mailAddress2=${anotherUser}@localhost
    LOG_INFO "End to config params of the case."
}

function pre_test() {
    LOG_INFO "Start to prepare the test environment!"
    DNF_INSTALL "dejagnu sendmail procmail mailx"
    firewall-cmd --zone=public --add-port=25/tcp
    firewall-cmd --reload
    systemctl start sendmail
    useradd ${anotherUser}
    test -d tmp || mkdir tmp
    LOG_INFO "End to prepare the test environment!"
}

function run_test() {
    LOG_INFO "Start to run test."
    runtest -V 2>&1 | grep 'DejaGnu version'
    CHECK_RESULT $? 0 0 "Failed option : -V"
    runtest --version 2>&1 | grep 'DejaGnu version'
    CHECK_RESULT $? 0 0 "Failed option : --version"
    runtest -help 2>&1 | grep "USAGE: runtest"
    CHECK_RESULT $? 0 0 "Failed option : --help"
    runtest CALC=common/calc --verbose --srcdir common --outdir tmp 2>&1 | grep "Verbose level"
    CHECK_RESULT $? 0 0 "Failed option : --verbose"
    runtest CALC=common/calc -v --srcdir common --outdir tmp 2>&1 | grep "Verbose level"
    CHECK_RESULT $? 0 0 "Failed option : -v"
    rm -rf tmp/*
    runtest CALC=common/calc --debug=tmp --srcdir common --outdir tmp
    test -f ./dbg.log
    CHECK_RESULT $? 0 0 "Failed option : --debug"
    runtest CALC=common/calc --srcdir common --outdir tmp --all 2>&1 | grep "PASS: version"
    CHECK_RESULT $? 0 0 "Failed option : --all"
    runtest CALC=common/calc --srcdir common --outdir tmp -a 2>&1 | grep "PASS: version"
    CHECK_RESULT $? 0 0 "Failed option : -a"
    rm -rf tmp/*
    runtest CALC=common/calc --srcdir common --outdir tmp --directory common
    test -f ./tmp/testrun.log
    CHECK_RESULT $? 0 0 "Failed option : --directory"
    runtest CALC=common/calc -v --ignore calc.exp --srcdir common --outdir tmp 2>&1 | grep "Ignoring test"
    CHECK_RESULT $? 0 0 "Failed option : --ignore"
    runtest CALC=common/calc --log_dialog --srcdir common --outdir tmp 2>&1 | grep "calc: add 1 2 3"
    CHECK_RESULT $? 0 0 "Failed option : --log_dialog"
    runtest CALC=common/calc -v --mail ${mailAddress1} --srcdir common --outdir tmp 
    SLEEP_WAIT 3
    grep "To: ${USER}@$(hostname)" /var/spool/mail/${USER}
    CHECK_RESULT $? 0 0 "Failed option : --mail (to one host)"
    runtest CALC=common/calc -v --mail ${mailAddress1},${mailAddress2} --srcdir common --outdir tmp 
    SLEEP_WAIT 3
    grep "To: ${anotherUser}@$(hostname), ${USER}@$(hostname)" /var/spool/mail/${USER} && grep "To: ${anotheruser}@$(hostname), ${USER}@$(hostname)" /var/spool/mail/${anotherUser}
    CHECK_RESULT $? 0 0 "Failed option : --mail (to multihost)"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    rm -rf tmp *.sum *.log /var/spool/mail/{${USER},${anotherUser}}
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
