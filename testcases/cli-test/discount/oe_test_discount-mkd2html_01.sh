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
# @Desc      	:   the test of discount package
####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL discount
    test -d tmp || mkdir tmp
    cp -f ./common/test.md ./tmp
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."

    discount-mkd2html -header test_header ./tmp/test.md
    cat ./tmp/test.html | grep "test_header"
    CHECK_RESULT $? 0 0 "Failed to run command: discount-makepage -header"

    discount-mkd2html -footer test_footer ./tmp/test.md
    cat ./tmp/test.html | grep "test_footer"
    CHECK_RESULT $? 0 0 "Failed to run command: discount-makepage -footer"

    discount-mkd2html -css ./common/test.css ./tmp/test.md
    cat ./tmp/test.html | grep "./common/test.css"
    CHECK_RESULT $? 0 0 "Failed to run command: discount-makepage -css" 

    LOG_INFO "Finish test!"

}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    rm -rf tmp
    LOG_INFO "Finish environment cleanup!"
}

main "$@"