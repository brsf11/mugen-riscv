#!/usr/bin/bash

# Copyright (c) 2021. Ding Taixin, 1315774958@qq.com. ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

####################################
#@Author        :   Ding Taixin
#@Contact       :   1315774958@qq.com
#@Date          :   2021/7/26
#@License       :   Mulan PSL v2
#@Desc          :   Test "getfacl" command
#####################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    
    DNF_INSTALL acl
    touch file 
    ln -s file filelink
    mkdir -p dir/subdir   
    uid=$(whoami)
    setfacl -d -m user:${uid}:rwx dir
    
    LOG_INFO "End to prepare the test environment."
}

################################################################################
# getfacl 2.2.53 -- get file access control lists
# Usage: getfacl [-aceEsRLPtpndvh] file ...
#   -a,  --access           display the file access control list only
#   -d, --default           display the default access control list only
#   -c, --omit-header       do not display the comment header
#   -e, --all-effective     print all effective rights
#   -E, --no-effective      print no effective rights
#   -s, --skip-base         skip files that only have the base entries
#   -R, --recursive         recurse into subdirectories
#   -L, --logical           logical walk, follow symbolic links
#   -P, --physical          physical walk, do not follow symbolic links
#   -t, --tabular           use tabular output format
#   -n, --numeric           print numeric user/group identifiers
#   -p, --absolute-names    don't strip leading '/' in pathnames
#   -v, --version           print version and exit
#   -h, --help              this help text
################################################################################

function run_test() {
    LOG_INFO "Start to run test."
    
    ### No Options ###
    getfacl file | grep -qe "^# file:"
    CHECK_RESULT $? 0 0 "L$LINENO: No Options No Pass"
    
    ### -a ###
    getfacl -a dir > result \
        && mapfile -t line < result \
        && [[ ${#line[@]} == 7 \
                && ${line[0]} =~ "file:" \
                && ${line[1]} =~ "owner:" \
                && ${line[2]} =~ "group:" \
                && ${line[3]} =~ "user:" \
                && ${line[4]} =~ "group:" \
                && ${line[5]} =~ "other:" \
                && ${line[6]}x == x \
            ]] 
    CHECK_RESULT $? 0 0 "L$LINENO: -a No Pass"
    
    ### -d ###
    getfacl -d dir > result \
        && mapfile -t line < result \
        && [[ ${#line[@]} == 9 \
                && ${line[0]} =~ "file:" \
                && ${line[1]} =~ "owner:" \
                && ${line[2]} =~ "group:" \
                && ${line[3]} =~ "user:" \
                && ${line[4]} =~ "user:$uid:" \
                && ${line[5]} =~ "group:" \
                && ${line[6]} =~ "mask:" \
                && ${line[7]} =~ "other:" \
                && ${line[8]}x == x \
            ]] 
    CHECK_RESULT $? 0 0 "L$LINENO: -d No Pass"

    ### -c ###
    getfacl -c file | grep -qe "^# file:" 
    CHECK_RESULT $? 1 0 "L$LINENO: -c No Pass"

    ### -e ###
    getfacl -e dir > result \
        && mapfile -t line < result \
        && [[ ${#line[@]} == 12 \
                && ${line[ 0]} =~ "file:" \
                && ${line[ 1]} =~ "owner:" \
                && ${line[ 2]} =~ "group:" \
                && ${line[ 3]} =~ "user:" \
                && ${line[ 4]} =~ "group:" \
                && ${line[ 5]} =~ "other:" \
                && ${line[ 6]} =~ "default:user:" \
                && ${line[ 7]} =~ "default:user:$uid:" \
                && ${line[ 8]} =~ "default:group:" \
                && ${line[ 9]} =~ "default:mask:" \
                && ${line[10]} =~ "default:other:" \
                && ${line[11]}x == x \
            ]] \
        && grep -qe "#effective:" result 
    CHECK_RESULT $? 0 0 "L$LINENO: -e No Pass"
   
    ### -E ###
    getfacl -E dir > result \
        && mapfile -t line < result \
        && [[ ${#line[@]} == 12 \
                && ${line[ 0]} =~ "file:" \
                && ${line[ 1]} =~ "owner:" \
                && ${line[ 2]} =~ "group:" \
                && ${line[ 3]} =~ "user:" \
                && ${line[ 4]} =~ "group:" \
                && ${line[ 5]} =~ "other:" \
                && ${line[ 6]} =~ "default:user:" \
                && ${line[ 7]} =~ "default:user:$uid:" \
                && ${line[ 8]} =~ "default:group:" \
                && ${line[ 9]} =~ "default:mask:" \
                && ${line[10]} =~ "default:other:" \
                && ${line[11]}x == x \
            ]] \
        && grep -qe "#effective:" result 
    CHECK_RESULT $? 1 0 "L$LINENO: -E No Pass"
   
    ### -s ###
    getfacl -s file dir  > result \
        && grep -qe "# file: file" result
    CHECK_RESULT $? 1 0 "L$LINENO: -s No Pass"

    ### -R ###
    getfacl -R dir  > result \
        && grep -qe "# file: dir/subdir" result
    CHECK_RESULT $? 0 0 "L$LINENO: -R No Pass"

    ### -L ###
    getfacl -L filelink  > result \
        && grep -qe "# file: filelink" result
    CHECK_RESULT $? 0 0 "L$LINENO: -L No Pass"

    ### -P ###
    getfacl -P filelink  > result \
        && [[ $(cat result)x == x ]]
    CHECK_RESULT $? 0 0 "L$LINENO: -P No Pass"

    ### -t ###
    getfacl -t file > result \
        && mapfile -t line < result \
        && [[ ${#line[@]} == 5 \
                && ${line[0]} =~ "file: file" \
                && ${line[1]} =~ "USER " \
                && ${line[2]} =~ "GROUP " \
                && ${line[3]} =~ "other " \
                && ${line[4]}x == x \
            ]] 
    CHECK_RESULT $? 0 0 "L$LINENO: -t No Pass"

    ### -n ###
    getfacl -n file > result \
        && mapfile -t line < result \
        && [[ ${#line[@]} == 7 \
                && ${line[ 1]} =~ "owner:" \
                && ${line[ 2]} =~ "group:" \
           ]] 
    CHECK_RESULT $? 0 0 "L$LINENO: -n No Pass"

    ### -p ###
    curr_path=$(cd $(dirname $0) || exit 1
    pwd)
    getfacl $(curr_path)/file  > result 2>&1 \
        && grep -qe "getfacl $(curr_path)/file" result
    CHECK_RESULT $? 1 0 "L$LINENO: -p No Pass"

    ### -v ###
    getfacl -v | grep -qe "^getfacl [[:digit:]]"
    CHECK_RESULT $? 0 0 "L$LINENO: -v No Pass"
    
    ### -h ###
    getfacl -h | grep -qe "^Usage: getfacl"
    CHECK_RESULT $? 0 0 "L$LINENO: -h No Pass"
    
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    
    DNF_REMOVE 
    rm -fr file filelink dir result
    
    LOG_INFO "End to restore the test environment."
}

main "$@"
