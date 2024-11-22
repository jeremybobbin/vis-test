#include <stdbool.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tap.h"
#include "buffer.h"

static bool compare(Buffer *buf, const char *data, size_t len) {
	return buf->len == len && (len == 0 || memcmp(buf->data, data, buf->len) == 0);
}

static bool compare0(Buffer *buf, const char *data) {
	return buf->len == strlen(data)+1 && memcmp(buf->data, data, buf->len) == 0;
}

int main(int argc, char *argv[]) {
	Buffer buf;

	plan_no_plan();

	string_init(&buf);
	ok(string_content(&buf) == NULL && string_length(&buf) == 0 && string_capacity(&buf) == 0, "Initialization");
	ok(string_insert(&buf, 0, "foo", 0) && string_content(&buf) == NULL &&
	   string_length(&buf) == 0 && string_capacity(&buf) == 0, "Insert zero length data");
	ok(!string_insert0(&buf, 1, "foo"), "Insert string at invalid position");

	ok(string_insert0(&buf, 0, "") && compare0(&buf, ""), "Insert empty string");
	ok(string_insert0(&buf, 0, "foo") && compare0(&buf, "foo"), "Insert string at start");
	ok(string_insert0(&buf, 1, "l") && compare0(&buf, "floo"), "Insert string in middle");
	ok(string_insert0(&buf, 4, "r") && compare0(&buf, "floor"), "Insert string at end");

	ok(string_put0(&buf, "") && compare0(&buf, ""), "Put empty string");
	ok(string_put0(&buf, "bar") && compare0(&buf, "bar"), "Put string");

	ok(string_prepend0(&buf, "foo") && compare0(&buf, "foobar"), "Prepend string");
	ok(string_append0(&buf, "baz") && compare0(&buf, "foobarbaz"), "Append string");

	string_release(&buf);
	ok(buf.data == NULL && string_length(&buf) == 0 && string_capacity(&buf) == 0, "Release");

	ok(string_insert(&buf, 0, "foo", 0) && compare(&buf, "", 0), "Insert zero length data");
	ok(string_insert(&buf, 0, "foo", 3) && compare(&buf, "foo", 3), "Insert data at start");
	ok(string_insert(&buf, 1, "l", 1) && compare(&buf, "floo", 4), "Insert data in middle");
	ok(string_insert(&buf, 4, "r", 1) && compare(&buf, "floor", 5), "Insert data at end");

	size_t cap = string_capacity(&buf);
	string_clear(&buf);
	ok(buf.data && string_length(&buf) == 0 && string_capacity(&buf) == cap, "Clear");

	ok(string_put(&buf, "foo", 0) && compare(&buf, "", 0), "Put zero length data");
	ok(string_put(&buf, "bar", 3) && compare(&buf, "bar", 3), "Put data");

	ok(string_prepend(&buf, "foo\0", 4) && compare(&buf, "foo\0bar", 7), "Prepend data");
	ok(string_append(&buf, "\0baz", 4) && compare(&buf, "foo\0bar\0baz", 11), "Append data");

	ok(string_grow(&buf, cap+1) && compare(&buf, "foo\0bar\0baz", 11) && string_capacity(&buf) >= cap+1, "Grow");

	const char *content = string_content(&buf);
	char *data = string_move(&buf);
	ok(data == content && string_length(&buf) == 0 && string_capacity(&buf) == 0 && string_content(&buf) == NULL, "Move");
	ok(string_append0(&buf, "foo") && string_content(&buf) != data, "Modify after move");
	free(data);

	skip_if(TIS_INTERPRETER, 1, "vsnprintf not supported") {

		ok(string_printf(&buf, "Test: %d\n", 42) && compare0(&buf, "Test: 42\n"), "Set formatted");
		ok(string_printf(&buf, "%d\n", 42) && compare0(&buf, "42\n"), "Set formatted overwrite");
		string_clear(&buf);

		ok(string_printf(&buf, "%s", "") && compare0(&buf, ""), "Set formatted empty string");
		string_clear(&buf);

		bool append = true;
		for (int i = 1; i <= 10; i++)
			append &= string_appendf(&buf, "%d", i);
		ok(append && compare0(&buf, "12345678910"), "Append formatted");
		string_clear(&buf);

		append = true;
		for (int i = 1; i <= 10; i++)
			append &= string_appendf(&buf, "%s", "");
		ok(append && compare0(&buf, ""), "Append formatted empty string");
		string_clear(&buf);
	}

	string_release(&buf);

	return exit_status();
}
