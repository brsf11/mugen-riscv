# RISC-V-oE多线程QEMU自动化测试使用

- qemu_test.py 实现了自动化测试环境复原和多线程测试的功能
- 支持在 Linux 和 MacOS 操作系统环境利用 qemu 执行 mugen 自动化测试
- 支持调用 RISC-V 和 x86_64 架构的 qemu 启动虚拟机进行测试

## 使用方法
- 依赖安装
    - 依赖 ``python3`` ``python-paramiko``
    - 依赖 ``lsof`` 命令（ MacOS 环境）
    - 依赖 ``netstat`` 命令（ Linux 环境）
- 使用
    ```shell
        usage: qemu_test.py [-h] [-l list_file] [-x X] [-c C] [-M M] [-w W] [-m] [--user USER] [--password PASSWORD] [-A {riscv64,x86_64}] [-B B] [-U U] [-K K]
                            [-P P] [-I I] [-D D] [-d MUGENDIR] [-g] [--detailed] [--addDisk] [--multiMachine] [--addNic] [--bridge_ip BRIDGE_IP] [-t T] [-F F]

        options:
          -h, --help            show this help message and exit
          -l list_file          Specify the test targets list
          -x X                  Specify threads num, default is 1
          -c C                  Specify virtual machine cores num, default is 4
          -M M                  Specify virtual machine memory size(GB), default is 4 GB
          -w W                  Specify working directory
          -m, --mugen           Run native mugen test suites
          --user USER           Specify user
          --password PASSWORD   Specify password
          -A {riscv64,x86_64}   Specify the qemu architecture
          -B B                  Specify bios
          -U U                  Specify UEFI pflash
          -K K                  Specify kernel
          -P P                  Specify kernel parameters
          -I I                  Specify initrd
          -D D                  Specify backing file name
          -d MUGENDIR           Specify mugen installed directory
          -g, --generate        Generate testsuite json after running test
          --detailed            Print detailed log
          --addDisk
          --multiMachine
          --addNic
          --bridge_ip BRIDGE_IP
                                Specify the network bridge ip
          -t T                  Specify the number of generated free tap
          -F F                  Specify test config file
          --screen              Use screen command to manage qemu processes
    ```

    例如
    ```shell
    python3 qemu_test.py -F test.json
    ```

    - qemu_test.py 在运行 qemu 虚拟机的宿主机上运行
    - 可使用 ``-F`` 参数+配置文件或使用参数指定测试的配置，运行测试必须的参数有工作目录、 bios 或 kernel 、 drive 文件
    - 可使用 ``-w`` 参数或 ``"workingDir"`` 项指定运行测试的 working Directory 工作目录，工作目录为 qemu 镜像所在目录，测试运行完成后日志文件等也会传回工作目录
    - 可使用 ``-l`` 参数或 ``"listFile"`` 项指定运行的测试套列表 list_file
    - 可使用 ``-D`` 参数或 ``"drive"`` 项指定运行 qemu 所用的虚拟磁盘，该磁盘将被 ``qemu-img`` 作为 backing_file 建立实际用于启动的虚拟磁盘
    - 可使用 ``-A`` 参数或 ``"qemuArch"`` 项指定测试使用的 qemu 架构，在没有指定该参数的情况下默认为 RISC-V 架构
    - 可使用 ``-c`` 、 ``-M`` 参数或 ``"cores"`` 、 ``"memory"`` 项指定 qemu 虚拟机 CPU 核数和分配的内存大小
    - 可使用 ``-B`` 参数或 ``"bios"`` 项指定 qemu 启动使用的固件
    - 可使用 ``-U`` 参数或 ``"pflash"`` 项指定 qemu 启动使用的 UEFI 固件 pflash 原始镜像，这个参数只在 x86_64 架构下生效，且由于该镜像会存储启动信息，故每个使用 UEFI 启动的实例都将复制一个独立的 pflash 文件并在关闭时删除，原始的镜像文件并不会被更改
    - 可使用 ``-K`` 、 ``-I`` 、 ``-P`` 参数或 ``"kernel"`` 、 ``"initrd"`` 、 ``"kernelParams"`` 项在不使用固件的情况下直接从指定的内核启动，其中 ``-I`` 和 ``-P`` 是可选的，在没有指定内核参数的情况下将使用默认参数启动
    - 若需指定 qemu 启动参数中 ``-bios`` 为 ``none`` ，需在配置文件中写明 ``"bios"`` 项为 ``"none"`` 或用 ``-B none`` 参数，否则 qemu 启动参数中 ``-bios`` 会省略
    - 不指定 mugen 安装目录程序默认运行测试前准备 mugen 环境（包括安装 git 、 clone 仓库和 mugen 的依赖安装及结点配置），若待测镜像已准备好 mugen ，需用 ``"mugenDir"`` 配置项或 ``-d`` 指定 mugen 安装目录
    - 不指定测试列表文件程序会在测试前遍历软件源生成测试列表，要测试指定的测试套列表，需用 ``"listFile"`` 配置项或 ``-l`` 参数指定测试列表文件
    - 可使用 ``-x`` 参数和 ``"threads"`` 项指定运行的线程数，当参数大于 ``1`` 时将同时运行多个测试套
    - 可使用 ``--user`` 、 ``--password`` 参数或 ``"user"`` 、 ``"password"`` 项指定运行 mugen_riscv.py 的用户名和密码，用户通常为 ``root``
    - 可使用 ``-g`` 参数和 ``"generate"`` 项指定是否在调用 mugen_riscv.py 时传入 ``-g`` 参数，使其在测试完成后生成通过测试例的列表（格式与测试套描述文件相同）
    - 可使用 ``--detailed`` 参数和 ``"detailed"`` 项指定是否使 mugen 打印详细日志，该配置决定调用 mugen_riscv.py 时是否传入 ``-x`` 参数
    - 某些测试需要额外的块设备进行测试， ``--addDisk`` 和 ``"addDisk"`` 项指定是否在创建 qemu 虚拟机时根据测试的需求建立并载入额外的空虚拟磁盘和在调用 mugen_riscv.py 时传入 ``--addDisk`` 参数
    - 某些测试需要多台实例进行测试， ``--multiMachine`` 和 ``"multiMachine"`` 项指定是否在创建 qemu 虚拟机时根据测试的需求建立额外的 qemu 虚拟机实例和在调用 mugen_riscv.py 时传入 ``--multiMachine`` 参数
    - 使用多台实例进行测试时，各台实例之间需要通过网桥实现相互 ping 通， ``--addNic`` 和 ``"addNic"`` 项指定是否在创建 qemu 虚拟机时根据测试的需求以及每台实例的 IP 地址重新配置 qemu 实例的 mugen ``env.json`` 配置，和是否在调用 mugen_riscv.py 时传入 ``--addNic`` 参数，该参数依赖 ``--bridge_ip`` 和 ``-t`` 参数
    - 可使用 ``--bridge_ip`` 、 ``-t`` 参数或 ``"bridge ip"`` 、 ``"tap num"`` 项配置网桥 IP 和该连接在该网桥上的虚拟网卡数量，假设共有 50 个虚拟网卡，则虚拟网卡名称必须为 ``tap0`` ～ ``tap49``
    - 对于有 riscv 版本的测试套，测试套列表中可用原不带 riscv 后缀的测试套名称，脚本会自动优先匹配有后缀的版本，若想测试原测试套，可在运行 qemu_test.py 时加上 ``-m`` 参数或在配置文件中将 ``"mugenNative"`` 配置为 ``1``
    - 由于测试中偶现 python subprocess 性能问题，可使用 ``--screen`` 参数或将 ``"useScreen"`` 配置项配置为 ``1``，使用 screen 命令作为替代方案管理 qemu 进程

