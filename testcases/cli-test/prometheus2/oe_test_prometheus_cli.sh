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
# @Desc      :   Test Prometheus command line
# #############################################

source "./common_lib.sh"

function config_params() {
    LOG_INFO "Start to config params of the case."
    free_port="$(GET_FREE_PORT localhost)"
    LOG_INFO "End to config params of the case."
}

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL prometheus2
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    prometheus --version 2>&1 | grep 'prometheus, version'
    CHECK_RESULT $? 0 0 'Failed to output version info.'
    prometheus --help 2>&1 | grep 'usage: prometheus'
    CHECK_RESULT $? 0 0 'Failed to output version info.' 
    prometheus --config.file="prometheus.yml" > prometheus.log 2>&1 &
    wait_for_ready
    curl -s "localhost:9090/config" | grep 'job_name: test_prometheus_cli'
    CHECK_RESULT $? 0 0 "Failed to use specific config file."
    clear_env
    prometheus --web.listen-address="0.0.0.0:${free_port}" > prometheus.log 2>&1 &
    wait_for_ready
    curl -s "http://localhost:$free_port" | grep 'Found'
    CHECK_RESULT $? 0 0 'Failed to use flag: --web.listen-address'
    clear_env
    prometheus --web.read-timeout=5m > prometheus.log 2>&1 &
    CHECK_RESULT $? 0 0 'Failed to use flag: --web.read-timeout'
    clear_env
    prometheus --web.max-connections=100 > prometheus.log 2>&1 &
    CHECK_RESULT $? 0 0 'Failed to use flag: --web.max-connections'
    clear_env
    prometheus --web.external-url="the_external_url" > prometheus.log 2>&1 &
    wait_for_ready
    curl -s 'http://localhost:9090' | grep '<a href="/the_external_url">Found</a>.'
    CHECK_RESULT $? 0 0 'Failed to use flag: --web.external-url'
    clear_env
    prometheus --web.route-prefix="the_prefix" > prometheus.log 2>&1 &
    wait_for_ready
    curl -s 'http://localhost:9090' | grep '<a href="/the_prefix">Found</a>.'
    CHECK_RESULT $? 0 0 'Failed to use flag: --web.route-prefix'
    clear_env
    prometheus --web.user-assets=./ > prometheus.log 2>&1 &
    CHECK_RESULT $? 0 0 'Failed to use flag: --web.user-assets'
    clear_env
    prometheus --web.enable-lifecycle > prometheus.log 2>&1 &
    wait_for_ready
    curl -s -X POST 'http://localhost:9090/-/quit'
    CHECK_RESULT "$(pgrep 'prometheus')" 1 0 'Failed to use flag: --web.enable-lifecycle'
    clear_env
    prometheus --web.enable-admin-api > prometheus.log 2>&1 &
    wait_for_ready
    curl -s -X POST 'http://localhost:9090/api/v1/admin/tsdb/snapshot' | grep '"status":"success"'
    CHECK_RESULT $? 0 0 'Failed to use flag:  --web.enable-admin-api'
    clear_env
    prometheus --web.console.templates=./ > prometheus.log 2>&1 &
    CHECK_RESULT $? 0 0 'Failed to use flag: --web.console.templates'
    clear_env
    prometheus --web.console.libraries=./ > prometheus.log 2>&1 &
    CHECK_RESULT $? 0 0 'Failed to use flag: --web.console.libraries'
    clear_env
    prometheus --web.page-title="the title" > prometheus.log 2>&1 &
    wait_for_ready
    curl -s 'http://localhost:9090/config' | grep '<title>the title</title>'
    CHECK_RESULT $? 0 0 'Failed to use flag: --web.page-title'
    clear_env
    prometheus --web.cors.origin=".*" > prometheus.log 2>&1 &
    CHECK_RESULT $? 0 0 'Failed to use flag: --web.cors.origin'
    clear_env
    prometheus --storage.tsdb.path="./the_data/" > prometheus.log 2>&1 &
    wait_for_ready
    CHECK_RESULT "$(ls ./the_data | grep -cE 'chunks_head|lock|queries.active|wal')" 4 0 'Failed to use flag: --storage.tsdb.path'
    clear_env
    clear_env
    prometheus --storage.tsdb.retention=1m > prometheus.log 2>&1 &
    CHECK_RESULT $? 0 0 'Failed to use flag: --storage.tsdb.retention'
    clear_env
    prometheus --storage.tsdb.retention.time=1m > prometheus.log 2>&1 &
    CHECK_RESULT $? 0 0 'Failed to use flag: --storage.tsdb.retention.time'
    clear_env
    prometheus --storage.tsdb.retention.size=1MB > prometheus.log 2>&1 &
    CHECK_RESULT $? 0 0 'Failed to use flag: --storage.tsdb.retention.size'
    clear_env
    prometheus --storage.tsdb.no-lockfile > prometheus.log 2>&1 &
    CHECK_RESULT "$(ls ./data | grep -cE 'lock')" 0 0 'Failed to use flag: --storage.tsdb.no-lockfile'
    clear_env
    prometheus --storage.tsdb.allow-overlapping-blocks > prometheus.log 2>&1 &
    CHECK_RESULT $? 0 0 'Failed to use flag: --storage.tsdb.allow-overlapping-blocks'
    clear_env
    prometheus --storage.tsdb.wal-compression > prometheus.log 2>&1 &
    CHECK_RESULT $? 0 0 'Failed to use flag: --storage.tsdb.wal-compression'
    clear_env
    prometheus --storage.remote.flush-deadline=1m > prometheus.log 2>&1 &
    CHECK_RESULT $? 0 0 'Failed to use flag: --storage.remote.flush-deadline'
    clear_env
    prometheus --storage.remote.read-sample-limit=5 > prometheus.log 2>&1 &
    CHECK_RESULT $? 0 0 'Failed to use flag: --storage.remote.read-sample-limit'
    clear_env
    prometheus --storage.remote.read-concurrent-limit=5 > prometheus.log 2>&1 &
    CHECK_RESULT $? 0 0 'Failed to use flag: --storage.remote.read-concurrent-limit'
    clear_env
    prometheus --storage.remote.read-max-bytes-in-frame=100 > prometheus.log 2>&1 &
    CHECK_RESULT $? 0 0 'Failed to use flag: --storage.remote.read-max-bytes-in-frame'
    clear_env
    prometheus --rules.alert.for-outage-tolerance=1h > prometheus.log 2>&1 &
    CHECK_RESULT $? 0 0 'Failed to use flag: --rules.alert.for-outage-tolerance'
    clear_env
    prometheus --rules.alert.for-grace-period=5m > prometheus.log 2>&1 &
    CHECK_RESULT $? 0 0 'Failed to use flag: --rules.alert.for-grace-period'
    clear_env
    prometheus --rules.alert.resend-delay=5m > prometheus.log 2>&1 &
    CHECK_RESULT $? 0 0 'Failed to use flag: --rules.alert.resend-delay'
    clear_env
    prometheus --alertmanager.notification-queue-capacity=100 > prometheus.log 2>&1 &
    CHECK_RESULT $? 0 0 'Failed to use flag: --alertmanager.notification-queue-capacity'
    clear_env
    prometheus --alertmanager.timeout=5s > prometheus.log 2>&1 &
    CHECK_RESULT $? 0 0 'Failed to use flag: --alertmanager.timeout'
    clear_env
    prometheus --query.lookback-delta=2m > prometheus.log 2>&1 &
    CHECK_RESULT $? 0 0 'Failed to use flag: --query.lookback-delta'
    clear_env
    prometheus --query.timeout=2m > prometheus.log 2>&1 &
    CHECK_RESULT $? 0 0 'Failed to use flag: --query.timeout'
    clear_env
    prometheus --query.max-concurrency=10 > prometheus.log 2>&1 &
    CHECK_RESULT $? 0 0 'Failed to use flag: --query.max-concurrency'
    clear_env
    prometheus --query.max-samples=100 > prometheus.log 2>&1 &
    CHECK_RESULT $? 0 0 'Failed to use flag: --query.max-samples'
    clear_env
    prometheus --log.level=debug > prometheus.log 2>&1 &
    CHECK_RESULT $? 0 0 'Failed to use flag: --log.level'
    clear_env
    prometheus --log.format=json > prometheus.log 2>&1 &
    wait_for_ready
    grep '"level":"info","msg":"Server is ready to receive web requests."' ./prometheus.log
    CHECK_RESULT $? 0 0 'Failed to use flag: --log.format'
    clear_env
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "Start environment cleanup."
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
