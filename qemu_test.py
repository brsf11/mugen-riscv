from dataclasses import replace
import os
import sys
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
    try:
        conn.connect(qemuVM.ip,qemuVM.port,qemuVM.user,qemuVM.password,timeout=timeout,allow_agent=False,look_for_keys=False)
        exitcode,output = ssh_cmd.pssh_cmd(conn,cmd)
        ssh_cmd.pssh_close(conn)
    except :
        print("ssh execute "+cmd+" failed")
        exitcode , output = None , None
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

def isCommandExist(cmd):
    from shutil import which
    return which(cmd) is not None

def findAvalPort(num=1):
    port_list = []
    port = 12055

    if isCommandExist('lsof'):
        pre_cmd = 'lsof -i :'
    elif isCommandExist('netstat') and sys.platform == 'linux':
        pre_cmd = 'netstat -anp 2>&1 | grep '
    else:
        sys.exit('Cannot find lsof or netstat command!')

    while len(port_list) != num:
        if os.system(pre_cmd + str(port) + ' > /dev/null') != 0:
            port_list.append(port)

        port += 1

    return port_list


class Dispatcher(Thread):
    def __init__(self,qemuVM,targetQueue,tapQueue,br_ip,step,initTarget=None):
        super(Dispatcher,self).__init__()
        self.qemuVM = qemuVM
        self.targetQueue = targetQueue
        self.initTarget = initTarget
        self.tapQueue = tapQueue
        self.step = step
        self.br_ip = br_ip
        self.attachVM = []

    def run(self):
        notEmpty = True
        while notEmpty:
            if self.initTarget is not None:
                tapnum = 0
                if self.initTarget[2] > 1 and self.qemuVM.runArgs.find('multiMachine') != -1:
                    if self.initTarget[3] > 1 and self.qemuVM.runArgs.find('addNic') != -1:
                        tapnum = self.initTarget[2]*(self.initTarget[3]+1)
                        if tapnum > self.tapQueue.qsize():
                            self.targetQueue.put(self.initTarget)
                        else:
                            self.qemuVM.start(disk=self.initTarget[1],machine=self.initTarget[2],tap_number=self.initTarget[3]+1,taplist=[self.tapQueue.get() for i in range(self.initTarget[3]+1)])
                            self.qemuVM.waitReady()
                            for i in range(1 , self.initTarget[2]):
                                self.attachVM.append(QemuVM(id= i*self.step+self.qemuVM.id, vcpu=self.qemuVM.vcpu , memory=self.qemuVM.memory,
                                                            user=self.qemuVM.user , password=self.qemuVM.password,
                                                            arch=self.qemuVM.arch, initrd=self.qemuVM.initrd,
                                                            kernel=self.qemuVM.kernel, kparms=self.qemuVM.kparms, bios=self.qemuVM.bios, pflash=self.qemuVM.pflash,
                                                            workingDir=self.qemuVM.workingDir , bkfile=self.qemuVM.bkFile , path=self.qemuVM.path, screen=self.qemuVM.screen,
                                                            ))
                                self.attachVM[i-1].start(disk=self.initTarget[1],machine=self.initTarget[2],tap_number=self.initTarget[3]+1,taplist=[self.tapQueue.get() for i in range(self.initTarget[3]+1)])
                                self.attachVM[i-1].waitReady()
                                self.attachVM[i-1].conftap(br_ip = self.br_ip)
                            self.qemuVM.conftap(br_ip = self.br_ip , tapnode = ['.'.join(self.br_ip.split(".")[:-1]+[str(self.attachVM[i].id+1)]) for i in range(self.initTarget[2]-1)])
                            try:
                                self.qemuVM.runTest(self.initTarget[0])
                            except:
                                print("error "+self.initTarget[0])
                            else:
                                self.qemuVM.destroy()
                                self.qemuVM.waitPoweroff()
                            finally:
                                while len(self.qemuVM.tapls) > 0:
                                    self.tapQueue.put(self.qemuVM.tapls.pop())
                            while len(self.attachVM) > 0:
                                self.attachVM[-1].destroy()
                                self.attachVM[-1].waitPoweroff()
                                while len(self.attachVM[-1].tapls) > 0:
                                    self.tapQueue.put(self.attachVM[-1].tapls.pop())
                                self.attachVM.pop()
                    else:
                        tapnum = self.initTarget[2]
                        if tapnum > self.tapQueue.qsize():
                            self.targetQueue.put(self.initTarget)
                        else:
                            self.qemuVM.start(disk=self.initTarget[1],machine=self.initTarget[2],tap_number=1,taplist=[self.tapQueue.get()])
                            self.qemuVM.waitReady()
                            ports = findAvalPort(self.initTarget[2]-1)
                            print(ports)
                            for i in range(1 , self.initTarget[2]):
                                self.attachVM.append(QemuVM(id= i*self.step+self.qemuVM.id, vcpu=self.qemuVM.vcpu , memory=self.qemuVM.memory,
                                                            user=self.qemuVM.user , password=self.qemuVM.password,
                                                            arch=self.qemuVM.arch, initrd=self.qemuVM.initrd,
                                                            kernel=self.qemuVM.kernel, kparms=self.qemuVM.kparms, bios=self.qemuVM.bios, pflash=self.qemuVM.pflash,
                                                            workingDir=self.qemuVM.workingDir , bkfile=self.qemuVM.bkFile , path=self.qemuVM.path, screen=self.qemuVM.screen,
                                                            ))
                                self.attachVM[i-1].start(disk=self.initTarget[1],machine=self.initTarget[2],tap_number=1,taplist=[self.tapQueue.get()])
                                self.attachVM[i-1].waitReady()
                                self.attachVM[i-1].conftap(br_ip = self.br_ip)
                            self.qemuVM.conftap(br_ip = self.br_ip , tapnode = ['.'.join(self.br_ip.split(".")[:-1]+[str(self.attachVM[i].id+1)]) for i in range(self.initTarget[2]-1)])
                            try:
                                self.qemuVM.runTest(self.initTarget[0])
                            except:
                                print("error "+self.initTarget[0])
                            else:
                                self.qemuVM.destroy()
                                self.qemuVM.waitPoweroff()
                            finally:
                                while len(self.qemuVM.tapls) > 0:
                                    self.tapQueue.put(self.qemuVM.tapls.pop())
                            while len(self.attachVM) > 0:
                                self.attachVM[-1].destroy()
                                self.attachVM[-1].waitPoweroff()
                                while len(self.attachVM[-1].tapls) > 0:
                                    self.tapQueue.put(self.attachVM[-1].tapls.pop())
                                self.attachVM.pop()
                else:
                    if self.initTarget[3] > 1 and self.qemuVM.runArgs.find('addNic') != -1:
                        tapnum = self.initTarget[3]
                        if tapnum > self.tapQueue.qsize():
                            self.targetQueue.put(self.initTarget)
                        else:
                            self.qemuVM.start(disk=self.initTarget[1],machine=self.initTarget[2],tap_number=self.initTarget[3],taplist=[self.tapQueue.get() for i in range(tapnum)])
                            self.qemuVM.waitReady()
                            try:
                                self.qemuVM.runTest(self.initTarget[0])
                            except:
                                print("error "+self.initTarget[0])
                            else:
                                self.qemuVM.destroy()
                                self.qemuVM.waitPoweroff()
                            while len(self.qemuVM.tapls) > 0:
                                self.tapQueue.put(self.qemuVM.tapls.pop())
                    else:
                        self.qemuVM.start(disk=self.initTarget[1])
                        self.qemuVM.waitReady()
                        try:
                            self.qemuVM.runTest(self.initTarget[0])
                        except:
                            print("error "+self.initTarget[0])
                        else:
                            self.qemuVM.destroy()
                            self.qemuVM.waitPoweroff()
                self.initTarget = None
            else:
                try:
                    target = self.targetQueue.get(block=True,timeout=2)
                except:
                    notEmpty = False
                else:
                    if target[2] > 1 and self.qemuVM.runArgs.find('multiMachine') != -1:
                        if target[3] > 1 and self.qemuVM.runArgs.find('addNic') != -1:
                            tapnum = target[2]*(target[3]+1)
                            if tapnum > self.tapQueue.qsize():
                                self.targetQueue.put(target)
                            else:
                                self.qemuVM.start(disk=target[1],machine=target[2],tap_number=target[3]+1,taplist=[self.tapQueue.get() for i in range(target[3]+1)])
                                self.qemuVM.waitReady()
                                ports = findAvalPort(target[2]-1)
                                print(ports)
                                for i in range(1 , target[2]):
                                    self.attachVM.append(QemuVM(id= i*self.step+self.qemuVM.id, vcpu=self.qemuVM.vcpu , memory=self.qemuVM.memory,
                                                                user=self.qemuVM.user , password=self.qemuVM.password,
                                                                arch=self.qemuVM.arch, initrd=self.qemuVM.initrd,
                                                                kernel=self.qemuVM.kernel, kparms=self.qemuVM.kparms, bios=self.qemuVM.bios, pflash=self.qemuVM.pflash,
                                                                workingDir=self.qemuVM.workingDir , bkfile=self.qemuVM.bkFile , path=self.qemuVM.path, screen=self.qemuVM.screen,
                                                                ))
                                    self.attachVM[i-1].start(disk=target[1],machine=target[2],tap_number=target[3]+1,taplist=[self.tapQueue.get() for i in range(target[3]+1)])
                                    self.attachVM[i-1].waitReady()
                                    self.attachVM[i-1].conftap(br_ip = self.br_ip)
                                self.qemuVM.conftap(br_ip = self.br_ip , tapnode = ['.'.join(self.br_ip.split(".")[:-1]+[str(self.attachVM[i].id+1)]) for i in range(target[2]-1)])
                                try:
                                    self.qemuVM.runTest(target[0])
                                except:
                                    print("error "+target[0])
                                else:
                                    self.qemuVM.destroy()
                                    self.qemuVM.waitPoweroff()
                                while len(self.attachVM) > 0:
                                    self.attachVM[-1].destroy()
                                    self.attachVM[-1].waitPoweroff()
                                    while len(self.attachVM[-1].tapls) > 0:
                                        self.tapQueue.put(self.attachVM[-1].tapls.pop())
                                    self.attachVM.pop()
                                while len(self.qemuVM.tapls) > 0:
                                    self.tapQueue.put(self.qemuVM.tapls.pop())
                        else:
                            tapnum = target[2]
                            if tapnum > self.tapQueue.qsize():
                                self.targetQueue.put(target)
                            else:
                                self.qemuVM.start(disk=target[1],machine=target[2],tap_number=1,taplist=[self.tapQueue.get()])
                                self.qemuVM.waitReady()
                                for i in range(1 , target[2]):
                                    self.attachVM.append(QemuVM(id= i*self.step+self.qemuVM.id, vcpu=self.qemuVM.vcpu , memory=self.qemuVM.memory,
                                                                user=self.qemuVM.user , password=self.qemuVM.password,
                                                                arch=self.qemuVM.arch, initrd=self.qemuVM.initrd,
                                                                kernel=self.qemuVM.kernel, kparms=self.qemuVM.kparms, bios=self.qemuVM.bios, pflash=self.qemuVM.pflash,
                                                                workingDir=self.qemuVM.workingDir , bkfile=self.qemuVM.bkFile , path=self.qemuVM.path, screen=self.qemuVM.screen,
                                                                ))
                                    self.attachVM[i-1].start(disk=target[1],machine=target[2],tap_number=1,taplist=[self.tapQueue.get()])
                                    self.attachVM[i-1].waitReady()
                                    self.attachVM[i-1].conftap(br_ip = self.br_ip)
                                self.qemuVM.conftap(br_ip = self.br_ip , tapnode = ['.'.join(self.br_ip.split(".")[:-1]+[str(self.attachVM[i].id+1)]) for i in range(target[2]-1)])
                                try:
                                    self.qemuVM.runTest(target[0])
                                except:
                                    print("error "+target[0])
                                else:
                                    self.qemuVM.destroy()
                                    self.qemuVM.waitPoweroff()
                                while len(self.attachVM) > 0:
                                    self.attachVM[-1].destroy()
                                    self.attachVM[-1].waitPoweroff()
                                    while len(self.attachVM[-1].tapls) > 0:
                                        self.tapQueue.put(self.attachVM[-1].tapls.pop())
                                    self.attachVM.pop()
                                while len(self.qemuVM.tapls) > 0:
                                    self.tapQueue.put(self.qemuVM.tapls.pop())
                    else:
                        if target[3] > 1 and self.qemuVM.runArgs.find('addNic') != -1:
                            tapnum = target[3]
                            if tapnum > self.tapQueue.qsize():
                                self.targetQueue.put(target)
                            else:
                                self.qemuVM.start(disk=target[1],machine=target[2],tap_number=target[3],taplist=[self.tapQueue.get() for i in range(tapnum)])
                                self.qemuVM.waitReady()
                                try:
                                    self.qemuVM.runTest(target[0])
                                except:
                                    print("error "+target[0])
                                else:
                                    self.qemuVM.destroy()
                                    self.qemuVM.waitPoweroff()
                                while len(self.qemuVM.tapls) > 0:
                                    self.tapQueue.put(self.qemuVM.tapls.pop())
                        else:
                            self.qemuVM.start(target[1])
                            self.qemuVM.waitReady()
                            try:
                                self.qemuVM.runTest(target[0])
                            except:
                                print("error "+target[0])
                            self.qemuVM.destroy()
                            self.qemuVM.waitPoweroff()


