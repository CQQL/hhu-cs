#include <string.h>
#include <sys/utsname.h>

#include "hl_common.h"

static char hostname_buf[MAXSIZE];

const char* get_hostname() {
	struct utsname uname_buf;
	uname(&uname_buf);
	strncpy(hostname_buf, uname_buf.nodename, sizeof hostname_buf);
	hostname_buf[(sizeof hostname_buf)-1] = '\0';
	return hostname_buf;
}
