#!/usr/bin/bash
# Copyright (c) [2020] Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author    	:   lemon.higgins
#@Contact   	:   lemon.higgins@aliyun.com
#@Date      	:   2020-04-09 17:58:35
#@License   	:   Mulan PSL v2
#@Version   	:   1.0
#@Desc      	:   封装scp命令，供文件传输使用
####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function sshscp() {
    src=$1
    dest=$2
    remotepasswd=${3-openEuler12#$}
    connport=${4-22}

    test "$src"x = ""x && LOG_ERROR "No transfer file provided." && exit 1

    test "$dest"x = ""x && LOG_ERROR "No file storage path provided." && exit 1

    test "$remotepasswd"x = "openEuler12#$"x && LOG_WARN "the remote password uses the default configuration."

    test "$connport"x = "22"x && LOG_WARN "the connect port using the default configuration"

    expect <<-EOF
        set timeout -1
        spawn scp -P $connport -r $src $dest
        expect {
            "Are you sure you want to continue connecting*"
            {
                send "yes\r"
                expect "\[P|p]assword:"
                send "${remotepasswd}\r"
            }
            -re "\[P|p]assword:" 
            {
                send "${remotepasswd}\r"
            }
            timeout 
            {
                send_user "connection to remote timed out: \$expect_out(buffer)\n"
                exit 101
            }
            eof
            {
                catch wait result
                exit [lindex \$result 3] 
            }
        }
        expect {
            eof 
            {
                catch wait result
                exit [lindex \$result 3]
            }
            -re "\[P|p]assword:" 
            {
                send_user "invalid password or account. \$expect_out(buffer)\n"
                exit 13
            }
            timeout 
            {
                send_user "connection to remote timed out : \$expect_out(buffer)\n"
                exit 101
            }
        }
EOF
    exit $?
}

usage() {
    printf "Usage: sshscp.sh -s src(user@ip:path) -d destination((user@ip:path)) [-p login_password] [-o port] -r -t timeout"
}

while getopts "p:s:d:o:h" OPTIONS; do
    case $OPTIONS in
    p) remotepasswd="$OPTARG" ;;
    s) src="$OPTARG" ;;
    d) dest="$OPTARG" ;;
    o) connport="$OPTARG" ;;
    h)
        usage
        exit 1
        ;;
    \?)
        printf "ERROR - Invalid parameter" >&2
        usage
        exit 1
        ;;
    *)
        printf "ERROR - Invalid parameter" >&2
        usage
        exit 1
        ;;
    esac
done

sshscp "$src" "$dest" "$remotepasswd" "$connport"
exit $?
