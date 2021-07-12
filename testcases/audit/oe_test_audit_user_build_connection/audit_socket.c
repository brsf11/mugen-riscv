#include <stdio.h>
#include <sys/param.h>
#include <sys/stat.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <unistd.h>
#include <stdlib.h>
#include <poll.h>
#include <errno.h>
#include <stddef.h>


#define SOCK_PATH "/usr/local/audit_sock"

void writeLogLine(const char *fileName,const char *content)
{
	FILE *fp;
	if((fp=fopen(fileName,"a"))==NULL)
	{
		printf("Open Failed.\n");
		return;
	}
	fprintf(fp,"%s\n",content);
	fclose(fp);
}


int main(void)
{
	int fd,len;
	struct sockaddr_un un;

	if((fd=socket(AF_UNIX,SOCK_STREAM,0))<0){
		printf("create unix sock error :%d\r\n",errno);
		return -1;
	}
	
	(void)memset(&un,0,sizeof(un));
	un.sun_family=AF_UNIX;
	(void)strcpy(un.sun_path,SOCK_PATH);

	len=offsetof(struct sockaddr_un,sun_path)+strlen(un.sun_path);
	(void)unlink(SOCK_PATH);

	if(bind(fd,(struct sockaddr *)&un,len)<0){
		printf("bind unix sock error : %d\r\n",errno);
		close(fd);
		return -1;
	}

	if(chmod(SOCK_PATH,S_IRWXU)!=0){
		printf("chmod sock %s error : %d\r\n",SOCK_PATH,errno);
		close(fd);
		return -1;
	}


	(void)memset(&un,0,sizeof(un));
	un.sun_family=AF_UNIX;
	(void)strcpy(un.sun_path,"/var/run/audispd_events");

	len=offsetof(struct sockaddr_un,sun_path)+strlen(un.sun_path);
	if(connect(fd,(struct sockaddr *)&un,len)<0){
		printf("connect sock error :%d\r\n",errno);
		close(fd);
		return -1;
	}





	printf("start audisp plugin ok! fd=%d\r\n",fd);

	struct pollfd fds;
	fds.fd=fd;
	fds.events=POLLIN;
	printf("start audit thread now!\r\n");
	int ind=0;
	for(ind=0;ind<20;ind++){
		
		
		if(poll(&fds,1,1000)>0){
			int len=0;
			sleep(2);
			system("date");
			unsigned char buf[2048]={0};
			while(len=recv(fd,buf,sizeof(buf)-1,MSG_DONTWAIT)){
				if(len<0)
					break;
				writeLogLine("./1.txt",buf);
				printf("%s\r\n",buf);
			}
		}
		
		system("echo OK >./wait_poll");

	
	}
	return 0;
}
