from dataclasses import replace
import os
import argparse
from socket import timeout
import time
import paramiko
from mugen_riscv import TestEnv,TestTarget
from queue import Queue
from libs.locallibs import sftp,ssh_cmd
from threading import Thread
import threading
import subprocess
import json

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
    try:
        stat = paramiko.SFTPClient.from_transport(conn.get_transport()).lstat(remotepath)
    except:
        stat = None
    else:
        if stat.st_size == 0:
            stat = None
    finally:
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
    def __init__(self,qemuVM,targetQueue,initTarget=None):
        super(Dispatcher,self).__init__()
        self.qemuVM = qemuVM
        self.targetQueue = targetQueue
        self.initTarget = initTarget

    def run(self):
        notEmpty = True
        while notEmpty:
            if self.initTarget is not None:
                self.qemuVM.start()
                self.qemuVM.waitReady()
                self.qemuVM.runTest(self.initTarget)
                self.qemuVM.destroy()
                self.qemuVM.waitPoweroff()
                self.initTarget = None
            else:
                try:
                    target = self.targetQueue.get(block=True,timeout=2)
                except:
                    notEmpty = False
                else:
                    self.qemuVM.start()
                    self.qemuVM.waitReady()
                    self.qemuVM.runTest(target)
                    self.qemuVM.destroy()
                    self.qemuVM.waitPoweroff()


class QemuVM(object):
    def __init__(self,id=1,port=12055,user='root',password='openEuler12#$',vcpu=4,memory=4,
                 workingDir='/run/media/brsf11/30f49ecd-b387-4b8f-a70c-914110526718/VirtualMachines/RISCVoE2203Testing20220818/',
                 bkfile='openeuler-qemu.qcow2' , path='/root/GitRepo/mugen-riscv' , gene=False):
        self.id = id
        self.port = port
        self.ip = '127.0.0.1'
        self.user = user
        self.password = password
        self.vcpu=vcpu
        self.memory=memory
        self.workingDir = workingDir
        self.bkFile = bkfile
        self.drive = 'img'+str(self.id)+'.qcow2'
        self.path = path
        self.gene = gene
        if self.workingDir[-1] != '/':
            self.workingDir += '/'

    def start(self):
        if self.drive in os.listdir(self.workingDir):
            os.system('rm -f '+self.workingDir+self.drive)
        cmd = 'qemu-img create -f qcow2 -F qcow2 -b '+self.workingDir+self.bkFile+' '+self.workingDir+self.drive
        res = os.system(cmd)
        if res != 0:
            print('Failed to create cow img: '+self.drive)
            return -1
        ## Configuration
        memory_append=self.memory * 1024
        drive=self.workingDir+self.drive
        fw=self.workingDir+"fw_payload_oe_qemuvirt.elf"
        ssh_port=self.port

        cmd="qemu-system-riscv64 \
        -nographic -machine virt  \
        -smp "+str(self.vcpu)+" -m "+str(self.memory)+"G \
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
        conn = 519
        while conn == 519:
            conn = paramiko.SSHClient()
            conn.set_missing_host_key_policy(paramiko.AutoAddPolicy)
            try:
                conn.connect(self.ip, self.port, self.user, self.password, timeout=5)
            except Exception as e:
                conn = 519
        if conn != 519:
            conn.close()


    def runTest(self,testsuite):
        if self.gene:
            g = " -g"
        else:
            g = ''
        print(ssh_exec(self,'cd '+self.path+' \n echo \''+testsuite+'\' > list_temp \n python3 mugen_riscv.py -l list_temp'+g,timeout=60)[1])
        if lstat(self,self.path+'/logs_failed') is not None:
            sftp_get(self,self.path+'/logs_failed','',self.workingDir)
        if lstat(self,self.path+'/logs') is not None:
            sftp_get(self,self.path+'/logs','',self.workingDir)
        if lstat(self , self.path+'/suite2cases_out') is not None:
            sftp_get(self,self.path+'/suite2cases_out','',self.workingDir)
        sftp_get(self,self.path,'exec.log',self.workingDir+'exec_log/'+testsuite)


    def isBroken(self):
        conn = 519
        while conn == 519:
            conn = paramiko.SSHClient()
            conn.set_missing_host_key_policy(paramiko.AutoAddPolicy)
            try:
                conn.connect(self.ip, self.port, self.user, self.password, timeout=5)
            except Exception as e:
                conn = 519
                return True
        if conn != 519:
            conn.close()
        return False

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
    parser.add_argument('-x',type=int,default=1,help='Specify threads num, default is 1')
    parser.add_argument('-c',type=int,default=4,help='Specify virtual machine cores num, default is 4')
    parser.add_argument('-M',type=int,default=4,help='Specify virtual machine memory size(GB), default is 4 GB')
    parser.add_argument('-w',type=str,default='/run/media/brsf11/30f49ecd-b387-4b8f-a70c-914110526718/VirtualMachines/RISCVoE2203Testing20220818/',help='Specify working directory')
    parser.add_argument('-m','--mugen',action='store_true',help='Run native mugen test suites')
    parser.add_argument('-b',type=str,default='openeuler-qemu.qcow2',help='Specify backing file name')
    parser.add_argument('-d',type=str,default='/root/GitRepo/mugen-riscv',help='Specity mugen installed directory')
    parser.add_argument('-g','--generate',action='store_true',default=False,help='Generate testsuite json after running test')
    args = parser.parse_args()

    test_env = TestEnv()
    test_env.ClearEnv()
    test_env.PrintSuiteNum()

    if args.x <= 0 :
        print('Thread num should be greater than 0!')
        exit(-1)


    if args.list_file is not None:
        test_target = TestTarget(list_file_name=args.list_file)
        test_target.PrintTargetNum()
        test_target.CheckTargets(suite_list_mugen=test_env.suite_list_mugen,suite_list_riscv=test_env.suite_list_riscv,mugen_native=args.mugen,qemu_mode=True)
        test_target.PrintUnavalTargets()
        test_target.PrintAvalTargets()

        ports = findAvalPort(args.x)
        print(ports)

        qemuVM = []
        for i in range(args.x):
            qemuVM.append(QemuVM(i,ports[i],vcpu=args.c,memory=args.M,workingDir=args.w,bkfile=args.b,path=args.d.rstrip('/'),gene=args.generate))   
        targetQueue = Queue()
        for target in test_target.test_list:
            jsondata = json.loads(open('suite2cases/'+target+'.json','r').read())
            if len(jsondata['cases']) != 0:
                targetQueue.put(target)

        dispathcers = []
        for i in range(args.x):
            dispathcers.append(Dispatcher(qemuVM[i],targetQueue))
            dispathcers[i].start()
            time.sleep(0.5)

        isAlive = True
        isEnd = False
        while isAlive:
            tempAlive = []
            for i in range(args.x):
                if dispathcers[i].is_alive():
                    print('Thread '+str(i)+' is alive')
                    tempAlive.append(True)
                else:
                    print('Thread '+str(i)+' is dead')
                    tempAlive.append(False)
                    if not isEnd:
                        try:
                            target = targetQueue.get(block=True,timeout=2)
                        except:
                            isEnd = True
                        else:
                            dispathcers[i] = Dispatcher(qemuVM[i],targetQueue,initTarget=target)
                            dispathcers[i].start()
            isAlive = False
            for i in range(args.x):
                isAlive |= tempAlive[i]
            time.sleep(5)
            
