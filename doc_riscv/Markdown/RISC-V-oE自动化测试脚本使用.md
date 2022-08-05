# RISC-V-oE自动化测试脚本使用  
- RISC-V oE自动化测试脚本  
    - openEuler的mugen项目目前用于openEuler x86/AArch64的测试，并不方便直接用于当前openEuler RISC-V的测试  
        - 测试项目（测试套）并不能很好地匹配  
        - 目前的openEuler RISC-V测试依靠QEMU虚拟机
    - mugen中一个测试套对应一个软件或服务，为了更方便地执行测试，可以再抽象一层  
    - 辅助测试脚本匹配测试列表和mugen中的测试套，并反馈缺失的测试和执行可用测试  
## 使用方法  
- 依赖安装  
    - 依赖 ```tqdm```  
    - 使用 
        ```shell  
        pip3 install tqdm
        ```   
        或   
        ```shell  
        dnf install python3-tqdm
        ```  
        推荐使用后者  
- 使用  
    ```shell  
    python3 runtest.py list_file
    ```  
    - list_file为运行的测试套列表  
    - 对于有riscv版本的测试套，测试套列表中可用原不带riscv后缀的测试套名称，脚本会自动优先匹配有后缀的版本，若想测试原测试套，可在运行runtest.py时加上```-m```参数  
    - 测试套列表文件格式可参考已有的列表文件  