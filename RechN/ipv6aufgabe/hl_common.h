#define PORT 2673
// Maximum size of various string fields (including trailing \0)
#define MAXSIZE 256

/**
 * Determines this machine's hostname, of up to MAXSIZE characters (including
 * trailing \0).
 *
 * Returns a static buffer.
 */
extern const char* get_hostname();
