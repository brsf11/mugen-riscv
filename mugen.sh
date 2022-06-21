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

TIMEOUT="30m"
COMMAND_X="no"
COMMAND_S="no"
COPY_DONE="no"
CASE_NUM=0
SUCCESS_NUM=0
FAIL_NUM=0

function usage() {
    printf "Usage:  \n
    -c: configuration environment of test framework\n
    -a: execute all use cases\n
    -f: designated test suite\n
    -r: designated test case\n
    -x: the shell script is executed in debug mode\n
    -b: do make for test suite if test suite path have makefile or Makefile file\n
    -s: runing test case at remote NODE1
    \n
    Example: 
        run all cases:
          normal mode:
            bash mugen.sh -a
          debug mode:
            bash mugen.sh -a -x

        run test suite:
          normal mode:
            bash mugen.sh -f test_suite
          debug mode:
            bash mugen.sh -f test_suite -x

        run test case:
          normal mode:
            bash mugen.sh -f test_suite -r test_case
          debug mode:
            bash mugen.sh -f test_suite -r test_case -x
        
        run at remote:
          normal mode:
            bash mugen.sh -a -s
            bash mugen.sh -f test_suite -s
            bash mugen.sh -f test_suite -r test_case -s
          debug mode:
            bash mugen.sh -a -s
            bash mugen.sh -f test_suite -s
            bash mugen.sh -f test_suite -r test_case -s
        \n
	configure env of test framework:
	    bash mugen.sh -c --ip \$ip --password \$passwd --user \$user --port \$port\n
          if want run at remote should add --run_remote 
          if want run at remote copy all testcase once add --put_all
    \n
    do make for test suite:
        for all test suite:
            bash mugen.sh -b -a
        for one test suite:
            bash mugen.sh -b test_suite\n"
}

function deploy_conf() {
    python3 ${OET_PATH}/libs/locallibs/write_conf.py "$@"
    test $? -ne 0 && exit 1 || exit 0
}

function load_conf() {
    rm -rf ${OET_PATH}/results

    export_var=$(python3 ${OET_PATH}/libs/locallibs/read_conf.py env-var)
    test $? -ne 0 && exit 1

    $export_var

    env_conf="$(echo -e $conf_file | sed -e 's/json/env/')"
    printf "%s\n" "$export_var" >$env_conf

    if [[ $COMMAND_S == "yes" ]]; then
        env_path="$(echo -e $conf_file | sed -e 's/mugen.json//')"
        SFTP put --node 1 --remotedir /mugen_re/conf/ --localdir $env_path --localfile "mugen.env"
    fi
}

function generate_result_file() {
    local suite=$1
    local case=$2
    local exitcode=$3

    if [ "$exitcode" -eq 0 ]; then
        LOG_INFO "The case exit by code $ret_code."
        ((SUCCESS_NUM++))
        result="succeed"
    else
        LOG_ERROR "The case exit by code $ret_code."
        ((FAIL_NUM++))
        result="failed"
    fi

    local result_path="$OET_PATH/results/$suite/$result"
    mkdir -p "$result_path"
    touch "$result_path"/"$case"
}

function exec_case() {
    local cmd=$1
    local log_path=$2
    local case_name=$3
    local test_suite=$4

    exec 6>&1
    exec 7>&2
    exec >>"$log_path"/"$(date +%Y-%m-%d-%T)".log 2>&1

    SLEEP_WAIT $TIMEOUT "$cmd"
    ret_code=$?

    exec 1>&6 6>&-
    exec 2>&7 7>&-

    test "$ret_code"x == "143"x && {
        cmd_pid=$(pgrep "$cmd")
        if [ -n "$cmd_pid" ]; then
            for pid in ${cmd_pid}; do
                pstree -p "$pid" | grep -o '([0-9]*)' | tr -d '()' | xargs kill -9
            done
        fi
        LOG_WARN "The case execution timeout."
    }

    generate_result_file "$test_suite" "$case_name" "$ret_code"
}

