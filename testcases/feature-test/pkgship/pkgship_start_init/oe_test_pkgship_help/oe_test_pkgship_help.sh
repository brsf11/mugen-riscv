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
#@Author    	:   Li, Meiting
#@Contact   	:   244349477@qq.com
#@Date      	:   2020-08-28
#@License   	:   Mulan PSL v2
#@Desc      	:   Pkgship items normal function test
#####################################

source ../../common_lib/pkgship_lib.sh

function run_test() {
  LOG_INFO "Start to run test."

  pkgship -h | grep "usage: pkgship \[-h\] {init,list,builddep,installdep,selfdepend,bedepend,pkginfo,dbs,v} ...

package related dependency management

positional arguments:
  {init,list,builddep,installdep,selfdepend,bedepend,pkginfo,dbs,v}
                        package related dependency management
    init                initialization of the database
    list                get all package data
    builddep            query the compilation dependencies of the specified package
    installdep          query the installation dependencies of the specified package
    selfdepend          query the self-compiled dependencies of the specified package
    bedepend            dependency query for the specified package
    pkginfo             query the information of a single package
    dbs                 Get all data bases
    v                   Get version information

optional arguments:
  -h, --help            show this help message and exit" >/dev/null
  CHECK_RESULT $? 0 0 "The help message of pkgship is error."


  pkgship init -h | grep "usage: pkgship init \[-h\] \[-filepath FILEPATH\]

optional arguments:
  -h, --help          show this help message and exit
  -filepath FILEPATH  specify the path of conf.yaml" >/dev/null
  CHECK_RESULT $? 0 0 "The help message of pkgship init is error."

  pkgship list -h | grep "usage: pkgship list \[-h\] \[-packagename PACKAGENAME\] \[-s\] \[-remote\] database

positional arguments:
  database              name of the database operated

optional arguments:
  -h, --help            show this help message and exit
  -packagename PACKAGENAME
                        Package name that needs fuzzy matching
  -s                    Specify -s to query the source package information, If not specified, query binary package information by default
  -remote               The address of the remote service" >/dev/null
  CHECK_RESULT $? 0 0 "The help message of pkgship list is error."

  pkgship pkginfo -h | grep "usage: pkgship pkginfo [-h] [-s] [-remote] packagename database

positional arguments:
  packagename  source package name
  database     name of the database operated

optional arguments:
  -h, --help   show this help message and exit
  -s           Specify -s to query the src source package information, If not specified, query bin binary package information by default
  -remote      The address of the remote service" >/dev/null
  CHECK_RESULT $? 0 0 "The help message of pkgship pkginfo is error."

  pkgship builddep -h | grep "usage: pkgship builddep [-h] [-level LEVEL] [-remote] [-dbs [DBS [DBS ...]]] [sourceName [sourceName ...]]

positional arguments:
  sourceName            source package name

optional arguments:
  -h, --help            show this help message and exit
  -level LEVEL          Specify the dependency level that needs to be queried, by default to the last
  -remote               The address of the remote service
  -dbs [DBS [DBS ...]]  Operational database collection" >/dev/null
  CHECK_RESULT $? 0 0 "The help message of pkgship buildep is error."

  pkgship installdep -h | grep "usage: pkgship installdep [-h] [-level LEVEL] [-remote] [-dbs [DBS [DBS ...]]] [binaryName [binaryName ...]]

positional arguments:
  binaryName            binary package name

optional arguments:
  -h, --help            show this help message and exit
  -level LEVEL          Specify the dependency level that needs to be queried, by default to the last
  -remote               The address of the remote service
  -dbs [DBS [DBS ...]]  Operational database collection" >/dev/null
  CHECK_RESULT $? 0 0 "The help message of pkgship installdep is error."

  pkgship selfdepend -h | grep "usage: pkgship selfdepend [-h] [-b] [-w] [-s] [-remote] [-dbs [DBS [DBS ...]]] [pkgName [pkgName ...]]

positional arguments:
  pkgName               source package name

optional arguments:
  -h, --help            show this help message and exit
  -b                    Specify -b to indicate that the queried package is binary, and the source package is queried by default
  -w                    Specify -w means you need to find the sub-package relationship
  -s                    Specify -s to find self-compiled dependencies
  -remote               The address of the remote service
  -dbs [DBS [DBS ...]]  Operational database collection" >/dev/null
  CHECK_RESULT $? 0 0 "The help message of pkgship selfdepend is error."

  pkgship bedepend -h | grep "usage: pkgship bedepend [-h] [-w] [-b] [-install] [-build] [-remote] dbName [pkgName [pkgName ...]]

positional arguments:
  dbName      need to query the repositories of dependencies
  pkgName     source package name

optional arguments:
  -h, --help  show this help message and exit
  -w          Specifying -w means that you need to find sub-packages, not required by default
  -b          the queried package is binary, and the source package is queried by default
  -install    Specify -install means that the query is dependent on the installation,-Install and -build cannot exist at the same time
  -build      Specify -build means that the query is compiled to be dependent,-Install and -build cannot exist at the same time
  -remote     The address of the remote service" >/dev/null
  CHECK_RESULT $? 0 0 "The help message of pkgship bedpend is error."

  pkgship dbs -h | grep "usage: pkgship dbs [-h] [-remote]

optional arguments:
  -h, --help  show this help message and exit
  -remote     The address of the remote service" >/dev/null
  CHECK_RESULT $? 0 0 "The help message of pkgship dbs is error."

  LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    REVERT_ENV

    LOG_INFO "End to restore the test environment."
}

main $@
