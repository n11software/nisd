/*
 * Copyright (c) 2023, 2024
 * 	N11 Software. All rights reserved.
 *
 * @N11_PUBLIC_SOURCE_LICENSE_HEADER_START@
 *
 * This file contains Original Code and/or Modifications of Original Code
 * as defined in and that are subject to the N11 Public Source License
 * Version 2.0 (the 'License'). You may not use this file except in
 * compliance with the License. The rights granted to you under the License
 * may not be used to create, or enable the creation or redistribution of,
 * unlawful or unlicensed copies of software, or to circumvent, violate,
 * or enable the circumvention or violation of, any terms of a software
 * license agreement.
 *
 * Please obtain a copy of the License using Git at:
 * git clone ssh://n11.dev:23231/health-files.git
 * Navigate to the following location: npsl/N11_LICENSE_2
 * and read it before using this file.
 *
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
 * EXPRESS OR IMPLIED, AND N11 HEREBY DISCLAIMS ALL SUCH WARRANTIES,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT.
 * Please see the License for the specific language governing rights and
 * limitations under the License.
 *
 * @N11_PUBLIC_SOURCE_LICENSE_HEADER_END@
 */

#ifndef lint
static const char copyright[] =
"@(#) Copyright (c) 2023, 2024\n\
	N11 Software. All rights reserved.\n";
#endif /* not lint */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ed.h"

#define BUF_SIZE 1024

static char *buf;
static size_t buf_len;
static size_t buf_cap;

int
init(void)
{
	buf_cap = BUF_SIZE;
	buf = malloc(buf_cap);
	if (!buf) {
		perror("unable to alloc buffer");
		return 1;
	}

	buf_len = 0;
	return 0;
}

void
clean(void)
{
	free(buf);
}

void
appendLine(line)
	char *line;
{
	size_t line_len;
	line_len = strlen(line);
	if (line[line_len - 1] == '\n') {
		line_len--;
	}

	while (buf_len + line_len + 1 > buf_cap) {
		buf_cap *= 2;
		buf = realloc(buf, buf_cap);
		if (!buf) {
			perror("unable to realloc buffer");
			exit(1);
		}
	}

	memcpy(buf + buf_len, line, line_len);
	buf_len += line_len;
	buf[buf_len++] = '\n';
}

void
insert(line)
	const char *line;
{
	size_t line_len = strlen(line);
	if (line_len > 0 && line[line_len - 1] == '\n') {
		line_len--;
	}

	memmove(buf + buf_len + line_len + 1, buf + buf_len, buf_cap - buf_len - 1);
	memcpy(buf + buf_len, line, line_len);
	buf_len += line_len;
	buf[buf_len++] = '\n';
}

void
change(line)
	const char *line;
{
	size_t line_len = strlen(line);
	if (line_len > 0 && line[line_len - 1] == '\n') {
		line_len--;
	}

	if (buf_len > 0) {
		memcpy(buf, line, line_len);
		buf_len = line_len;
		buf[buf_len++] = '\n';
	}
}

void
deleteLine(line_num)
	size_t line_num;
{
	size_t current_line, del_line_len, start, end, i;

	if (line_num == 0 || line_num > buf_len) {
		printf("?\n");
		return;
	}

	current_line = 0;
	del_line_len = 0;
	start = 0;
	end = 0;
	for (i = 0; i < buf_len; i++) {
		if (buf[i] == '\n') {
			current_line++;
			if (current_line == line_num) {
				end = i;
				del_line_len = i - start + 1;	
				break;
			}
			start = i + 1;
		}
	}

	memmove(buf+ start, buf + end + 1, buf_len - end);
	buf_len -= del_line_len;
}

void
printBuf(void)
{
	if (buf_len > 0) {
		fwrite(buf, 1, buf_len, stdout);
	} else {
		printf("?\n");
	}
}

int
readFile(file)
	const char *file;
{
	char line[1024];
	FILE *fp;

	fp = fopen(file, "r");
	if (!fp) {
		perror("unable to open file for reading");
		return 1;
	}

	if (!buf) {
		buf_cap = BUF_SIZE;
		buf = malloc(buf_cap);
		if (!buf) {
			perror("unable to alloc buf");
			fclose(fp);
			return 1;
		}
	} else {
		free(buf);
		buf_cap = BUF_SIZE;
		buf = malloc(buf_cap);
		if (!buf) {
			perror("unable to alloc buf");
			fclose(fp);
			return 1;
		}
	}

	buf_len = 0;

	while(fgets(line, sizeof(line), fp)) {
		size_t line_len = strlen(line);
		if (line_len > 0 && line[line_len - 1] == '\n') {
			line_len--;
		}

		while (buf_len + line_len + 1 > buf_cap) {
			buf_cap *= 2;
			buf = realloc(buf, buf_cap);
			if (!buf) {
				perror("unable to realloc buf");
				fclose(fp);
				return 1;
			}
		}

		memcpy(buf + buf_len, line, line_len);
		buf_len += line_len;
		buf[buf_len++] = '\n';
	} 

	fclose(fp);
	return 0;
}

int
writeFile(file)
	const char *file;
{
	FILE* fp;
	fp = fopen(file, "w");
	if (!fp) {
		perror("unable to open file for writing");
		return 1;
	}

	if (fwrite(buf, 1, buf_len, fp) != buf_len) {
		perror("unable to write buf to file");
		fclose(fp);
		return 1;
	}

	fclose(fp);
	return 0;
}

void
loop(void)
{
	char line[BUF_SIZE];
	char filename[BUF_SIZE];

	int line_num;

	while (1) {
		printf(": ");
		if (!fgets(line, BUF_SIZE, stdin)) {
			break;
		}

		if (line[0] == 'q') {
			break;
		} else if (line[0] == 'a') {
			while (1) {
				if (!fgets(line, BUF_SIZE, stdin)) {
					break;
				}

				if (line[0] == '.') {
					break;
				}

				appendLine(line);
			}
		} else if (line[0] == 'i') {
			if (sscanf(line, "i %d", &line_num) == 1) {
				if (!fgets(line, sizeof(line), stdin)) {
					printf("invalid input\n");
					continue;
				}

				insert(line);
			} else {
				printf("invalid input");
			}
		} else if (line[0] == 'c') {
			if (!fgets(line, sizeof(line), stdin)) {
				printf("invalid input\n");
				continue;
			}

			change(line);
		} else if (line[0] == 'd') {
			size_t line_num;
			line_num = atoi(line + 1);
			deleteLine(line_num);
		} else if (line[0] == 'p') {
			printBuf();
		} else if (line[0] == 'w') {
			sscanf(line, "w %s", filename);
			if (writeFile(filename) == 0) {
				printf("file written\n");
			} else {
				printf("failed to write file\n");
			}
		} else if (line[0] == 'r') {
			sscanf(line, "r %s", filename);
			if (readFile(filename) == 0) {
				printf("file read\n");
			} else {
				printf("failed to read file\n");
			}
		} else {
			printf("unknown command\n");
		}
	}
}
