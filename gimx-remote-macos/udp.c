//
//  udp.c
//  gimx-remote-macos
//
//  Created by shdwprince on 10/28/16.
//  Copyright © 2016 shdwprince. All rights reserved.
//

#include "udp.h"

#include<stdio.h> //printf
#include<string.h> //memset
#include<arpa/inet.h>
#include<sys/socket.h>

#define MSGLEN 38 * sizeof(int) + 2 * sizeof(char)
#define BUFLEN 512

long UDPConnect(const char *addr, const int port, unsigned int *s, struct sockaddr_in *si_other) {
    //struct sockaddr_in si_other;
    //unsigned int s, slen=sizeof(si_other);
    if ((*s = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)) == -1) {
        return -1;
    }

    memset((char *) si_other, 0, sizeof(si_other));
    si_other->sin_family = AF_INET;
    si_other->sin_port = htons(port);

    if (inet_aton(addr, &(si_other->sin_addr)) == 0) {
        return -2;
    }

    struct timeval tv;
    tv.tv_sec = 0;
    tv.tv_usec = 100000;
    if (setsockopt(*s, SOL_SOCKET, SO_RCVTIMEO, &tv,sizeof(tv)) < 0) {
        return -4;
    }

    return 0;
}

long UDPSend(const unsigned int s, const struct sockaddr_in si_other, const int packet[]) {
    signed char msg[MSGLEN];
    memset(&msg[0], 0xff, 1);
    memset(&msg[1], 0x9c, 1);
    memcpy(&msg[2], packet, 38 * sizeof(int));

    if (sendto(s, msg, sizeof(msg) , 0 , (struct sockaddr *) &si_other, sizeof(si_other)) == -1) {
        return -3;
    }

    return 0;
}

long UDPType(const unsigned int s, const struct sockaddr_in si_other) {
    signed char msg[] = {0x11, 0x00};

    if (sendto(s, msg, sizeof(msg) , 0 , (struct sockaddr *) &si_other, sizeof(si_other)) == -1) {
        return -3;
    }

    int buflen = 3;
    signed char buf[buflen];
    memset(buf,'\0', buflen);
    if (recvfrom(s, buf, buflen, 0, (struct sockaddr *) &si_other, 0) == -1) {
        return -4;
    }
    printf("%x %x %x\n\n", buf[0], buf[1], buf[2]);
    
    return buf[1];
}
