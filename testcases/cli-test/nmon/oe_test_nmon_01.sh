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
#@Author    	:   zhangjujie2
#@Contact   	:   zhangjujie43@gmail.com
#@Date      	:   2022/08/04
#@License   	:   Mulan PSL v2
#@Desc      	:   Take the test for nmon
#####################################

source "./common/common.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL "nmon gcc ncurses-devel nfs-utils rpmdevtools rpmlint openeuler-lsb"
    env_pre
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start to run test."
    nmon -f && test -f *.nmon
    CHECK_RESULT $? 0 0 "Failed option: -f"
    rm -rf *.nmon
    nmon -F example.nmon && test -f example.nmon
    CHECK_RESULT $? 0 0 "Failed option: -F"
    rm -rf example.nmon
    ./nmon_openEuler -fa
    SLEEP_WAIT 10
    grep 'GPU' *.nmon
    CHECK_RESULT $? 0 0 "Failed option: -a"
    rm -rf *.nmon
    nmon -f -c 1 && grep 'snapshots,1' *.nmon
    CHECK_RESULT $? 0 0 "Failed option: -c"
    rm -rf *.nmon
    nmon -f -d 512 && grep 'max_disks,512' *.nmon
    CHECK_RESULT $? 0 0 "Failed option: -d"
    rm -rf *.nmon
    nmon -f -g auto -D
    SLEEP_WAIT 2
    grep -E 'SERV|WAIT|DGINFLIGHT' *.nmon
    CHECK_RESULT $? 0 0 "Failed option: -D"
    rm -rf *.nmon
    nmon -f -g auto
    SLEEP_WAIT 1
    grep -E 'DG|BBBG' *.nmon
    CHECK_RESULT $? 0 0 "Failed option: -g auto"
    rm -rf *.nmon auto
    echo "userDefineDisk $(lsblk -l | grep disk | awk '{print $1}')" >./template/uddg
    nmon -f -g ./template/uddg
    SLEEP_WAIT 1
    grep -E 'DG|BBBG|userDefineDisk' *.nmon
    CHECK_RESULT $? 0 0 "Failed option: -g"
    rm -rf *.nmon
    nmon -h 2>&1 | grep "Options"
    CHECK_RESULT $? 0 0 "Failed option: -h"
    nmon -fJ && grep 'JFS' *.nmon
    CHECK_RESULT $? 0 1 "Failed option: -J"
    rm -rf *.nmon
    nmon -f -l 200 && grep 'disks_per_line,200' *.nmon
    CHECK_RESULT $? 0 0 "Failed option: -l"
    rm -rf *.nmon
    nmon -f -m ./template/ && test -f ./template/*.nmon
    CHECK_RESULT $? 0 0 "Failed option: -m"
    rm -rf ./template/*.nmon
    nmon -fM
    SLEEP_WAIT 2
    grep 'MHZ' *.nmon
    CHECK_RESULT $? 0 0 "Failed option: -M"
    rm -rf *.nmon
    nmon -fN
    SLEEP_WAIT 7
    grep -E 'NFSSVRV2|NFSSVRV3|NFSSVRV4' *.nmon
    CHECK_RESULT $? 0 0 "Failed option: -N"
    rm -rf *.nmon
    nmon -fp >./template/nmonPID
    if [ "$(cat ./template/nmonPID)" -eq "$(pgrep -f "nmon -fp")" ]; then
        touch ./template/equal
    fi
    test -f ./template/equal
    CHECK_RESULT $? 0 0 "Failed option: -p"
    rm -rf ./template/nmonPID ./template/equal *.nmon
    nmon -f -r exampleRunname && grep 'runname,exampleRunname' *.nmon
    CHECK_RESULT $? 0 0 "Failed option: -r"
    rm -rf *.nmon
    nmon -fR
    SLEEP_WAIT 10
    grep 'rrdtool' *.nmon
    CHECK_RESULT $? 0 0 "Failed option: -R"
    rm -rf *.nmon
    nmon -f -s 5 && grep 'interval,5' *.nmon
    CHECK_RESULT $? 0 0 "Failed option: -s"
    rm -rf *.nmon
    nmon -ft
    SLEEP_WAIT 1
    grep 'TOP' *.nmon
    CHECK_RESULT $? 0 0 "Failed option: -t"
    rm -rf *.nmon
    nmon -fT -c 5 -s 1
    SLEEP_WAIT 8
    grep 'UARG' *.nmon
    CHECK_RESULT $? 0 0 "Failed option: -T"
    rm -rf *.nmon
    nmon -fU
    SLEEP_WAIT 8
    grep 'CPUUTIL' *.nmon
    CHECK_RESULT $? 0 0 "Failed option: -U"
    rm -rf *.nmon
    nmon -V 2>&1 | grep 'version'
    CHECK_RESULT $? 0 0 "Failed option: -V"
    nmon -? 2>&1 | grep "Options"
    CHECK_RESULT $? 0 0 "Failed option: -?"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start restore the test environment."
    env_post
    kill -USR2 $(pgrep -w nmon) $(pgrep nmon_openEuler)
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"

