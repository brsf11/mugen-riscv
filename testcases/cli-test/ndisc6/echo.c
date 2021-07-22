#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <sys/socket.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <errno.h>
#include <netdb.h>

#define PORT_NUM 7777
#define MAXBUF 1024

int main()
{
        int server_fd,conn_fd;
        socklen_t len;
        struct sockaddr_in server_addr,client_addr;
        char buf[MAXBUF + 1];
        server_fd = socket(AF_INET,SOCK_STREAM,0);

        memset(&server_addr,0,sizeof(server_addr));

        server_addr.sin_port = htons(PORT_NUM);
        server_addr.sin_family = AF_INET;
        server_addr.sin_addr.s_addr = htonl(INADDR_ANY);

        bind(server_fd,(struct sockaddr *)&server_addr,sizeof(server_addr));

        listen(server_fd,5);

        while(1)
        {
                printf("----------------ready for connection-------------\n");

                len = sizeof(struct sockaddr);
                conn_fd = accept(server_fd,(struct sockaddr *)&client_addr,&len);

                if(conn_fd > 0)
                {
                        printf("got connection from ip:%s, port:%d\n",inet_ntoa(client_addr.sin_addr),ntohs(client_addr.sin_port));
                }
                while(1)
                {
                        memset(buf,0,sizeof(buf));

                        len = recv(conn_fd,buf,MAXBUF,0);
                        if(len > 0)
                                printf("recv: %s  , %d Byte\n",buf,strlen(buf));
                        else if(len == 0)
                        {
                                printf("client quit...\n");
                                break;
                        }

                        len = send(conn_fd,buf,strlen(buf),0);
                        if(len > 0)
                                printf("send: %s  , %d Byte\n",buf,strlen(buf));
                        else if(len == 0)
                        {
                                printf("client quit...\n");
                                break;
                        }

                }
                close(conn_fd);
                printf("\n\n\n");
        }
        close(server_fd);