### 使用例
- 使用qemu_test.py测试不需要在宿主机上安装mugen依赖  

#### 使用配置文件  
- RISC-V 示例配置文件
    ```json
        {
            "workingDir":"/run/media/brsf11/30f49ecd-b387-4b8f-a70c-914110526718/VirtualMachines/oE-RISCV-preview-22.03-v2", 
            "bios":"none",
            "kernel":"fw_payload_oe_qemuvirt.elf",
            "drive":"mugen_ready.qcow2",
            "user":"root",
            "password":"openEuler12#$",
            "threads":4,
            "cores":4,
            "memory":4,
            "mugenNative":1,
            "detailed":1,
            "addDisk":1,
            "multiMachine":1,
            "addNic":1,
            "bridge ip":"10.0.0.1",
            "tap num":50,
            "mugenDir":"/root/mugen-riscv/",
            "listFile":"lists/previewV2part1remain3",
            "useScreen":1,
            "generate":1
        }
    ```

- x86_64 示例配置文件
    ```json
        {
            "workingDir":"/home/hachi/mugen/qemu-imgs/openEuler-23.03-V1-base-qemu-preview/",
            "qemuArch":"x86_64",
            "kernel":"vmlinuz",
            "kernelParams":"root=/dev/vda2 rw console=ttyS0 loglevel=7 selinux=0 earlycon",
            "initrd":"initrd.img",
            "drive":"mugen_ready_x86.qcow2",
            "user":"root",
            "password":"openEuler12#$",
            "threads":4,
            "cores":4,
            "memory":4,
            "mugenNative":1,
            "detailed":1,
            "addDisk":1,
            "multiMachine":1,
            "addNic":1,
            "bridge ip":"10.0.0.1",
            "tap num":50,
            "mugenDir":"/root/mugen/",
            "listFile":"lists/x86fail0_retest",
            "generate":1
        }
    ```

