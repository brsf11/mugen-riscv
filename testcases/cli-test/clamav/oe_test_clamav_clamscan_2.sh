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
#@Author    	:   meitingli
#@Contact   	:   244349477@qq.com
#@Date      	:   2021-08-03
#@License   	:   Mulan PSL v2
#@Desc      	:   Take the test clamscan
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the database config."

    DNF_INSTALL clamav
    mkdir test_virus_collection
    echo "test1" >test_virus_collection/testfile1
    echo "test2" >test_virus_collection/testfile2
    cp /var/lib/clamav/main.cvd test_virus_collection/

    LOG_INFO "End to prepare the database config."
}

function run_test() {
    LOG_INFO "Start to run test."

    clamscan --alert-macros=no >/dev/null
    CHECK_RESULT $? 0 0 "Check clamscan --alert-macros=no failed."
    clamscan --max-scansize=40 >/dev/null
    CHECK_RESULT $? 0 0 "Check clamscan --max-scansize=40 failed."
    clamscan --exclude=REGEX >/dev/null
    CHECK_RESULT $? 0 0 "Check clamscan --exclude=REGEX failed."
    clamscan --exclude-pua=CAT >/dev/null
    CHECK_RESULT $? 0 0 "Check clamscan --exclude-pua=CAT failed."
    clamscan --pcre-max-filesize=50 >/dev/null
    CHECK_RESULT $? 0 0 "Check clamscan --pcre-max-filesize=50 failed."
    clamscan -r --bell -i >/dev/null
    CHECK_RESULT $? 0 0 "Check clamscan --bell -i failed."
    clamscan -i --remove --recursive /opt --max-dir-recursion=5 -l test_clamscan.log >/dev/null
    CHECK_RESULT $? 0 0 "Check clamscan -i --remove --recursive /opt --max-dir-recursion=5 -l test_clamscan.log failed."
    clamscan --no-summary -ri /opt >/dev/null
    CHECK_RESULT $? 0 0 "Check clamscan --no-summary -ri /opt failed."
    clamscan -r --move=test_virus_collection/ /opt/ >/dev/null
    CHECK_RESULT $? 0 0 "Check clamscan  -r --move=test_virus_collection/ /opt/ failed."
    clamscan -r --copy=test_virus_collection/ /opt/ >/dev/null
    CHECK_RESULT $? 0 0 "Check clamscan  -r --copy=test_virus_collection/ /opt/ failed."
    clamscan --max-dir-recursion=5 >/dev/null
    CHECK_RESULT $? 0 0 "Check clamscan --max-dir-recursion=5 failed."

    clamscan --official-db-only >/dev/null
    CHECK_RESULT $? 0 0 "Check clamscan --official-db-only failed."
    clamscan --log test_log.log >/dev/null
    CHECK_RESULT $? 0 0 "Check clamscan --log test_log.log failed."
    clamscan --alert-exceeds-max /opt >/dev/null
    CHECK_RESULT $? 0 0 "Check clamscan --alert-exceeds-max failed."
    clamscan --max-recursion 1024 --max-dir-recursion 10 --max-embeddedpe 10 --max-htmlnormalize 10 >/dev/null
    CHECK_RESULT $? 0 0 "Check clamscan --max-recursion 1024 --max-dir-recursion 10 --max-embeddedpe 10 --max-htmlnormalize 10 failed."
    clamscan --allmatch test_virus_collection --include=REGEX --include-dir=REGEX --max-htmlnotags 5 --max-scriptnormalize 5 >/dev/null
    CHECK_RESULT $? 0 0 "Check clamscan --allmatch test_virus_collection --include=REGEX --include-dir=REGEX --max-htmlnotags 5 --max-scriptnormalize 5 failed."
    clamscan -z test_virus_collection --cross-fs /opt --max-filesize 1024 --max-ziptypercg 5 >/dev/null
    CHECK_RESULT $? 0 0 "Check clamscan -z test_virus_collection --cross-fs /opt --max-filesize 1024 --max-ziptypercg 5 failed."
    clamscan --follow-dir-symlinks 0 --max-scansize 1024 >/dev/null
    CHECK_RESULT $? 0 0 "Check clamscan --follow-dir-symlinks 0 --max-scansize 1024 failed."
    clamscan --follow-file-symlinks 0 --max-files 1024 --max-ziptypercg 5 >/dev/null
    CHECK_RESULT $? 0 0 "Check clamscan --follow-file-symlinks 0 --max-files 1024 --max-ziptypercg 5 failed."
    clamscan --file-list /opt --exclude-dir=REGEX --max-partitions 5 --max-iconspe 5 >/dev/null
    CHECK_RESULT $? 0 0 "Check clamscan --file-list /opt --exclude-dir=REGEX --max-partitions 5 --max-iconspe 5 failed."

    clamscan --bytecode test_virus_collection --bytecode-timeout 50 --max-rechwp3 5 >/dev/null
    CHECK_RESULT $? 0 0 "Check clamscan --bytecode test_virus_collection --bytecode-timeout 50 --max-rechwp3 5 failed."
    clamscan --bytecode-unsigned test_virus_collection --statistics bytecode --pcre-match-limit 5 >/dev/null
    CHECK_RESULT $? 0 0 "Check clamscan --bytecode-unsigned test_virus_collection --statistics bytecode --pcre-match-limit 5 failed."
    clamscan --detect-pua test_virus_collection --pcre-recmatch-limit 5 --phishing-sigs test_virus_collection --statistics pcre >/dev/null
    CHECK_RESULT $? 0 0 "Check clamscan --detect-pua test_virus_collection  --pcre-recmatch-limit 5 --phishing-sigs test_virus_collection --statistics pcre failed."
    clamscan --include-pua=CAT --detect-structured test_virus_collection --structured-ssn-format=2 --pcre-max-filesize 5 --statistics none >/dev/null
    CHECK_RESULT $? 0 0 "Check clamscan --include-pua=CAT --detect-structured test_virus_collection --structured-ssn-format=2 --pcre-max-filesize 5 --statistics none failed."
    clamscan --structured-ssn-count 1 --structured-cc-count 1 --scan-mail test_virus_collection --disable-cache >/dev/null
    CHECK_RESULT $? 0 0 "Check clamscan --structured-ssn-count 1 --structured-cc-count 1 --scan-mail test_virus_collection --disable-cache failed."

    clamscan --phishing-scan-urls test_virus_collection --heuristic-alerts test_virus_collection --heuristic-scan-precedence test_virus_collection >/dev/null
    CHECK_RESULT $? 0 0 "Check clamscan --phishing-scan-urls test_virus_collection --heuristic-alerts test_virus_collection --heuristic-scan-precedence test_virus_collection failed."
    clamscan --normalize test_virus_collection --scan-pe test_virus_collection --alert-encrypted-doc test_virus_collection --alert-macros test_virus_collection
    CHECK_RESULT $? 0 0 "Check clamscan --normalize test_virus_collection --scan-pe test_virus_collection --alert-encrypted-doc test_virus_collection --alert-macros test_virus_collection failed."
    clamscan --alert-phishing-ssl test_virus_collection --alert-phishing-cloak test_virus_collection --alert-partition-intersection test_virus_collection --nocerts --dumpcerts --max-scantime 100 >/dev/null
    CHECK_RESULT $? 0 0 "Check clamscan --alert-phishing-ssl test_virus_collection --alert-phishing-cloak test_virus_collection --alert-partition-intersection test_virus_collection --nocerts --dumpcerts --max-scantime 100 failed."

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    rm -rf test_clamscan.log test_virus_collection test_log.log
    DNF_REMOVE

    LOG_INFO "End to restore the test environment."
}

main "$@"
