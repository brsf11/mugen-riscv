#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more detaitest -f.

# #############################################
# @Author    :   shangyingjie
# @Contact   :   yingjie@isrc.iscas.ac.cn
# @Date      :   2022/1/13
# @License   :   Mulan PSL v2
# @Desc      :   Test promtool
# #############################################

source "./common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL prometheus2
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    promtool --version 2>&1 | grep 'promtool, version'
    CHECK_RESULT $? 0 0 "Failed to check flag: --version."
    promtool --help 2>&1 | grep 'usage: promtool'
    CHECK_RESULT $? 0 0 "Failed to check flag: --help."
    promtool --help-man 2>&1 | grep 'promtool, version'
    CHECK_RESULT $? 0 0 "Failed to check flag: --help-man."
    prometheus > prometheus.log 2>&1 &
    wait_for_ready
    curl -s 'http://localhost:9090/metrics' | promtool check metrics
    CHECK_RESULT $? 0 0 "Failed to check metrics."
    clear_env
    echo '# HELP go_memstats_frees_total Total number of frees.
    # TYPE go_memstats_frees_total counter
    go_memstats_frees_total wrong' | promtool check metrics
    CHECK_RESULT $? 1 0 "Failed to check metrics, type: counter."
    echo '# HELP go_memstats_frees_total Total number of frees.
    # TYPE go_memstats_frees_total counter
    go_memstats_frees_total 100' | promtool check metrics
    CHECK_RESULT $? 0 0 "Failed to check metrics, type: counter."
    echo '# HELP process_max_fds Maximum number of open file descriptors.
    # TYPE process_max_fds gauge
    process_max_fds wrong' | promtool check metrics
    CHECK_RESULT $? 1 0 "Failed to check metrics, type: gauge."
    echo '# HELP process_max_fds Maximum number of open file descriptors.
    # TYPE process_max_fds gauge
    process_max_fds 1024' | promtool check metrics
    CHECK_RESULT $? 0 0 "Failed to check metrics, type: gauge."
    echo '# HELP prometheus_tsdb_tombstone_cleanup_seconds The time taken to recompact blocks to remove tombstones.
    # TYPE prometheus_tsdb_tombstone_cleanup_seconds histogram
    prometheus_tsdb_tombstone_cleanup_seconds_bucket{le="1.005"} wrong' | promtool check metrics
    CHECK_RESULT $? 1 0 "Failed to check metrics, type: histogram."
    echo '# HELP prometheus_tsdb_tombstone_cleanup_seconds The time taken to recompact blocks to remove tombstones.
    # TYPE prometheus_tsdb_tombstone_cleanup_seconds histogram
    prometheus_tsdb_tombstone_cleanup_seconds_bucket{le="1.005"} 0' | promtool check metrics
    CHECK_RESULT $? 0 0 "Failed to check metrics, type: histogram."
    echo '# HELP prometheus_tsdb_wal_truncate_duration_seconds Duration of WAL truncation.
    # TYPE prometheus_tsdb_wal_truncate_duration_seconds summary
    prometheus_tsdb_wal_truncate_duration_seconds_sum wrong' | promtool check metrics
    CHECK_RESULT $? 1 0 "Failed to check metrics, type: summary."
    echo '# HELP prometheus_tsdb_wal_truncate_duration_seconds Duration of WAL truncation.
    # TYPE prometheus_tsdb_wal_truncate_duration_seconds summary
    prometheus_tsdb_wal_truncate_duration_seconds_sum 1' | promtool check metrics
    CHECK_RESULT $? 0 0 "Failed to check metrics, type: summary."
    prometheus > prometheus.log 2>&1 &
    wait_for_ready
    for ((i = 0; i < 10; i++)); do
        promtool query instant http://localhost:9090 'prometheus_build_info' 2>&1 | grep 'prometheus_build_info'
        if [ $? -eq 0 ]; then
            break
        fi
        sleep 5s
    done
    test "$i" -ne 10
    CHECK_RESULT $? 0 0 "Failed to use: query instant."
    for ((i = 0; i < 10; i++)); do
        promtool query range --start=$(date -d '5minutes ago' +'%s') --end=$(date -d 'now' +'%s') --step=1m http://localhost:9090 'process_cpu_seconds_total' | grep 'process_cpu_seconds_total'
        if [ $? -eq 0 ]; then
            break
        fi
        sleep 5s
    done
    test "$i" -ne 10
    CHECK_RESULT $? 0 0 "Failed to use: query range."
    for ((i = 0; i < 10; i++)); do
        promtool query series --match='up' --match='go_info{job="prometheus"}' http://localhost:9090 | grep '{__name__="up", instance="localhost:9090", job="test_prometheus_cli"}'
        if [ $? -eq 0 ]; then
            break
        fi
        sleep 5s
    done
    test "$i" -ne 10
    CHECK_RESULT $? 0 0 "Failed to use: query series."
    for ((i = 0; i < 10; i++)); do
        promtool query labels http://localhost:9090 'event' | grep $'add\ndelete\nupdate'
        if [ $? -eq 0 ]; then
            break
        fi
        sleep 5s
    done
    test "$i" -ne 10
    CHECK_RESULT $? 0 0 "Failed to use: query labels."
    promtool debug pprof http://localhost:9090 | grep 'collecting: http://localhost:9090/debug/pprof/goroutine'
    CHECK_RESULT $? 0 0 "Failed to use: debug pprof."
    promtool debug metrics http://localhost:9090 |grep 'collecting: http://localhost:9090/metrics'
    CHECK_RESULT $? 0 0 "Failed to use: debug metrics."
    promtool debug all http://localhost:9090 | grep 'collecting: http://localhost:9090/debug/pprof/mutex'
    CHECK_RESULT $? 0 0 "Failed to use: debug all."
    promtool test rules test.yml
    CHECK_RESULT $? 0 0 "Failed to use: test rules."
    clear_env
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"

