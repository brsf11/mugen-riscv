#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   saarloos
# @Contact   :   9090-90-90-9090@163.com
# @Modify    :   9090-90-90-9090@163.com
# @Date      :   2022/06/23
# @License   :   Mulan PSL v2
# @Desc      :   check embedded tiny image
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function run_test() {
    LOG_INFO "Start to run test."

    qemu-system-aarch64 --version
    CHECK_RESULT $? 0 0 "qemu-system-aarch64 not install please run '${OET_PATH}/dep_install.sh -e' first"

    outputdir="${FIND_TINY_DIR}"
    if [ -z ${outputdir} ]; then
        outputdir="/usr1/output"
    fi

    machineName="${RUN_QEMU_MACHINE}"
    if [ -z ${machineName} ]; then
        machineName="virt-4.0"
    fi

    cpuName="${RUN_QEMU_CPU}"
    if [ -z ${cpuName} ]; then
        cpuName="cortex-a57"
    fi

    zImage_path=$(find ${outputdir} -name "zImage")
    initrd_path=$(find ${outputdir} -name "openeuler-image-*qemu-*.rootfs.cpio.gz")

    expect <<-EOF
        set timeout 30

        spawn qemu-system-aarch64 -M ${machineName} -cpu ${cpuName} -m 2048M -nographic -kernel ${zImage_path} -initrd ${initrd_path}

        expect {
            "login:" {
                send "root\n"
                expect "# "
                send "busybox\n"
                expect {
                    "BusyBox v*" { exit 0 }
                    timeout { exit 1 }
                }
            }
            timeout {
                send "\n"
                expect "# "
                send "busybox\n"
                expect {
                    "BusyBox v*" { exit 0 }
                    timeout { exit 1 }
                }
            }
            eof {
                catch wait result
                exit [lindex \$result 3]
            }
        }
EOF

    CHECK_RESULT $? 0 0 "aarch64 tiny image test fail"

    LOG_INFO "End to run test."
}

main "$@"