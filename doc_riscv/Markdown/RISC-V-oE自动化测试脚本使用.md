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
    usage: mugen_riscv.py [-h] [-l list_file] [-m] [-a] [-g] [-f test_suite]

    options:
    -h, --help      show this help message and exit
    -l list_file    Specify the test targets list
    -m, --mugen     Run native mugen test suites
    -a, --analyze   Analyze missing testcases
    -g, --generate  Generate testsuite json after running test
    -f test_suite   Specify testsuite
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
### 使用步骤  
#### 基本使用  
- 安装mugen依赖和配置测试套环境变量（见mugen使用教程）  
- 一般测试（以下均在进行测试的系统中运行）  
    - 使用测试套列表进行测试  
        - 1.新建测试套列表文件  
            - 格式参考lists/文件夹下已有的几个测试套列表文件  
            - 将要测试的测试套名称写入测试套列表文件  
            - 建议测试套列表存放在lists/文件夹下，但理论上可以放在任何位置  
        - 2.运行测试  
            在本仓库根目录下执行  
            ```shell
                python3 mugen_riscv.py -l /path/to/list  
            ```
            /path/to/list即为测试套列表的位置，可以使用相对执行目录（即仓库根目录）的相对路径  
    - 直接指定测试套进行测试  
        直接在仓库根目录下运行  
        ```shell
            python3 mugen_riscv.py -f testsuite
        ```
        testsuite即为要运行的测试套名称  
- mugen移植开发辅助功能使用  
    - 指定运行mugen原生测试套  
        - 由于mugen只原生支持X86和AArch64，用于RISC-V时需要进行适配（我们现在正在进行这项工作），本mugen的riscv分支使用测试套文件区分已适配的测试和为适配的测试。即已适配的测试套在suite2cases/目录下会有一个对应带"-riscv"后缀的测试套描述文件  
        - mugen_riscv.py在运行测试时默认优先匹配适配后的测试套
        - 需要运行mugen原生测试套里的测试，需要在执行时加上-m参数  
            如
            ```shell
                python3 mugen_riscv.py -l /path/to/list -m
            ```
    - 使用mugen_riscv.py的适配缺失分析功能  
        - mugen_riscv.py的适配缺失分析功能用于帮助列出适配后测试套相对于mugen原生测试套缺失的测试例（即为测试套中为做移植适配的测试例）  
        - 使用  
            执行
            ```shell
                python3 mugen_riscv.py -a
            ```
            脚本会自动列出当前所有适配后测试套的缺失信息  
        - 指定测试套列表  
            ```shell
                python3 mugen_riscv.py -l /path/to/list -a
            ```
        - 指定测试套  
            ```shell
                python3 mugen_riscv.py -f testsuite -a
            ```
    - 让mugen_riscv.py执行测试后生成可用测试的测试套描述文件  
        - 移植mugen的测试需要筛选出测试套中哪些测试可以在RISC—V环境下正确运行，并将这些可用的测试整合形成一个对应的带"-riscv"后缀的测试套描述文件  
        - 判断测试是否可用的一个简单依据是测试运行结果，如果测试通过，那么一般情况下测试和被测对象本身都是正确的  
        - 因此可以让mugen_riscv.py在执行测试后将通过的测试整合，并生成对应的测试套描述文件，从而方便mugen测试移植乃至开发工作  
        - 使用  
            ```shell
                python3 mugen_riscv.py -l /path/to/list -g
            ```
            或
            ```shell
                python3 mugen_riscv.py -f testsuite -g
            ```

