#include <alloca.h>
#include <assert.h>
#include <string.h>
#include <stdio.h>
#include <unistd.h>
#include <arpa/inet.h>

#include "hl_common.h"

int main(int argc, char** argv) {
  // Turn off output buffering so that we see all messages immediately
  if (setvbuf(stdout, NULL, _IONBF, 0) != 0) {
    perror("setvbuf failed!");
    return 1;
  }

  int sock = socket(AF_INET6, SOCK_DGRAM, IPPROTO_UDP);
  if (sock == -1) {
    perror("Cannot create socket");
    return 1;
  }

  struct sockaddr_in6 sa;
  memset(&sa, 0, sizeof sa);
  sa.sin6_family = AF_INET6;
  sa.sin6_addr = in6addr_any;
  sa.sin6_port = htons(PORT);
  if (bind(sock, (struct sockaddr *)&sa, sizeof sa) == -1) {
    perror("bind failed!");
    close(sock);
    return 1;
  }

  for (;;) {
    struct sockaddr_in6 peer;
    socklen_t peer_len = sizeof peer;
    char incoming[1+MAXSIZE];
    ssize_t len = recvfrom(sock, incoming, sizeof incoming, 0, (struct sockaddr*) &peer, &peer_len);
    if (len == -1) {
      perror("recvfrom failed");
      break;
    }
    // Max length of IPv6 address is 8 * 4 + 7 and 1 for the \0
    char peeraddr[40];
    inet_ntop(AF_INET6, peer.sin6_addr.s6_addr, peeraddr, 40);
    assert(strlen(peeraddr) < MAXSIZE);
    if (len <= 1) {
      printf("Message from %s too short\n", peeraddr);
      continue;
    }
    if (incoming[0] != 'M') {
      printf("Weird first byte in message from %s: %i\n", peeraddr, (int) incoming[0]);
      continue;
    }
    incoming[len-1] = '\0'; // Ensure that input is a valid C string

    // Craft message contents
    char* peername = incoming+1;
    const char* hostname = get_hostname();

    char msg[1+17+3*(MAXSIZE-1)+1];
    size_t msglen = snprintf(msg, sizeof msg, "RHello %s (%s)! I am %s.", peername, peeraddr, hostname);

    printf("Sending \"%s\" to %s\n", msg, peeraddr);

    // Send response message
    if (sendto(sock, msg, msglen+1, 0, (struct sockaddr*) &peer, peer_len) == -1) {
      perror("Send failed");
      break;
    }
  }

  // An error occured
  close(sock);
  return 2;
}
