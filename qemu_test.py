from dataclasses import replace
import os
import argparse
import time
import paramiko
from mugen_riscv import TestEnv,TestTarget
from queue import Queue
from libs.locallibs import sftp,ssh_cmd
from threading import Thread
import subprocess

def ssh_exec(qemuVM,cmd,timeout=5):
    conn = paramiko.SSHClient()
    conn.set_missing_host_key_policy(paramiko.AutoAddPolicy)
    conn.connect(qemuVM.ip,qemuVM.port,qemuVM.user,qemuVM.password,timeout=timeout,allow_agent=False,look_for_keys=False)
    exitcode,output = ssh_cmd.pssh_cmd(conn,cmd)
    ssh_cmd.pssh_close(conn)
    return exitcode,output

def sftp_get(qemuVM,remotedir,remotefile,localdir,timeout=5):
    conn = paramiko.SSHClient()
    conn.set_missing_host_key_policy(paramiko.AutoAddPolicy)
    conn.connect(qemuVM.ip,qemuVM.port,qemuVM.user,qemuVM.password,timeout=timeout,allow_agent=False,look_for_keys=False)
    sftp.psftp_get(conn,remotedir,remotefile,localdir)

def lstat(qemuVM,remotepath,timeout=5):
    conn = paramiko.SSHClient()
    conn.set_missing_host_key_policy(paramiko.AutoAddPolicy)
    conn.connect(qemuVM.ip,qemuVM.port,qemuVM.user,qemuVM.password,timeout=timeout,allow_agent=False,look_for_keys=False)
    stat = paramiko.SFTPClient.from_transport(conn.get_transport()).lstat(remotepath)
    ssh_cmd.pssh_close(conn)
    return stat

def findAvalPort(num=1):
    port_list = []
    port = 12055
    while(len(port_list) != num):
        if os.system('netstat -anp 2>&1 | grep '+str(port)+' > /dev/null') != 0:
            port_list.append(port)
        port += 1
    return port_list

class Dispatcher(Thread):
    def __init__(self,qemuVM,targetQueue):
        super(Dispatcher,self).__init__()
        self.qemuVM = qemuVM
        self.targetQueue = targetQueue

    def run(self):
        while self.targetQueue.empty() == False:
            self.qemuVM.start()
            self.qemuVM.waitReady()
            self.qemuVM.runTest(self.targetQueue.get())
            self.qemuVM.destroy()
            self.qemuVM.waitPoweroff()


