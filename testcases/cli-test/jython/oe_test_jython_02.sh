# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
# @Author    	:   zu binshuo
# @Contact   	:   binshuo@isrc.iscas.ac.cn
# @Date      	:   2022-7-15
# @License   	:   Mulan PSL v2
# @Desc      	:   the test of pngcrush package
####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL jython
    ss=""
    for file in $(ls /usr/share/jython/javalib); do
        ss=$ss"/usr/share/jython/javalib/${file}:"
    done
    export CLASSPATH=$ss
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."

    jython -Dpython.verbose=comment -c "" 2>&1 | grep -m 1 "import"
    CHECK_RESULT $? 0 0 "Failed to run command: jython -D"

    echo "print 'test'; exit(0)" | jython 2>&1 | grep "test"
    CHECK_RESULT $? 0 0 "Failed to run command: jython (interactive mode)"

    jython -c "import sys; print sys.argv[1]; exit(0)" test_arg 2>&1 | grep "test_arg"
    CHECK_RESULT $? 0 0 "Failed to run command: jython arg"

    jython -m timeit -h 2>&1 | grep "Library usage:"
    CHECK_RESULT $? 0 0 "Failed to run command: jython -m"

    jython -3 ./common/test.py 2>&1 | grep "DeprecationWarning"
    CHECK_RESULT $? 0 0 "Failed to run command: jython -3"

    jython -3 -W ignore::DeprecationWarning ./common/test.py 2>&1 | grep "DeprecationWarning"
    CHECK_RESULT $? 0 1 "Failed to run command: jython -W"

    jython -s -m site 2>&1 | grep "ENABLE_USER_SITE: False"
    CHECK_RESULT $? 0 0 "Failed to run command: jython -s"
    
    jython -u -c "import sys;sys.stdout.write('stdout1');sys.stderr.write('stderr1')" 2>&1 | grep "stdout1stderr1"
    CHECK_RESULT $? 0 0 "Failed to run command: jython -u"

    LOG_INFO "Finish test!"

}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"