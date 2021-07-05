#!/usr/bin/bash
# Copyright (c) [2021] Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
# @Author  : lemon-higgins
# @email   : lemon.higgins@aliyun.com
# @Date    : 2021-04-20 15:12:00
# @License : Mulan PSL v2
# @Version : 1.0
# @Desc    :
#####################################

OET_PATH=$(
    cd "$(dirname "$0")" || exit 1
    pwd
)
export OET_PATH

source ${OET_PATH}/libs/locallibs/common_lib.sh

[[ -d "/etc/mugen" ]] && export conf_file="/etc/mugen/mugen.json" || export conf_file="${OET_PATH}/conf/mugen.json"
REPOSITORY="https://gitee.com/openeuler/integration-test.git"

TIMEOUT="30m"
COMMAND_X="no"
CASE_NUM=0
SUCCESS_NUM=0
FAIL_NUM=0

function usage() {
    echo TODO
    #TODO
}

function deploy_conf() {
    python3 ${OET_PATH}/libs/locallibs/write_conf.py "$@"
    test $? -ne 0 && exit 1
}

function load_conf() {
    rm -rf ${OET_PATH}/results

    export_var=$(python3 ${OET_PATH}/libs/locallibs/read_conf.py env-var)
    test $? -ne 0 && exit 1

    $export_var

    env_conf="$(echo -e $conf_file | sed -e 's/json/env/')"
    printf "%s\n" "$export_var" >$env_conf

}

function exec_case() {
    local cmd=$1
    local log_path=$2
    local case_name=$3

    exec 6>&1
    exec 7>&2

    exec >"$log_path"/"$(date +%Y-%m-%d-%T)".log 2>&1

    timeout --preserve-status $TIMEOUT $cmd
    ret_code=$?

    exec 1>&6 6>&-
    exec 2>&7 7>&-

    test "$ret_code"x == "143"x && {
        LOG_WARN "The case execution timeout."
    }

    if [ $ret_code -eq 0 ]; then
        LOG_INFO "The case exit by code $ret_code."
        ((SUCCESS_NUM++))
        mkdir -p ${OET_PATH}/results/succeed
        touch ${OET_PATH}/results/succeed/${case_name}
    else
        LOG_ERROR "The case exit by code $ret_code."
        ((FAIL_NUM++))
        mkdir -p ${OET_PATH}/results/failed
        touch ${OET_PATH}/results/failed/${case_name}
    fi
}

function run_test_case() {

    local test_suite=$1
    local test_case=$2

    if [[ -z "$test_suite" || -z "$test_case" ]]; then
        LOG_ERROR "Parameter(test suite or test case) loss."
        exit 1
    fi

    ((CASE_NUM++))

    suite_path=$(python3 ${OET_PATH}/libs/locallibs/suite_case.py --suite $test_suite --key path)
    test $? -ne 0 && return 1
    test -d "$suite_path" || {
        LOG_ERROR "Path value:${suite_path} in a JSON file that does not exist in the environment."
        return 1
    }

    if ! grep -q "$test_case" suite2cases/"${test_suite}.json"; then
        LOG_ERROR "In the suite2cases directory, Can't find the case name:${test_case} in the file of testsuite:${test_suite}."
        return 1
    fi

    case_path=($(find ${suite_path} -name "${test_case}.*" | sed -e "s#/${test_case}.\(sh\|py\)##"))
    test ${#case_path[@]} -gt 1 && {
        LOG_ERROR "Multiple identical test case scripts have been found under the test suite. Please check your use case scripts."
        return 1
    }

    log_path=${OET_PATH}/logs/${test_suite}/${test_case}
    mkdir -p ${log_path}

    LOG_INFO "start to run testcase:$test_case."

    pushd "$case_path" >/dev/null || return 1

    local time_out
    time_out=$(grep -w --fixed-strings EXECUTE_T ${test_case}.* 2>/dev/nul | awk -F '=' '{print $NF}' | tr -d '"')
    test -n "$time_out" && TIMEOUT=$time_out

    local script_type
    script_type=$(find . -name "${test_case}.*" | awk -F '.' '{print $NF}')

    if [[ "$script_type"x == "sh"x ]] || [[ "$script_type"x == "bash"x ]]; then
        if [ "$COMMAND_X"x == "yes"x ]; then
            exec_case "bash -x ${test_case}.sh" "$log_path" "$test_case"
        else
            exec_case "bash ${test_case}.sh" "$log_path" "$test_case"
        fi
    elif [ "$script_type"x == "py"x ]; then
        exec_case "python3 ${test_case}.py" "$log_path" "$test_case"
    fi

    popd >/dev/nul || return 1

    LOG_INFO "End to run testcase:$test_case."
}

function run_test_suite() {
    local test_suite=$1

    [ -z "$(find $OET_PATH/suite2cases -name ${test_suite}.json)" ] && {
        LOG_ERROR "In the suite2cases directory, Can't find the file of testsuite:${test_suite}."
        return 1
    }

    for test_case in $(python3 ${OET_PATH}/libs/locallibs/suite_case.py --suite $test_suite --key cases-name | shuf); do
        run_test_case "$test_suite" "$test_case"
    done
}

function run_all_cases() {
    test_suites=($(find ${OET_PATH}/suite2cases/ -type f -name "*.json" | awk -F '/' '{print $NF}' | sed -e 's/.json$//g'))
    test ${#test_suites[@]} -eq 0 && {
        LOG_ERROR "Can't find recording about test_suites."
        return 1
    }

    for test_suite in ${test_suites[*]}; do

        run_test_suite "$test_suite"
    done
}

function statistic_result() {

    LOG_INFO "A total of ${CASE_NUM} use cases were executed, with ${SUCCESS_NUM} successes and ${FAIL_NUM} failures."

    [ ${FAIL_NUM} -ne 0 ] && exit 1
}

while getopts "c:af:r:dx" option; do
    case $option in
    c)
        deploy_conf ${*//-c/}
        ;;
    d)
        echo -e "The test script download function has been discarded."
        ;;
    a)
        if echo "$@" | grep -q -e '-a *-x *$\|-x *-a *$\|-ax *$\|-xa *$'; then
            COMMAND_X="yes"
        elif ! echo "$@" | grep -q -e '-a *$'; then
            usage
            exit 1
        fi

        load_conf
        run_all_cases
        statistic_result
        ;;

    f)
        test_suite=$OPTARG

        echo $test_suite | grep -q -e '-a\| -r \|-x\|-d' && {
            usage
            exit 1
        }

        echo "$@" | grep -q -e ' *-x *\| *-xf *' && {
            COMMAND_X="yes"
        }

        echo "$@" | grep -q -e ' -r ' || {
            load_conf
            run_test_suite $test_suite
            statistic_result
        }
        ;;
    r)
        test_case=$OPTARG
        echo $test_case | grep -q -e '-a\|-f\|-x\|-d' && {
            usage
            exit 1
        }

        echo "$@" | grep -q -e ' *-x *\| *-xr *\| *-xf *' && {
            COMMAND_X="yes"
        }

        load_conf
        run_test_case $test_suite $test_case
        statistic_result
        ;;
    x)
        echo "$@" | grep -q -e '^ *-x *$' && {
            LOG_ERROR "The -x parameter must be used in combination with -a, -f, and -r."
            exit 1
        }
        ;;
    *)
        usage
        exit 1
        ;;

    esac
done
