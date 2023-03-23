#!/usr/bin/bash

# Copyright (c) 2023. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   yangchenguang
# @Contact   :   yangchenguang@uniontech.com
# @Date      :   2023/01/31
# @License   :   Mulan PSL v2
# @Desc      :   Test xmllint format xml
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL libxml2
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    cat >>test_old.xml << EOF
<person><name>openEuler</name><age>2</age></person>
EOF
    xmllint --format test_old.xml --output test_new.xml
    CHECK_RESULT $? 0 0 "Failed to fromat xml"
    cat >> test_xsd.xsd << EOF
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
<xs:element name="name" type="xs:string"/>
<xs:element name="age" type="xs:integer"/>
<xs:element name="person">
<xs:complexType>
<xs:all>
<xs:element ref="name"/>
<xs:element ref="age"/>
</xs:all>
</xs:complexType>
</xs:element>
</xs:schema>
EOF
    xmllint --schema test_xsd.xsd test_new.xml
    CHECK_RESULT $? 0 0 "Xml schema error"
    xmllint --noblanks test_new.xml
    CHECK_RESULT $? 0 0 "Failed delete space for xml"
    xmllint --xpath '//person/name' test_new.xml
    CHECK_RESULT $? 0 0 "Failed to search element"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -f test_old.xml test_new.xml test_xsd.xsd
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