- x86_64 使用 UEFI 启动示例配置文件
    ```json
        {
            "workingDir":"/home/hachi/mugen/qemu-imgs/openEuler-23.09-x86_64/",
            "qemuArch":"x86_64",
            "pflash":"/usr/share/edk2-ovmf/x64/OVMF.fd",
            "drive":"mugen_ready_x86.qcow2",
            "user":"root",
            "password":"openEuler12#$",
            "threads":4,
            "cores":4,
            "memory":4,
            "mugenNative":1,
            "detailed":1,
            "addDisk":1,
            "multiMachine":1,
            "addNic":1,
            "bridge ip":"10.0.0.1",
            "tap num":50,
            "mugenDir":"/root/mugen/",
            "listFile":"lists/x86fail0_retest",
            "generate":1
        }
    ```

- 运行测试  
    ```shell
        python3 qemu_test.py -F /path/to/configFile
    ```

#### 使用参数  
- 运行测试  
    ```shell
        python3 qemu_test.py -w /run/media/brsf11/30f49ecd-b387-4b8f-a70c-914110526718/VirtualMachines/RISCVoE2203Testing20220926/ -B none -K fw_payload_oe_qemuvirt.elf -D openeuler-qemu.qcow2 -x 4 -c 4 -M 4 -m -g -l lists/list_git
    ```

#### UEFI 启动所需的 OVMF.fd

在 Archlinux 安装

```bash
sudo pacman -S edk2-ovmf
```

在 Debian 安装

```bash
sudo apt-get install ovmf
```

#### 宿主机联立网桥和虚拟网卡

这里给出一个示例演示多个 qemu 虚拟机实例配合测试所需的网桥和虚拟网卡的建立，假设要添加的网桥名为 ``br0`` ，网桥 IP 为 10.0.0.1/24 ，要加入的虚拟网卡名为 ``tap0``

```bash
sudo brctl addbr br0
sudo ip addr add 10.0.0.1/24 broadcast 10.0.0.255 dev br0
sudo ip link set dev br0 up
sudo tunctl -t tap0 -u $(whoami)
sudo ip link set dev tap0 up
sudo brctl addif br0 tap0
```

注意 qemu_test.py 脚本只使用名为 ``tap${num}`` 的网卡，而对网桥名没有特殊要求，所有虚拟网卡应当能够互相 ping 通
