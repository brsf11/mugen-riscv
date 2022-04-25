#!/user/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
# @Author    	:   ye mengfei
# @Contact   	:   mengfei@isrc.iscas.ac.cn
# @Date      	:   2022-4-26
# @License   	:   Mulan PSL v2
# @Desc      	:   the test of pps-tools package
####################################

####################################
# * how to create the pps device
#       input file: pps-ktimer.c和Makefile
#       build module: make
#       load module: insmod /root/pps_client/pps-ktimer.ko
# * /usr/bin/ppsfind
#       ppsfind ktimer
# * /usr/bin/ppstest
#       ppstest /dev/pps0
# * /usr/bin/ppsldisc
#       it will pause(): ppsldisc /dev/ttyS0
# * /usr/bin/ppswatch
#       ppswatch [-a | -c] <ppsdev>
# * /usr/bin/ppsctl
#       ppsctl [-bBfFac] <ppsdev>
####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "pps-tools kernel-source"
    CRTDIR=$(
        cd "$(dirname $0)" || exit 1
        pwd
    )
    mkdir pps_client
    cd ./pps_client
    cp $(find / -name pps-ktimer.c) pps-ktimer1.c
    cp pps-ktimer1.c pps-ktimer2.c
    sed -i 's/PPS_CAPTUREASSERT/PPS_CAPTURECLEAR/g' pps-ktimer2.c
    sed -i 's/PPS_OFFSETASSERT/PPS_OFFSETCLEAR/g' pps-ktimer2.c
    echo 'obj-m+=pps-ktimer1.o
obj-m+=pps-ktimer2.o

all:
	make -C /lib/modules/$(shell uname -r)/build M=`pwd` modules' >Makefile
    make
    insmod pps-ktimer1.ko
    insmod pps-ktimer2.ko 
    cd $CRTDIR
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    # 1. ppsfind
    ppsfind ktimer | grep "pps[0-9]:.*name=ktimer path="
    CHECK_RESULT $? 0 0 "ppsfind command failed"

    # 2. ppstest
    ppstest /dev/pps0 >ppstest_log.txt 2>&1 &
    SLEEP_WAIT 3
    grep "source.* - assert.*, sequence:.* - clear.*" ppstest_log.txt
    CHECK_RESULT $? 0 0 "ppstest command failed"
    pkill -9 ppstest

    # 3. ppsldisc
    ppsldisc /dev/ttyS0 &
    SLEEP_WAIT 3
    test -d /sys/devices/virtual/pps/pps2
    CHECK_RESULT $? 0 0 "ppsldisc command failed"
    pkill -9 ppsldisc

    # 4. ppswatch
    ppswatch -a /dev/pps0 >ppswatch_log1.txt 2>&1 &
    SLEEP_WAIT 3
    grep "timestamp:.*, sequence:.*, offset:.*" ppswatch_log1.txt
    CHECK_RESULT $? 0 0 "ppswatch -a command failed"
    pkill -9 ppswatch

    ppswatch -c /dev/pps1 >ppswatch_log2.txt 2>&1 &
    SLEEP_WAIT 3
    grep "timestamp:.*, sequence:.*, offset:.*" ppswatch_log2.txt
    CHECK_RESULT $? 0 0 "ppswatch -c command failed"
    pkill -9 ppswatch

    # 5. ppsctl
    ppsctl -fa /dev/pps0
    CHECK_RESULT $? 0 0 "ppswatch -fa command failed"

    ppsctl -Fa /dev/pps0
    CHECK_RESULT $? 0 0 "ppswatch -Fa command failed"

    ppsctl -fc /dev/pps0
    CHECK_RESULT $? 0 0 "ppswatch -fc command failed"

    ppsctl -Fc /dev/pps0
    CHECK_RESULT $? 0 0 "ppswatch -Fc command failed"

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rmmod pps-ktimer1 pps-ktimer2
    rm -rf pps_client ppstest_log* ppswatch_log*
    LOG_INFO "End to restore the test environment."
}

main "$@"