function run_test_case() {

    local test_suite=$1
    local test_case=$2
    export exec_result

    if [[ -z "$test_suite" || -z "$test_case" ]]; then
        LOG_ERROR "Parameter(test suite or test case) loss."
        exit 1
    fi

    result_files=$(find ${OET_PATH}/results/${test_suite} -name "$test_case" >/dev/null 2>&1)
    for result_file in $result_files; do
        test -f $result_file && rm -rf $result_file
    done

    suite_path=$(python3 ${OET_PATH}/libs/locallibs/suite_case.py --suite $test_suite --key path)
    test $? -ne 0 && return 1
    test -d "$suite_path" || {
        LOG_ERROR "Path value:${suite_path} in a JSON file that does not exist in the environment."
        return 1
    }

    ((CASE_NUM++))

    if ! grep -q "$test_case" suite2cases/"${test_suite}.json"; then
        LOG_ERROR "In the suite2cases directory, Can't find the case name:${test_case} in the file of testsuite:${test_suite}."
        generate_result_file "$test_suite" "$case_name" 1
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

    if [ -z "${case_path[*]}" ]; then
        echo -e "Can't find the test script:$test_case, Please confirm whether the code is submitted." >>"$log_path"/"$(date +%Y-%m-%d-%T)".log 2>&1
        exec_case "exit 255" "$log_path" "$test_case" "$test_suite"
    fi

    if [[ $COMMAND_S == "yes" && $COPY_DONE == "no" ]]; then
        common_files=$(python3 ${OET_PATH}/libs/locallibs/suite_case.py --suite $test_suite --key common-files)
        test $? -ne 0 && return 1

        for one_file in $common_files; do
            local_dir=${one_file%/*}
            local_file=${one_file##*/}
            remote_dir=$(echo -e ${local_dir} | sed -e "s#${OET_PATH}#/mugen_re#")
            SFTP put --node 1 --remotedir $remote_dir --remotefile $local_file --localdir $local_dir --localfile $local_file
            if [ $? -ne 0 ]; then
                LOG_ERROR "Copy $test_suite suite2cases to remote fail."
                return 1
            fi
        done

        remote_dir=$(echo -e ${case_path%/*} | sed -e "s#${OET_PATH}#/mugen_re#") 
        SFTP put --node 1 --remotedir $remote_dir --localdir $case_path
        test $? -ne 0 && return 1
    fi

    pushd "$case_path" >/dev/null || return 1

    local time_out
    time_out=$(grep -w --fixed-strings EXECUTE_T ${test_case}.* 2>/dev/null | awk -F '=' '{print $NF}' | tr -d '"')
    test -n "$time_out" && local TIMEOUT=$time_out

    local script_type
    script_type=$(find . -name "${test_case}.*" | awk -F '.' '{print $NF}')

    if [[ "$script_type"x == "sh"x ]] || [[ "$script_type"x == "bash"x ]]; then
        if [ "$COMMAND_X"x == "yes"x ]; then
            run_cmd="bash -x ${test_case}.sh"
        else
            run_cmd="bash ${test_case}.sh"
        fi
    elif [ "$script_type"x == "py"x ]; then
        run_cmd="python3 ${test_case}.py"
    fi

    if [[ $COMMAND_S == "yes" ]]; then
        remote_case_path=$(echo -e ${case_path} | sed -e "s#${OET_PATH}#/mugen_re#")
        remote_cmd=". /mugen_re/conf/mugen.env &&
                 export OET_PATH=/mugen_re &&
                 pushd \"$remote_case_path\" >/dev/null || exit 1 &&
                 $run_cmd > /tmp/mugen_re.log 2>&1 &&
                 (cat /tmp/mugen_re.log && rm -rf /tmp/mugen_re.log && popd >/dev/null || exit 1) ||
                 (cat /tmp/mugen_re.log 1>&2 && rm -rf /tmp/mugen_re.log && popd >/dev/null && exit 1)
                "
        run_cmd="python3 ${OET_PATH}/libs/locallibs/ssh_cmd.py --node 1 --cmd \"${remote_cmd}\""
    fi

    exec_case "$run_cmd" "$log_path" "$test_case" "$test_suite"

    popd >/dev/null || return 1

    if [[ $COMMAND_S == "yes" && $COPY_DONE == "no" ]]; then
        remote_dir=$(echo -e ${suite_path} | sed -e "s#${OET_PATH}#/mugen_re#")
        P_SSH_CMD --node 1 --cmd "rm -rf $remote_dir"
    fi

    LOG_INFO "End to run testcase:$test_case."
}

function run_test_suite() {
    local test_suite=$1

    [ -z "$(find $OET_PATH/suite2cases -name ${test_suite}.json)" ] && {
        LOG_ERROR "In the suite2cases directory, Can't find the file of testsuite:${test_suite}."
        return 1
    }

    local this_copy=false
    local suite_path=""
    if [[ $COMMAND_S == "yes" && $COPY_DONE == "no" && ${NODE1_COPY_ALL}x == "true"x ]]; then
        suite_path=$(python3 ${OET_PATH}/libs/locallibs/suite_case.py --suite $test_suite --key path)
        test $? -ne 0 && return 1

        remote_dir=$(echo -e ${suite_path%/*} | sed -e "s#${OET_PATH}#/mugen_re#")
        SFTP put --node 1 --remotedir $remote_dir --localdir $suite_path
        if [ $? -ne 0 ]; then
            LOG_ERROR "Copy $test_suite testcases to remote fail."
            return 1
        fi
        COPY_DONE="yes"
        this_copy=true
    fi

    for test_case in $(python3 ${OET_PATH}/libs/locallibs/suite_case.py --suite $test_suite --key cases-name | shuf); do
        run_test_case "$test_suite" "$test_case"
    done

    if $this_copy; then
        remote_dir=$(echo -e ${suite_path} | sed -e "s#${OET_PATH}#/mugen_re#")
        P_SSH_CMD --node 1 --cmd "rm -rf $remote_dir"
    fi
}

function run_all_cases() {
    test_suites=($(find ${OET_PATH}/suite2cases/ -type f -name "*.json" | awk -F '/' '{print $NF}' | sed -e 's/.json$//g'))
    test ${#test_suites[@]} -eq 0 && {
        LOG_ERROR "Can't find recording about test_suites."
        return 1
    }

    local this_copy=false
    if [[ $COMMAND_S == "yes" && $COPY_DONE == "no" && ${NODE1_COPY_ALL}x == "true"x ]]; then
        SFTP put --node 1 --remotedir /mugen_re/ --localdir ${OET_PATH}/testcases/
        if [ $? -ne 0 ]; then
            LOG_ERROR "Copy all testcases to remote fail."
            return 1
        fi
        COPY_DONE="yes"
        local this_copy=true
    fi

    for test_suite in ${test_suites[*]}; do
        run_test_suite "$test_suite"
    done

    if $this_copy; then
        P_SSH_CMD --node 1 --cmd "rm -rf /mugen_re/testcases"
    fi
}

function statistic_result() {

    LOG_INFO "A total of ${CASE_NUM} use cases were executed, with ${SUCCESS_NUM} successes and ${FAIL_NUM} failures."

    exit ${FAIL_NUM}
}

DO_MAKE_COUNT=0
NOT_DO_MAKE_COUNT=0
TOTAL_MAKE_COUNT=0

function build_one_suite() {
    ((TOTAL_MAKE_COUNT++))
    local test_suite=$1

    [ -z "$(find $OET_PATH/suite2cases -name ${test_suite}.json)" ] && {
        LOG_ERROR "In the suite2cases directory, Can't find the file of testsuite:${test_suite}."
        return 1
    }

    suite_path=$(python3 ${OET_PATH}/libs/locallibs/suite_case.py --suite $test_suite --key path)
    if [ $? -ne 0 ]; then
        LOG_ERROR "find ${test_suite} test suite path fail"
        return 1
    fi
    test -d "$suite_path" || {
        LOG_ERROR "Path value:${suite_path} in a JSON file that does not exist in the environment."
        return 1
    }

    pushd "$suite_path" >/dev/null || return 1

    if [[ -f "./makefile" || -f "./Makefile" ]]; then
        LOG_INFO "do make for testsuite: ${test_suite}"
        make
        if [ $? -ne 0 ]; then
            LOG_ERROR "do make for testsuite: ${test_suite} fail"
            popd >/dev/null
            return 1
        fi
        ((DO_MAKE_COUNT++))
    else
        if [[ $2 != "no_print" ]]; then
            LOG_INFO "This test suite $suite_path have no makefile or Makefile"
        fi
        ((NOT_DO_MAKE_COUNT++))
    fi

    popd >/dev/null || return 1

    return 0
}

function build_all() {
    test_suites=($(find ${OET_PATH}/suite2cases/ -type f -name "*.json" | awk -F '/' '{print $NF}' | sed -e 's/.json$//g'))
    test ${#test_suites[@]} -eq 0 && {
        LOG_ERROR "Can't find recording about test_suites."
        return 1
    }

    do_error_count=0

    for test_suite in ${test_suites[*]}; do
        build_one_suite "$test_suite" "no_print"
        if [ $? -ne 0 ]; then
            LOG_ERROR "doing test suite $test_suite make fail"
            ((do_error_count++))
        fi
    done

    LOG_INFO "A total ${TOTAL_MAKE_COUNT} test suite run make, ${DO_MAKE_COUNT} had make, ${NOT_DO_MAKE_COUNT} no need do make, ${do_error_count} do make fail"
    if [ $do_error_count -ne 0 ]; then
        exit 1
    fi

    exit 0
}

function copy_libs_to_node1() {
    if [[ $COMMAND_S == "no" ]]; then
        return
    fi
    P_SSH_CMD --node 1 --cmd "ls -l /mugen_re/" | grep -q "libs"
    if [ $? -ne 0 ]; then
        SFTP put --node 1 --remotedir /mugen_re/ --localdir ${OET_PATH}/libs/
    fi
}

while getopts "c:af:r:dxb:s" option; do
    case $option in
    c)
        deploy_conf ${*//-c/}
        ;;
    d)
        echo -e "The test script download function has been discarded."
        ;;
    a)
        if echo "$@" | grep -q -e ' -a *-x *$\| -x *-a *$\| -ax *$\| -xa *$'; then
            COMMAND_X="yes"
        elif echo "$@" | grep -q -e '-a *-s *$\|-s *-a *$\|-as *$\|-sa *$'; then
            COMMAND_S="yes"
        elif echo "$@" | grep -q -e '-a *-b *$\|-b *-a *$\|-ab *$\|-ba *$'; then
            ret=$(build_all)
            exit $ret
        elif ! echo "$@" | grep -q -e '-a *$'; then
            usage
            exit 1
        fi

        load_conf
        copy_libs_to_node1
        run_all_cases
        statistic_result
        ;;
    b)
        test_suite=$OPTARG
        op_list=('-f' '-r' '-x' '-d' '-c' '-s')

        for op in ${op_list[*]}; do
            if [[ $test_suite ==  $op ]]; then
                usage
                exit 1
            fi
        done

        if echo "$@" | grep -q -e ' *-a *$\|-ba *$'; then
            build_all
        else
            build_one_suite $test_suite
        fi

        ;;
    f)
        test_suite=$OPTARG

        echo "$@" | grep -q -e " -b *$"
        if [ $? -eq 0 ]; then
            usage
            exit 1
        fi

        echo $test_suite | grep -q -e ' -a\| -r \|-x\|-d' && {
            usage
            exit 1
        }

        echo "$@" | grep -q -e ' *-x *\| *-xf *' && {
            COMMAND_X="yes"
        }

        echo "$@" | grep -q -e ' *-s *\| *-sf *' && {
            COMMAND_S="yes"
        }

        echo "$@" | grep -q -e ' -r ' || {
            load_conf
            copy_libs_to_node1
            run_test_suite $test_suite
            statistic_result
        }
        ;;
    r)
        test_case=$OPTARG

        echo "$@" | grep -q -e " -b *$"
        if [ $? -eq 0 ]; then
            usage
            exit 1
        fi

        echo $test_case | grep -q -e ' -a\| -f\| -x\| -d' && {
            usage
            exit 1
        }

        echo "$@" | grep -q -e ' *-x *\| *-xr *\| *-xf *' && {
            COMMAND_X="yes"
        }

        echo "$@" | grep -q -e ' *-s *\| *-sr *\| *-sf *' && {
            COMMAND_S="yes"
        }

        load_conf
        copy_libs_to_node1
        run_test_case $test_suite $test_case
        statistic_result
        ;;
    x)
        echo "$@" | grep -q -e '^ [a-Z0-9-_]-x *$' && {
            LOG_ERROR "The -x parameter must be used in combination with -a, -f, and -r."
            exit 1
        }
        ;;
    s)
        echo "$@" | grep -q -e '^ [a-Z0-9-_]-x *$' && {
            LOG_ERROR "The -s parameter must be used in combination with -a, -f, and -r."
            exit 1
        }
        ;;
    *)
        usage
        exit 1
        ;;

    esac
done
