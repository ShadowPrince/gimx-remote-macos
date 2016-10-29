//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#include<sys/socket.h>

long UDPConnect(const char *addr, const int port, unsigned int *s, struct sockaddr_in *si_other);
long UDPSend(const unsigned int s, const struct sockaddr_in si_other, const int packet[]);
long UDPType(const unsigned int s, const struct sockaddr_in si_other);
