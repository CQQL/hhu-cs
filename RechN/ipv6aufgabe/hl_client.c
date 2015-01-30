#include <errno.h>
#include <netdb.h>
#include <string.h>
#include <stdio.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <sys/types.h>

#include "hl_common.h"

void contact(char* host) {
  // Determine remote address
  struct addrinfo* hostaddr;
  struct addrinfo hints;
  memset(&hints, 0, sizeof(struct addrinfo));
  hints.ai_family = AF_UNSPEC;
  hints.ai_socktype = SOCK_DGRAM;
  char port[6];
  snprintf(port, 6, "%d", PORT);
  if (getaddrinfo(host, port, &hints, &hostaddr) != 0) {
    perror("getaddrinfo failed");
    return;
  }

  // Create socket
  int sock = socket(AF_INET6, SOCK_DGRAM, IPPROTO_UDP);
  if (sock == -1) {
    perror("socket creation failed");
    return;
  }

  // Compose message
  char sendbuf[1+MAXSIZE];
  int msglen = snprintf(sendbuf, sizeof sendbuf, "M%s", get_hostname()) + 1;

  // Configure socket timeouts
  struct timeval timeout;
  memset(&timeout, 0, sizeof timeout);
  timeout.tv_sec = 1;
  if (setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof timeout) == -1) {
    perror("setsockopt(SO_RCVTIMEO) failed");
    close(sock);
    return;
  }
  if (setsockopt(sock, SOL_SOCKET, SO_SNDTIMEO, &timeout, sizeof timeout) == -1) {
    perror("setsockopt(SO_SNDTIMEO) failed");
    close(sock);
    return;
  }

  // Send message
  if (sendto(sock, sendbuf, msglen, 0, hostaddr->ai_addr, hostaddr->ai_addrlen) == -1) {
    perror("sendto failed");
    close(sock);
    return;
  }

  char recvbuf[4*MAXSIZE];
  struct sockaddr peer;
  socklen_t peer_len = sizeof peer;
  size_t msgsize = recvfrom(sock, &recvbuf, sizeof recvbuf, 0, &peer, &peer_len);
  if (msgsize == -1) {
    if (errno == EWOULDBLOCK) {
      fprintf(stderr, "No response from %s!\n", host);
      close(sock);
      return;
    }

    perror("recvfrom failed");
    close(sock);
    return;
  }

  recvbuf[msgsize-1] = '\0';
  // Max length of IPv6 address is 8 * 4 + 7 and 1 for the \0
  char peeraddr[40];
  inet_ntop(AF_INET6, hostaddr, peeraddr, 40);
  if (recvbuf[0] != 'R') {
    fprintf(stderr, "Reply from %s(%s) does not follow protocol!\n"
            "Expected message type 'R', but got %c\n",
            peeraddr, host, recvbuf[0]);
    close(sock);
    return;
  }

  printf("\"%s\" from %s (%s)\n", recvbuf+1, peeraddr, host);

  close(sock);
}

int main(int argc, char** argv) {
  if (argc == 1) {
    fprintf(stderr, "No remote host given!\n");
    printf("Usage: %s server-ip [server-ip..]\n", argv[0]);
    return 1;
  }

  char** host = argv+1;
  while (argc > 1) {
    contact(*host);
    host++;
    argc--;
  }

  return 0;
}
