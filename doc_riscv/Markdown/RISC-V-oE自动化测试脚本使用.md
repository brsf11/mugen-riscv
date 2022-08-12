# RISC-V-oE自动化测试脚本使用  
- RISC-V oE自动化测试脚本  
    - openEuler的mugen项目目前用于openEuler x86/AArch64的测试，并不方便直接用于当前openEuler RISC-V的测试  
        - 测试项目（测试套）并不能很好地匹配  
        - 目前的openEuler RISC-V测试依靠QEMU虚拟机
    - mugen中一个测试套对应一个软件或服务，为了更方便地执行测试，可以再抽象一层  
    - 辅助测试脚本匹配测试列表和mugen中的测试套，并反馈缺失的测试和执行可用测试  
## 使用方法  
- 依赖安装  
    - 依赖 ```python3```  
- 使用  
    ```shell  
    usage: mugen_riscv.py [-h] [-l list_file] [-m] [-a] [-s ana_suite] [-g]

    optional arguments:
    -h, --help      show this help message and exit
    -l list_file    Specify the test targets list
    -m, --mugen     Run native mugen test suites
    -a, --analyze   Analyze missing testcases
    -s ana_suite    Analyze missing testcases of specific testsuite
    -g, --generate  Generate testsuite json after running test
    ```  
    例如
    ```shell
    python3 mugen_riscv.py -l lists/list_riscv
    ```
    - list_file为运行的测试套列表  
    - 对于有riscv版本的测试套，测试套列表中可用原不带riscv后缀的测试套名称，脚本会自动优先匹配有后缀的版本，若想测试原测试套，可在运行runtest.py时加上```-m```参数  
    - 测试套列表文件格式可参考已有的列表文件  
    - 查找riscv测试套相比对应mugen原生测试套缺失的测试例可使用```-a```参数，```-s```用于指定测试套  
    - ```-g```用于在运行测试后保留测试套中通过的测试用例，并以测试套配置文件的格式输出  