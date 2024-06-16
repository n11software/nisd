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
#include "ed.h"

int
main(argc, argv)
	int argc;
	char *argv[];
{
	if (argv[1] == "-h") {
		printf("usage: ed [-hv]\n");
		return 0;
	} else if (argv[1] == "-v") {
		printf("NISD ed v0.1\n");
		printf("Copyright (c) 2023, 2024\n\	N11 Software. All rights reserved.\n");
		return 0;
	}

	if (init() != 0) {
		return 1;
	}

	loop();
	clean();

	return 0;
}