class QemuVM(object):
    def __init__(self,id=1,port=12055):
        self.id = id
        self.port = port
        self.ip = '127.0.0.1'
        self.user = 'root'
        self.password = 'openEuler12#$'
        self.workingDir = '/home/brsf11/Hdd/VirtualMachines/RISCVoE2203Testing20220818/'
        self.bkFile = 'openeuler-qemu.qcow2'
        self.drive = 'img'+str(self.id)+'.qcow2'

    def start(self):
        if self.drive in os.listdir(self.workingDir):
            os.system('rm -f '+self.workingDir+self.drive)
        cmd = 'qemu-img create -f qcow2 -F qcow2 -b '+self.workingDir+self.bkFile+' '+self.workingDir+self.drive
        res = os.system(cmd)
        if res != 0:
            print('Failed to create cow img: '+self.drive)
            return -1
        ## Configuration
        vcpu=2
        memory=2
        memory_append=memory * 1024
        drive=self.workingDir+self.drive
        fw=self.workingDir+"fw_payload_oe_qemuvirt.elf"
        ssh_port=self.port

        cmd="qemu-system-riscv64 \
        -nographic -machine virt  \
        -smp "+str(vcpu)+" -m "+str(memory)+"G \
        -audiodev pa,id=snd0 \
        -kernel "+fw+" \
        -bios none \
        -drive file="+drive+",format=qcow2,id=hd0 \
        -object rng-random,filename=/dev/urandom,id=rng0 \
        -device virtio-rng-device,rng=rng0 \
        -device virtio-blk-device,drive=hd0 \
        -device virtio-net-device,netdev=usernet \
        -netdev user,id=usernet,hostfwd=tcp::"+str(ssh_port)+"-:22 \
        -device qemu-xhci -usb -device usb-kbd -device usb-tablet -device usb-audio,audiodev=snd0 \
        -append 'root=/dev/vda1 rw console=ttyS0 swiotlb=1 loglevel=3 systemd.default_timeout_start_sec=600 selinux=0 highres=off mem="+str(memory_append)+"M earlycon' "

        self.process = subprocess.Popen(args=cmd,stderr=subprocess.PIPE,stdout=subprocess.PIPE,stdin=subprocess.PIPE,encoding='utf-8',shell=True)

    def waitReady(self):
        time.sleep(1)
        conn = paramiko.SSHClient()
        conn.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        conn.connect(self.ip,self.port,self.user,self.password,timeout=20,banner_timeout=20,auth_timeout=20,allow_agent=False,look_for_keys=False)
        print('Yes!')
        conn.close()


    def runTest(self,testsuite):
        print(ssh_exec(self,'cd /root/GitRepo/mugen-riscv \n echo \''+testsuite+'\' > list_temp \n python3 mugen_riscv.py -l list_temp -g',timeout=60)[1])
        if lstat(self,'/root/GitRepo/mugen-riscv/logs_failed').st_size != 0:
            sftp_get(self,'/root/GitRepo/mugen-riscv/logs_failed','',self.workingDir)
        if lstat(self,'/root/GitRepo/mugen-riscv/logs').st_size != 0:
            sftp_get(self,'/root/GitRepo/mugen-riscv/logs','',self.workingDir)
        if lstat(self,'/root/GitRepo/mugen-riscv/suite2cases_out').st_size != 0:
            sftp_get(self,'/root/GitRepo/mugen-riscv/suite2cases_out','',self.workingDir)
        sftp_get(self,'/root/GitRepo/mugen-riscv/','exec.log',self.workingDir+'exec_log/'+testsuite)

    def waitPoweroff(self):
        self.process.wait()
        while os.system('netstat -anp 2>&1 | grep '+str(self.port)+' > /dev/null') == 0:
            time.sleep(1)

    def destroy(self):
        ssh_exec(self,'poweroff')
        os.system('rm -f '+self.workingDir+self.drive)

        

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-l',metavar='list_file',help='Specify the test targets list',dest='list_file')
    parser.add_argument('-m','--mugen',action='store_true',help='Run native mugen test suites')
    parser.add_argument('-a','--analyze',action='store_true',help='Analyze missing testcases')
    parser.add_argument('-s',metavar='ana_suite',help='Analyze missing testcases of specific testsuite',dest='ana_suite')
    parser.add_argument('-g','--generate',action='store_true',help='Generate testsuite json after running test')
    parser.add_argument('-x',type=int,default=1,help='Specify threads num')
    args = parser.parse_args()

    test_env = TestEnv()
    test_env.ClearEnv()
    test_env.PrintSuiteNum()

    if args.x <= 0 :
        print('Thread num should be greater than 0!')
        exit(-1)

    if args.analyze is True:
        if args.ana_suite is not None:
            test_env.AnalyzeMissingTests(args.ana_suite)
        else:
            test_env.AnalyzeMissingTests()

    if args.list_file is not None:
        test_target = TestTarget(list_file_name=args.list_file)
        test_target.PrintTargetNum()
        test_target.CheckTargets(suite_list_mugen=test_env.suite_list_mugen,suite_list_riscv=test_env.suite_list_riscv,mugen_native=args.mugen,qemu_mode=True)
        test_target.PrintUnavalTargets()
        test_target.PrintAvalTargets()

        # qemuvm = QemuVM()
        # qemuvm.start()
        # qemuvm.waitReady()
        # qemuvm.destroy()
        # # qemuvm.waitPoweroff()
        # # qemuvm.start()
        # # qemuvm.waitReady()
        # # qemuvm.destroy()

        ports = findAvalPort(args.x)
        print(ports)

        qemuVM = []
        for i in range(args.x):
            qemuVM.append(QemuVM(i,ports[i]))   
        targetQueue = Queue()
        for target in test_target.test_list:
            targetQueue.put(target)

        dispathcers = []
        for i in range(args.x):
            dispathcers.append(Dispatcher(qemuVM[i],targetQueue))
            dispathcers[i].start()