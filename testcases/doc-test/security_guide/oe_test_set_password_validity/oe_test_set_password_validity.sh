# @Author    :   huyahui
# @Contact   :   huyahui8@163.com
# @Date      :   2020/05/28
# @License   :   Mulan PSL v2
# @Desc      :   Set password validity
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    cp /etc/login.defs /etc/login.defs-bak
    grep "^test:" /etc/passwd && userdel -rf test
    ls log && rm -rf log
    ls testlog && rm -rf testlog
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    sed -i 's/PASS_MAX_DAYS\t99999/PASS_MAX_DAYS   5/g' /etc/login.defs
    sed -i 's/PASS_WARN_AGE\t7/PASS_WARN_AGE   2/g' /etc/login.defs
    useradd test
    passwd test <<EOF
${NODE1_PASSWORD}
${NODE1_PASSWORD}
EOF
    date -s '4 day'
    rm -rf /root/.ssh/known_hosts

    expect <<EOF1
        log_file testlog
        set timeout 15
        spawn ssh test@127.0.0.1
        expect {
               "*yes/no*" {
               send "yes\\r"
               }
        }
        expect {
               "assword:" {
               send "${NODE1_PASSWORD}\\r"
               }
        }
        expect {
               "]" {
               send "exit\\r"
               }
        }
        expect eof
EOF1
    grep 'your password will expire in 1 day' testlog
    CHECK_RESULT $?
    date -s '2 day'
    expect <<EOF1
        set timeout 15
        log_file log
        spawn ssh test@127.0.0.1
        expect {
               "*yes/no*" {
                send "yes\\r"
                }
        }
        expect {
                "assword:" {
                send "${NODE1_PASSWORD}\\r"
                }
        }
        expect {
                "assword:" {
                send "${NODE1_PASSWORD}\\r"
                }
        }
        expect {
                "assword:" {
                send "Administritor45##\\r"
                }
        }
        expect {
                "assword:" {
                send "Administritor45##\\r"
                }
        }
        expect {
                "]" {
                send "exit\\r"
                }
        }
        expect eof
EOF1
    grep 'Current password' log && grep 'all authentication tokens updated successfully' log
    CHECK_RESULT $?
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf log testlog /run/faillock/test
    userdel -rf test
    mv /etc/login.defs-bak /etc/login.defs -f
    date -s '-6 day'
    LOG_INFO "Finish environment cleanup!"
}

main "$@"