class QemuVM(object):
    def __init__(self, arch, vcpu, memory, workingDir, bkfile, kernel, kparms, initrd, bios, pflash, screen, id=1, port=12055, user='root',password='openEuler12#$',
                  path='/root/GitRepo/mugen-riscv' , restore=True, runArgs=''):
        self.arch = arch
        self.id = id
        self.port , self.ip , self.user , self.password  = port , '127.0.0.1' , user , password
        self.vcpu , self.memory= vcpu , memory
        self.workingDir , self.bkFile = workingDir , bkfile
        self.kernel, self.kparms, self.initrd, self.bios, self.pflash = kernel, kparms, initrd, bios, pflash
        self.drive = 'img'+str(self.id)+'.qcow2'
        self.path = path
        self.restore = restore
        self.runArgs = runArgs
        self.mac = id+1
        self.tapls = []
        self.screen = screen
        self.name = "mugenss"+str(self.id)
        if self.workingDir[-1] != '/':
            self.workingDir += '/'

    def start(self , disk=1 , machine=1 , tap_number=0 , taplist=[]):
        self.tapls = taplist
        if self.drive in os.listdir(self.workingDir):
            os.system('rm -f '+self.workingDir+self.drive)
        if self.restore:
            cmd = 'qemu-img create -f qcow2 -F qcow2 -b '+self.workingDir+self.bkFile+' '+self.workingDir+self.drive+" >/dev/null"
            res = os.system(cmd)
            if res != 0:
                print('Failed to create cow img: '+self.drive)
                return -1
        os.system('rm -f '+self.workingDir+'disk'+str(self.id)+'-*')
        if disk > 1:
            print('Append '+str(disk-1)+" disks")
            for i in range(1 , disk):
                cmd = 'qemu-img create -f qcow2 '+self.workingDir+"disk"+str(self.id)+'-'+str(i)+'.qcow2 500M >/dev/null'
                res = os.system(cmd)
                if res != 0:
                    print('Failed to create img: disk'+str(id)+'-'+str(i))
                    exit(-1)
        ## Configuration
        memory_append=self.memory * 1024
        if self.restore:
            drive=self.workingDir+self.drive
        else:
            drive=self.workingDir+self.bkFile
        if self.kernel is not None:
            kernelArg=" -kernel "+self.workingDir+self.kernel
            if self.kparms is not None:
                kernelArg += " -append '" + kparms + "'"
            else:
                kernelArg += " -append 'root=/dev/vda2 rw console=ttyS0 swiotlb=1 loglevel=3 systemd.default_timeout_start_sec=600 selinux=0 highres=off mem=" + \
                         str(memory_append) + "M earlycon'"
        else:
            kernelArg=" "
        if self.initrd is not None:
            initrdArg = "-initrd " + self.workingDir + self.initrd
        else:
            initrdArg = " "
        if self.bios is not None:
            if self.bios == 'none':
                biosArg=" -bios none"
            else:
                biosArg=" -bios "+self.workingDir+self.bios
        else:
            biosArg=" "
        if self.pflash is not None:
            self.npflash = self.workingDir+"/OVMF_"+str(self.id)+".fd"
            cmd = "cp "+self.pflash+" "+self.npflash
            os.system(cmd)

        if self.arch == 'riscv64':
            cmd = "qemu-system-riscv64 \
                  -nographic -machine virt \
                  -cpu rv64,sv39=on "
        elif self.arch == 'x86_64':
            cmd = "qemu-system-x86_64 \
                  -nographic -machine pc -accel kvm \
                  -cpu host "
            if self.pflash is not None:
                cmd += "-drive if=pflash,format=raw,file="+self.npflash+" "
        else:
            print('Unsupported qemu architecture ' + self.arch)
            return

        cmd += "-smp " + str(self.vcpu) + " -m " + str(self.memory) + "G \
        -audiodev pa,id=snd0 \
        " + kernelArg + " \
        " + initrdArg + " \
        " + biosArg + " \
        -drive file=" + drive + ",format=qcow2,id=hd0,if=none \
        -object rng-random,filename=/dev/urandom,id=rng0 \
        -device qemu-xhci -usb -device usb-kbd -device usb-tablet -device usb-audio,audiodev=snd0 "

        if self.arch == 'riscv64':
            cmd += "-device virtio-rng-device,rng=rng0 \
                   -device virtio-blk-device,drive=hd0 "
        elif self.arch == 'x86_64':
            cmd += "-device virtio-rng,rng=rng0 \
                   -device virtio-blk,drive=hd0 "

        if disk > 1:
            for i in range(1 ,disk):
                cmd += "-drive file=" + self.workingDir + "disk" + str(self.id) + '-' + str(i) + ".qcow2,format=qcow2,id=hd" + str(i) + ",if=none -device virtio-blk-pci,drive=hd" + str(i) + " "

        if tap_number > 0:
            for i in range(tap_number-1):
                used_tap = taplist[i]
                cmd += "-netdev tap,id=net" + used_tap + ",ifname=" + used_tap + ",script=no,downscript=no -device virtio-net-pci,netdev=net" + used_tap + ",mac=52:54:00:11:45:{:0>2d}".format(self.mac) + " "
                self.mac+=1
            if machine > 1:
                used_tap = taplist[-1]
                cmd += "-netdev tap,id=net" + used_tap + ",ifname=" + used_tap + ",script=no,downscript=no -device virtio-net-pci,netdev=net" + used_tap + ",mac=52:54:00:11:45:{:0>2d}".format(self.mac) + " "
                self.mac += 1

        self.port = findAvalPort(1)[0]
        cmd += "-netdev user,id=usernet,hostfwd=tcp::" + str(self.port) + "-:22 -device virtio-net-pci,netdev=usernet,mac=52:54:00:11:45:{:0>2d}".format(self.mac)
        if self.screen:
            if os.system("screen -ls | grep "+self.name+" >/dev/null") == 0:
                os.system("screen -X -S "+self.name+" quit")
            os.system("screen -S "+self.name+" -d -m "+cmd)
            time.sleep(1)
            if os.system("screen -ls | grep "+self.name+" >/dev/null") != 0:
                print("Qemu process terminate unexpectedly " + cmd)
            else:
                print("Qemu process is running with cmdline " + cmd)
        else:
            self.process = subprocess.Popen(args=cmd,stderr=subprocess.PIPE,stdout=subprocess.PIPE,stdin=subprocess.PIPE,encoding='utf-8',shell=True)
            time.sleep(1)
            ret = self.process.poll()
            if ret is not None:
                print("Qemu process terminate unexpectedly " + str(ret))
                print(self.process.communicate())
            else:
                print("Qemu process is running with cmdline " + cmd)

    def waitReady(self):
        conn = 519
        while conn == 519:
            conn = paramiko.SSHClient()
            conn.set_missing_host_key_policy(paramiko.AutoAddPolicy)
            try:
                time.sleep(5)
                conn.connect(self.ip, self.port, self.user, self.password, timeout=5)
            except Exception as e:
                conn = 519
        if conn != 519:
            conn.close()

    def conftap(self , br_ip , tapnode=None):
        self.tapip = '.'.join(br_ip.split(".")[:-1]+[str(self.id+1)])
        nic = ssh_exec(self,"lshw -class network | grep -A 5 'description: Ethernet interface' | grep 'logical name:' | awk '{print $NF}' | grep -v 'lo'")[1].split("\n")[0]
        print("config the machine "+str(self.id)+" nic name "+nic)
        print(ssh_exec(self , "nmcli c a type Ethernet con-name "+nic+" ifname "+nic , timeout=300)[1])
        print(ssh_exec(self , "nmcli c m "+nic+" ipv4.address "+self.tapip+"/24" , timeout=300)[1])
        # print(ssh_exec(self , "nmcli c m "+nic+" ipv4.gateway "+br_ip , timeout=300)[1])
        print(ssh_exec(self , "nmcli c m "+nic+" ipv4.method manual",timeout=300)[1])
        print(ssh_exec(self , "nmcli c up "+nic , timeout=300)[1])
        print(ssh_exec(self , "rm -rf "+self.path+"/conf",timeout=300)[1])
        print(ssh_exec(self , 'bash '+self.path+'/mugen.sh -c --user root --password openEuler12#$ --ip '+self.tapip+' 2>&1',timeout=300)[1])
        if tapnode is not None:
            for ip in tapnode:
                print(ssh_exec(self , 'bash '+self.path+'/mugen.sh -c --user root --password openEuler12#$ --ip '+ip+' 2>&1',timeout=300)[1])
            

    def runTest(self,testsuite):
        print(ssh_exec(self,'cd '+self.path+' \n echo \''+testsuite+'\' > list_temp \n python3 mugen_riscv.py -l list_temp '+self.runArgs,timeout=60)[1])
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
        if self.screen:
            while os.system("screen -ls | grep "+self.name+" >/dev/null") == 0:
                time.sleep(1)
        else:
            self.process.wait()
            while os.system('netstat -anp 2>&1 | grep '+str(self.port)+' > /dev/null') == 0:
                time.sleep(1)

    def destroy(self):
        ssh_exec(self,'poweroff')
        if self.restore:
            os.system('rm -f '+self.workingDir+self.drive)
        os.system('rm -f '+self.workingDir+'disk'+str(self.id)+'-*')
        if self.pflash is not None:
            os.system("rm -f "+self.npflash)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-l',metavar='list_file',help='Specify the test targets list',dest='list_file')
    parser.add_argument('-x',type=int,default=1,help='Specify threads num, default is 1')
    parser.add_argument('-c',type=int,default=4,help='Specify virtual machine cores num, default is 4')
    parser.add_argument('-M',type=int,default=4,help='Specify virtual machine memory size(GB), default is 4 GB')
    parser.add_argument('-w',type=str,help='Specify working directory')
    parser.add_argument('-m','--mugen',action='store_true',help='Run native mugen test suites')
    parser.add_argument('--user',type=str,default=None,help='Specify user')
    parser.add_argument('--password',type=str,default=None,help='Specify password')
    parser.add_argument('-A', type=str, choices=['riscv64', 'x86_64'], default='riscv64',
                        help='Specify the qemu architecture', dest='qemuArch')
    parser.add_argument('-B',type=str,help='Specify bios')
    parser.add_argument('-U',type=str,help='Specify UEFI pflash')
    parser.add_argument('-K',type=str,help='Specify kernel')
    parser.add_argument('-P',type=str,help='Specify kernel parameters')
    parser.add_argument('-I',type=str,help='Specify initrd')
    parser.add_argument('-D',type=str,help='Specify backing file name')
    parser.add_argument('-d',type=str,help='Specify mugen installed directory',dest='mugenDir')
    parser.add_argument('-g','--generate',action='store_true',default=False,help='Generate testsuite json after running test')
    parser.add_argument('--detailed',action='store_true',default=False,help='Print detailed log')
    parser.add_argument('--addDisk',action='store_true',default=False)
    parser.add_argument('--multiMachine',action='store_true',default=False)
    parser.add_argument('--addNic',action='store_true',default=False)
    parser.add_argument('--bridge_ip', type=str, help='Specify the network bridge ip')
    parser.add_argument('-t', type=int, default=0, help='Specify the number of generated free tap')
    parser.add_argument('-F',type=str,help='Specify test config file')
    parser.add_argument('--screen',action='store_true',default=False,help='Use screen command to manage qemu processes')
    args = parser.parse_args()

    test_env = TestEnv()
    test_env.ClearEnv()
    test_env.PrintSuiteNum()

    # set default values
    threadNum = 1
    coreNum , memSize = 4 , 4
    runningArg = ''
    mugenNative , generateJson , preImg , genList = False , False , False , False
    list_file , workingDir , bkFile , orgDrive , mugenPath = None , None , None , None , None
    arch = 'riscv64'
    kernel, kparms, initrd, bios, pflash = None, None, None, None, None
    img_base = 'img_base.qcow2'
    detailed = False
    user , password = "root","openEuler12#$"
    addDisk, multiMachine, addNic = False,False,False
    bridge_ip = None
    screen = False
    tap = Queue()
    

    # parse arguments
    if args.F is not None:
        configFile = open(args.F,'r')
        configData = json.loads(configFile.read())
        if configData.__contains__('threads'):
            if type(configData['threads']) == int and configData['threads'] > 0:
                threadNum = configData['threads']
            else:
                print('Thread number is invalid!')
                exit(-1)
        if configData.__contains__('cores'):
            if type(configData['cores']) == int and configData['cores'] > 0:
                coreNum = configData['cores']
            else:
                print('Core number is invalid!')
                exit(-1)
        if configData.__contains__('memory'):
            if type(configData['memory']) == int and configData['memory'] > 0:
                memSize = configData['memory']
            else:
                print('Memory size is invalid!')
                exit(-1)
        if configData.__contains__('user'):
            if type(configData['user']) == str:
                user = configData['user']
            else:
                print('user is invalid!')
                exit(-1)
        if configData.__contains__('password'):
            if type(configData['password']) == str:
                password = configData['password']
            else:
                print('password is invalid!')
                exit(-1)
        if configData.__contains__('addDisk') and configData['addDisk'] == 1:
            runningArg += " --addDisk"
        if configData.__contains__('multiMachine') and configData['multiMachine'] == 1:
            runningArg += " --multiMachine"
        if configData.__contains__('addNic') and configData['addNic'] == 1:
            runningArg += " --addNic"
        if configData.__contains__('mugenNative') and configData['mugenNative'] == 1:
            runningArg += " -m"
            mugenNative = True
        if configData.__contains__('generate') and configData['generate'] == 1:
            runningArg += " -g"
        if configData.__contains__('detailed') and configData['detailed'] == 1:
            runningArg += " -x"
        if configData.__contains__('bridge ip'):
            bridge_ip = configData['bridge ip']
        if configData.__contains__('tap num'):
            for i in range(configData['tap num']):
                tap.put('tap'+str(i))
        if configData.__contains__('useScreen') and configData['useScreen'] == 1:
            screen = True
        if configData.__contains__('qemuArch') and type(configData['qemuArch']) == str:
            arch = configData['qemuArch']
            if arch not in ['riscv64', 'x86_64']:
                print("Unsupported qemu architecture " + arch)
                exit(-1)
        if configData.__contains__('workingDir') and (configData.__contains__('bios') or configData.__contains__('kernel') or configData.__contains__('pflash')) and configData.__contains__('drive'):
            if type(configData['workingDir']) == str:
                workingDir = configData['workingDir']
            else:
                print('Invalid working directory!')
                exit(-1)
            if type(configData['drive']) == str:
                orgDrive = configData['drive']
            else:
                print('Invalid drive file!')
                exit(-1)
            if configData.__contains__('bios') and type(configData['bios']) == str:
                bios = configData['bios']
            if configData.__contains__('pflash') and type(configData['pflash']) == str:
                pflash = configData['pflash']
            if configData.__contains__('kernel') and type(configData['kernel']) == str:
                kernel = configData['kernel']
            if configData.__contains__('kernelParams') and type(configData['kernelParams']) == str and configData['kernelParams'].strip() != "":
                kparms = configData['kernelParams']
            if configData.__contains__('initrd') and type(configData['initrd']) == str:
                initrd = configData['initrd']
            if configData.__contains__('mugenDir'):
                preImg = False
                bkFile = orgDrive
                mugenPath = configData['mugenDir'].rstrip('/')
                if configData.__contains__('listFile') and type(configData['listFile']) == str:
                    list_file = configData['listFile']
                    genList = False
                else:
                    genList = True
            else:
                preImg = True
                bkFile = img_base
                mugenPath = "/root/GitRepo/mugen-riscv"
                if configData.__contains__('listFile') and type(configData['listFile']) == str:
                    list_file = configData['listFile']
                    genList = False
                else:
                    genList = True
        else:
            print('Please specify working directory and bios or kernel and drive file!')
            exit(-1)
    else:
        if args.x > 0:
            threadNum = args.x
        else:
            print('Thread number is invalid!')
            exit(-1)
        if args.c > 0:
            coreNum = args.c
        else:
            print('Core number is invalid!')
            exit(-1)
        if args.M > 0:
            memSize = args.M
        else:
            print('Memory size is invalid!')
            exit(-1)
        if args.user is not None:
            user = args.user
        if args.password is not None:
            password = args.password
        if args.addDisk:
            runningArg += ' --addDisk'
        if args.multiMachine:
            runningArg += ' --multiMachine'
        if args.addNic:
            runningArg += ' --addNic'
        if args.mugen:
            runningArg += ' -m'
            mugenNative = True
        if args.generate:
            runningArg += ' -g'
        if args.detailed:
            runningArg += ' -x'      
        bridge_ip = args.bridge_ip
        if args.t > 0:
            for i in range(args.t):
                tap.put('tap'+str(i))
        if args.screen:
            screen = True

        if args.w != None and (args.B != None or args.K != None or args.U != None) and args.D != None:
            workingDir = args.w
            orgDrive = args.D
            bios = args.B
            pflash = args.U
            kernel = args.K
            if args.P.strip() != "":
                kparms = args.P
            initrd = args.I
            if args.mugenDir != None:
                preImg = False
                bkFile = orgDrive
                mugenPath = args.mugenDir.rstrip('/')
                if args.list_file != None:
                    list_file = args.list_file
                    genList = False
                else:
                    genList = True
            else:
                preImg = True
                bkFile = img_base
                mugenPath = "/root/GitRepo/mugen-riscv"
                if args.list_file != None:
                    list_file = args.list_file
                    genList = False
                else:
                    genList = True
        else:
            print('Please specify working directory and bios or kernel and drive file!')
            exit(-1)

    if screen and os.system("screen -v >/dev/null") != 0:
        print("screen command not found")
        exit(-1)
    else:
        os.system('for i in $(screen -ls | grep mugenss | sed "s/.*\(mugenss[0-9]*\).*/\\1/"); do screen -X -S $i quit; done')

    if preImg == True or genList == True:
        if preImg == True and (bkFile not in os.listdir(workingDir)):
            res = os.system('qemu-img create -f qcow2 -F qcow2 -b '+workingDir+orgDrive+' '+workingDir+bkFile)
            if res != 0:
                print('Failed to create img-base')
                exit(-1)

        preVM = QemuVM(id=1, port=findAvalPort(1)[0], user=user, password=password, arch=arch, kernel=kernel, kparms=kparms, initrd=initrd, bios=bios, pflash=pflash,
                       vcpu=coreNum, memory=memSize, path=mugenPath, workingDir=workingDir, bkfile=bkFile, screen=screen,
                       restore=False)
        preVM.start()
        preVM.waitReady()
        if preImg == True:
            print(ssh_exec(preVM,'dnf install git',timeout=120)[1])
            print(ssh_exec(preVM,'cd /root \n mkdir GitRepo \n cd GitRepo \n git clone https://github.com/brsf11/mugen-riscv.git',timeout=600)[1])
            print(ssh_exec(preVM,'cd /root/GitRepo/mugen-riscv \n bash dep_install.sh',timeout=300)[1])
            print(ssh_exec(preVM,'cd /root/GitRepo/mugen-riscv \n bash mugen.sh -c --port 22 --user root --password openEuler12#$ --ip 127.0.0.1 2>&1',timeout=300)[1])
            sshd_config = ssh_exec(preVM, 'cat /etc/ssh/sshd_config' , timeout=100)[1]
            try:
                ssh_exec(preVM , 'echo \'test ssh\' > /root/temp.txt')
                sftp_get(preVM , '/root' , 'temp.txt' , '.' , timeout=5)
            except:
                print("config ssh")
                sshd_config = sshd_config.replace("/usr/libexec/openssh/openssh/sftp-server" , "/usr/libexec/openssh/sftp-server")
                #print(sshd_config)
                ssh_exec(preVM, 'echo "'+sshd_config+'" > /etc/ssh/sshd_config')
                print(ssh_exec(preVM,"sudo systemctl restart sshd" , timeout=100)[1])
            else:
                os.system('rm -f ./temp.txt')
            finally:
                ssh_exec(preVM , 'rm -f /root/temp.txt')

        if genList is True:
            ssh_exec(preVM,'dnf list | grep -E \'riscv64|noarch\' > pkgs.txt',timeout=120)
            sftp_get(preVM,'.','pkgs.txt','.',timeout=5)
            pkgfile = open('pkgs.txt','r')
            raw = pkgfile.read()
            pkgfile.close()
            os.system('rm -f pkgs.txt')
            colums = raw.split('\n')
            pkgs = []
            for colum in colums:
                witharch = colum.split(' ')[0]
                witharch = witharch.replace('.riscv64','')
                pkgs.append(witharch.replace('.noarch',''))
            outputfile = open('list','w')
            pkgs.append('os-basic')
            pkgs.append('os-storage')
            for pkg in pkgs:
                outputfile.write(pkg+'\n')
            outputfile.close()
            list_file = 'list'
        preVM.destroy()
        preVM.waitPoweroff()



    if list_file is not None:
        test_target = TestTarget(list_file_name=list_file)
        test_target.PrintTargetNum()
        test_target.CheckTargets(suite_list_mugen=test_env.suite_list_mugen,suite_list_riscv=test_env.suite_list_riscv,mugen_native=mugenNative,qemu_mode=True)
        test_target.PrintUnavalTargets()
        test_target.PrintAvalTargets()

        qemuVM = []
        for i in range(threadNum):
            qemuVM.append(QemuVM(id=i , vcpu=coreNum , memory=memSize,
                                 user=user , password=password,
                                 arch=arch, initrd=initrd, kernel=kernel, kparms=kparms, bios=bios, pflash=pflash,
                                 workingDir=workingDir , bkfile=bkFile , path=mugenPath, screen=screen,
                                 runArgs=runningArg))   
        targetQueue = Queue()
        for target in test_target.test_list:
            jsondata = json.loads(open('suite2cases/'+target+'.json','r').read())
            if len(jsondata['cases']) != 0:
                targetQueue.put((target , max(jsondata.get('add disk' , [1])) , jsondata.get("machine num" , 1) , jsondata.get("add network interface" , 1)))

        dispathcers = []
        for i in range(threadNum):
            dispathcers.append(Dispatcher(qemuVM=qemuVM[i] , targetQueue=targetQueue , tapQueue=tap , br_ip=bridge_ip , step = threadNum))
            dispathcers[i].start()
            time.sleep(2)

        isAlive = True
        isEnd = False
        while isAlive:
            tempAlive = []
            for i in range(threadNum):
                if dispathcers[i].is_alive():
                    print('Thread '+str(i)+' is alive')
                    tempAlive.append(True)
                else:
                    print('Thread '+str(i)+' is dead')
                    while len(dispathcers[i].attachVM) > 0:
                        dispathcers[i].attachVM[-1].destroy()
                        dispathcers[i].attachVM[-1].waitPoweroff()
                        while len(dispathcers[i].attachVM[-1].tapls) > 0:
                            dispathcers[i].tapQueue.put(dispathcers[i].attachVM[-1].tapls.pop())
                        dispathcers[i].attachVM.pop()
                    while len(dispathcers[i].qemuVM.tapls) > 0:
                        dispathcers[i].tapQueue.put(dispathcers[i].qemuVM.tapls.pop())
                    tempAlive.append(False)
                    if not isEnd:
                        try:
                            target = targetQueue.get(block=True,timeout=2)
                        except:
                            isEnd = True
                        else:
                            dispathcers[i] = Dispatcher(qemuVM = qemuVM[i],targetQueue=targetQueue,initTarget=target , tapQueue=tap , br_ip=bridge_ip , step=threadNum)
                            dispathcers[i].start()
            isAlive = False
            for i in range(threadNum):
                isAlive |= tempAlive[i]
            time.sleep(5)
    
    if genList is True:
        os.system('rm -f list')
            
