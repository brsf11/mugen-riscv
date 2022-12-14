# RISC-V-oE多线程QEMU自动化测试使用  
- qemu_test.py(暂名)实现了自动化测试环境复原和多线程测试的功能  
## 使用方法  
- 依赖安装  
    - 依赖 ```python3``` ```python-paramiko```  
- 使用  
    ```shell  
    usage: qemu_test.py [-h] [-l list_file] [-x X] [-c C] [-M M] [-w W] [-m]
                        [-B B] [-K K] [-D D] [-d MUGENDIR] [-g] [-F F]

    options:
    -h, --help      show this help message and exit
    -l list_file    Specify the test targets list
    -x X            Specify threads num, default is 1
    -c C            Specify virtual machine cores num, default is 4
    -M M            Specify virtual machine memory size(GB), default is 4 GB
    -w W            Specify working directory
    -m, --mugen     Run native mugen test suites
    -B B            Specify bios
    -K K            Specify kernel
    -D D            Specify backing file name
    -d MUGENDIR     Specity mugen installed directory
    -g, --generate  Generate testsuite json after running test
    -F F            Specify test config file
    ```  
    例如
    ```shell
    python3 qemu_test.py -F test.json
    ```
    - qemu_test.py在运行qemu虚拟机的宿主机上运行  
    - 可使用-F+配置文件或使用参数指定测试的配置，运行测试必须的参数有工作目录、bios或kernel、drive文件  
    - 若需指定qemu启动参数中-bios为none，需在配置文件中写明bios项为"none"或用-B none，否则qemu启动参数中-bios会省略  
    - 不指定mugen安装目录程序默认运行测试前准备mugen环境（包括安装git、clone仓库和mugen的依赖安装及结点配置），若待测镜像已准备好mugen，需用"mugenDir"项或-d指定mugen安装目录  
    - 不指定测试列表文件程序会在测试前遍历软件源生成测试列表，要测试指定的测试套列表，需用"listFile"项或-l参数指定测试列表文件  
    - ```-x```和"threads"项指定运行的线程数  
    - ```-g```和"generate"项指定是否在测试完成后生成通过测试例的列表（格式与测试套描述文件相同）  
    - working Directory工作目录为qemu镜像所在目录，测试运行完成后日志文件等也会传回工作目录  
    - list_file为运行的测试套列表  
    - 对于有riscv版本的测试套，测试套列表中可用原不带riscv后缀的测试套名称，脚本会自动优先匹配有后缀的版本，若想测试原测试套，可在运行qemu_test时加上```-m```参数  
### 使用例  
- 使用qemu_test.py测试不需要在宿主机上安装mugen依赖  
#### 使用配置文件  
- 配置文件  
    ```json
        {
            "workingDir":"/run/media/brsf11/30f49ecd-b387-4b8f-a70c-914110526718/VirtualMachines/RISCVoE2203Testing20220926/", 
            "bios":"none",
            "kernel":"fw_payload_oe_qemuvirt.elf",
            "drive":"openeuler-qemu.qcow2",
            "threads":4,
            "cores":4,
            "memory":4,
            "mugenNative":1,
            "listFile":"lists/list_git",
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