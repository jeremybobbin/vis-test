#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

#include "../../map.h"
#include "../../ui-terminal-keytab.h"
#include "../../libkey.h"

#define LENGTH(x)  ((int)(sizeof (x) / sizeof *(x)))
#define ISUTF8(c)   (((c)&0xC0)!=0x80)

Map *keymap = NULL;

static bool map_put_recursive(Map *m, const char *k, const char *v) {
	char *s;
	while ((s = map_get(m, v))) {
		map_delete(m, v);
		v = s;
	}
	return map_put(m, k, v);
}

static int encode(char *buf, size_t len, const char *key) {
	int i, j;
	const char *next;
	char *s;

	next = vis_keys_next(key);
	if (next == NULL) {
		return 0;
	} else if (len == 0) {
		return -1;
	}


	if (next - key == 1) {
		buf[0] = key[0];
		return 1;
	}

	// key = "<Home>" -> map_get_sized: "Home"
	if (next - key > 2 && (s = map_get_sized(keymap, &key[1], next-key-2))) {
		return snprintf(&buf[0], len, "%s", s);
	}

	if (next - key == 5) { // <C-a>
		if (strncmp(key, "<C-", 3) == 0) {
			buf[0] = key[3]-0x60;
			return 1;
		} else if (strncmp(key, "<M-", 3) == 0) {
			if (len < 2) {
				return 0;
			}
			buf[0] = '\x1b';
			buf[1] = key[3];
		}
	}

	i = 0;
	if (key[i] != '<' && (key[i] & 0xC0)  && ISUTF8(key[i])) {
		for (j = 1; !ISUTF8(key[i+j]); j++);
		memcpy(&buf[0], &key[i], j);
		return j;
	}

	return 0;
}

int main(int argc, char *argv[]) {
	char kb[VIS_KEY_LENGTH_MAX*2], buf[BUFSIZ];
	const char *key, *next;
	int i, j, k, n;
	struct timespec ts;

	if ((keymap = map_new()) == NULL) {
		return 1;
	}

	for (i = 0; i < LENGTH(ui_terminal_keytab); i++) {
		map_put_recursive(keymap, ui_terminal_keytab[i][2], ui_terminal_keytab[i][1]);
	}

	for (i = 0; i < LENGTH(ui_terminal_keytab); i++) {
		if (ui_terminal_keytab[i][1][0] == '^' && ui_terminal_keytab[i][1][1]) {
			kb[0] = ui_terminal_keytab[i][1][1]^0x40;
			kb[1] = '\0';
			key = (const char*) kb;
		} else {
			key = ui_terminal_keytab[i][1];
		}
		// this may error if there's a bug in infocmp code - we'll just ignore it.
		map_put_recursive(keymap, key, ui_terminal_keytab[i][1]);
	}

	map_delete(keymap, "Enter");
	map_delete(keymap, "Escape");
	map_delete(keymap, "Tab");
	if (!(
		map_put_recursive(keymap, "Enter",  "\n")   &&
		map_put_recursive(keymap, "Escape", "\x1b") &&
		map_put_recursive(keymap, "Space",  " ")    &&
		map_put_recursive(keymap, "Tab",    "\t")
	)) {
		return 1;
	}

	for (i = 0, j = 0;;) {
		if (i == 0) {
			if ((n = read(0, &buf[i], sizeof(buf)-i-1)) == 0) {
				return 0;
			} else if (n == -1) {
				fprintf(stderr, "vis-keys - read failed: %s\n", strerror(errno));
				return 1;
			} else {
				buf[n] = '\0';
				i += n;
			}
		} else if (j < i) {
			if (buf[j] == '\n') {
				j++;
				continue;
			}

			if ((n = encode(&kb[0], sizeof(kb), &buf[j])) == -1) {
				return 1;
			}

			if ((n = write(1, kb, n)) == 0) {
				return 0;
			} else if (n == -1) {
				fprintf(stderr, "vis-keys - write failed: %s\n", strerror(errno));
				return 1;
			}

			if (strncmp(&buf[j], "<Escape>", sizeof("<Escape>")-1) == 0) {
				// retry usleep 3 times or quit
				ts.tv_sec  = 0;
				ts.tv_nsec = 250000000; // .25 seconds
				for (k = 0; k < 3; k++) {
					if (nanosleep(&ts, &ts) == 0) {
						break;
					}
				}

				if (k >= 3) {
					fprintf(stderr, "vis-keys - sleep failed: %s\n", strerror(errno));
					return 1;
				}
			}
			if ((next = vis_keys_next(&buf[j]))) {
				j += next - &buf[j];
			} else {
				j = i;
				continue;
			}
		} else {
			i = 0;
			j = 0;
		}
	}
	return 0;
}
