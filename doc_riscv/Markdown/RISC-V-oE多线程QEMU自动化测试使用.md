# RISC-V-oE多线程QEMU自动化测试使用  
- qemu_test.py(暂名)实现了自动化测试环境复原和多线程测试的功能  
## 使用方法  
- 依赖安装  
    - 依赖 ```python3``` ```python-paramiko```  
- 使用  
    ```shell  
    usage: qemu_test.py [-h] [-l list_file] [-x X] [-c C] [-M M] [-w W] [-m] [-b B]

    options:
    -h, --help    show this help message and exit
    -l list_file  Specify the test targets list
    -x X          Specify threads num, default is 1
    -c C          Specify virtual machine cores num, default is 4
    -M M          Specify virtual machine memory size(GB), default is 4 GB
    -w W          Specify working directory
    -m, --mugen   Run native mugen test suites
    -b B          Specify backing file name
    ```  
    例如
    ```shell
    python3 qemu_test.py -l lists/list_riscv -x 4
    ```
    - qemu_test.py在运行qemu虚拟机的宿主机上运行  
    - ```-x```指定运行的线程数  
    - working Directory工作目录为qemu镜像所在目录，测试运行完成后日志文件等也会传回工作目录  
    - list_file为运行的测试套列表  
    - 对于有riscv版本的测试套，测试套列表中可用原不带riscv后缀的测试套名称，脚本会自动优先匹配有后缀的版本，若想测试原测试套，可在运行qemu_test时加上```-m```参数  