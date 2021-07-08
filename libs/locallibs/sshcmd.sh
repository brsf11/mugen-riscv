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
#@Date      	:   2020-04-08 16:13:40
#@License   	:   Mulan PSL v2
#@Version   	:   1.0
#@Desc      	:   Encapsulate ssh, user t directly, and execute remote commands
####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function sshcmd() {
    cmd=$1
    remoteip=$2
    remotepasswd=${3}
    remoteuser=${4}
    timeout=${5}
    connport=${6}

    test "$cmd"x = ""x && LOG_ERROR "Lack of execute command." && exit 1
    cmd=${cmd//\$/\\\$}

    test "$remoteip"x = ""x && LOG_ERROR "Missing ip."
    test "$(echo ${remoteip} | awk -F"." '{if ($1!=0 && $NF!=0) split ($0,IPNUM,".")} END { for (k in IPNUM) if (IPNUM[k]==0) print IPNUM[k]; else if (IPNUM[k]!=0 && IPNUM[k]!~/[a-z|A-Z]/ && length(IPNUM[k])<=3 && IPNUM[k]<255 && IPNUM[k]!~/^0/) print IPNUM[k]}' | wc -l)" -ne 4 && LOG_ERROR "the remote ip is Incorrect." && exit 1
    if ping -c 1 ${remoteip} | grep "100% packet loss"; then
        LOG_ERROR "connection to $remoteip failed."
        exit 101
    fi

    test "$remoteuser"x = "root"x && LOG_WARN "the remote user uses the default configuration."

    test "$remotepasswd"x = "openEuler12#$"x && LOG_WARN "the remote password uses the default configuration."

    test "$timeout"x = "15"x && LOG_WARN "the timeout uses the default configuration."

    test "$connport"x = "22"x && LOG_WARN "the connect port using the default configuration"

    cmd_last_world=$(echo ${cmd} | awk '{print $NF}')

    e_time=${timeout}

    test "$cmd_last_world"x == "&"x && {
        timeout=0
        e_time=-1
    }

    expect <<-EOF

    set timeout ${e_time}
         
    spawn ssh -o "ConnectTimeout=${timeout}"  -p ${connport} ${remoteuser}@${remoteip} "$cmd"

        expect {
            "Are you sure you want to continue connecting*"
            {
                send "yes\r"
                expect "*\[P|p]assword:"
                send "${remotepasswd}\r"
            }
            "*\[P|p]assword:"
            {
                send "${remotepasswd}\r"
            }
            timeout 
            {
                end_user "connection to $remoteip timed out: \$expect_out(buffer)\n"
                exit 101
        	}
            eof 
            {
                catch wait result
                exit [lindex \$result 3] 
            }
        }
        expect {
            eof {
                catch wait result
                exit [lindex \$result 3] 
            }
            "\[P|p]assword:" 
            {
                send_user "invalid password or account again.\$expect_out(buffer)\n"
                send "${remotepasswd}\r"
            }
            timeout 
            {
                send_user "connection to $remoteip timed out: \$expect_out(buffer)\n"
                exit 101
            }
        }
    }
EOF
    exit $?
}

usage() {
    printf "Usage: sshcmd.sh -c \"command\" -i \"remote machinet ip\" [-u login_user] [-p login_password] [-o port] [-t timeout]"
}

while getopts "c:i:p:u:t:o:h" OPTIONS; do
    case $OPTIONS in
    c) cmd="$OPTARG" ;;
    i) remoteip="$OPTARG" ;;
    u) remoteuser="$OPTARG" ;;
    p) remotepasswd="$OPTARG" ;;
    t) timeout="$OPTARG" ;;
    o) connport="$OPTARG" ;;
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

if [ "$cmd"x = ""x ] || [ "$remoteip"x = ""x ]; then
    usage
    exit 1
fi

sshcmd "$cmd" "$remoteip" "${remotepasswd-openEuler12#$}" "${remoteuser-root}" "${timeout-300}" "${connport-22}"

exit $?
