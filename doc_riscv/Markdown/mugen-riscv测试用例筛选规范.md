# mugen-riscv测试用例筛选规范  
- mugen-riscv测试用例筛选本质上就是将通过运行测试查看结果，将mugen X86/AArch64中可直接用于RISC-V oE测试的测试用例筛选出来  
## 步骤和规范  
- 运行测试用例，首先去掉结果failed的测试用例（也需结合日志文件判断，排除例如超时的简单问题）  
    - 运行单个测试套或测试例可直接用mugen.sh，使用方法参考 [README.md](https://gitee.com/openeuler/mugen/blob/master/README.md)  
    - 运行多个测试套可以利用RISC-V oE自动化测试脚本，即runtest.py，使用方法参考 [RISC-V-oE自动化测试脚本使用.md](https://github.com/brsf11/Tarsier-Internship/blob/main/Document/RISC-V-mugen/Markdown/RISC-V-oE%E8%87%AA%E5%8A%A8%E5%8C%96%E6%B5%8B%E8%AF%95%E8%84%9A%E6%9C%AC%E4%BD%BF%E7%94%A8.md)
- 检查日志文件  
- 现阶段使用的用户模式网络配置的QEMU虚拟机不支持多节点测试和多硬盘，故目前需要排除用到多个节点和多硬盘的测试例（测试套文件中有"add disk"和"machine num"字段的，或可以结合测试用例代码判断）  
- 将一个测试套中可用的测试用例整合，形成一个新的测试套描述文件，命名为原文件名+后缀"-riscv"，之后使用自动化测试脚本运行时可仍可使用原测试套名，脚本会自动有限匹配带有riscv后缀的测试套，若想测试原测试套，可在运行runtest.py时加上```-m```参数   