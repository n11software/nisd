RUN 9 "JUNE 2024" NISD "Kernel man pages"
=========================================

# NAME

style - The style guide for NISD

# DESCRIPTION

This document outlines the coding style and conventions for the NISD project.

# COMMENTS

- **VERY important single-line comments** look like this:
  ```cpp
  /*
   * VERY important single-line comments look like this.
   */
  ```
- **Most single-line comments** look like this:
  ```cpp
  // Most single-line comments look like this.
  ```cpp
- **Multi-line comments** look like this. Make them real sentences. Fill them so they look like real paragraphs. Still try to stay under 72 characters:
  ```cpp
  /*
   * Multi-line comments look like this.  Make them real sentences.  Fill
   * them so they look like real paragraphs. Still try to stay under 72
   * characters.
   */
  ```cpp

# HEADER FILES

- A header file should protect itself from multiple inclusions. Use `#pragma once` for this:
  ```cpp
  #pragma once
  ```
- **Kernel headers** come first. These should be organized alphabetically:
  ```cpp
  #include <Boot/BOB.h>
  #include <CPU/GDT.h>
  #include <Inferno/Config.h>
  ```
- If **driver headers** are used, include them next, after a blank line:
  ```cpp
  #include <Drivers/RTC/RTC.h>
  #include <Drivers/PCI/PCI.h>
  ```
- If you're using any `/usr` include files, include them here after a blank line. These should also be sorted lexicographically:
  ```cpp
  #include <errno.h>
  #include <stdio.h>
  #include <stdlib.h>
  ```

# FUNCTION DECLARATIONS

Any functions that aren't used anywhere else are declared at the top of the source file:
```cpp
static char *Function(int a, int b, float c, int d);
```

INDENTATION
-----------

Tabs should always be used in place of spaces when indenting code. Indent size is 4 spaces. This is a good indicator when you have over-engineered your code. If you need 3-6 levels of indentation, you might want to consider fixing parts of your code; over 6 levels and your best bet is to restart the whole thing and write it again:
  ```cpp
int Foo(void) {
	int Bar = 0;
	int Baz = 0;
	int Qux = 0;
}
  ```

BRACKETS
--------

Brackets should always be on the same line as the parent statement:
```cpp
if (Foo == true) {

}

int main(int x) {

}
```

NAMESPACES
----------

Children properties in namespaces require indentation:
```cpp
namespace APIC {
	void Write();
	unsigned int Read();
	void Enable();
}
```

SWITCH STATEMENTS
-----------------

Case statements should be indented:
```cpp
switch (pd.size) {
	case 0:
		signedNum = va_arg(args, int);
		break;
	case 1:
		signedNum = va_arg(args, long);
		break;
}
```

HASH STATEMENTS
---------------

Hash statements are not indented:
```cpp
void Inferno(BOB* bob) {
#if enableGDT == true
	GDT::Table GDT = {
		{ 0, 0, 0, 0x00, 0x00, 0 },
		{ 0, 0, 0, 0x9a, 0xa0, 0 },
		{ 0, 0, 0, 0x92, 0xa0, 0 },
		{ 0, 0, 0, 0xfa, 0xa0, 0 },
		{ 0, 0, 0, 0xf2, 0xa0, 0 },
	};
	GDT::Descriptor descriptor;
	descriptor.size = sizeof(GDT) - 1;
	descriptor.offset = (unsigned long long)&GDT;
	LoadGDT(&descriptor);
#endif
}
```

CONDENSED STATEMENTS
--------------------

Condense any short statements to one line:
```cpp
if (Foo == 1) return 1;
```

LONG STATEMENTS
---------------

Break a long statement into multiple lines to avoid exceeding 80 characters:
```cpp
asm volatile("int $0x80" : "=a"(res) : "a"(1), 
            "d"((unsigned long)"Hello from syscall\n\r"), 
            "D"((unsigned long)0) : "rcx", "r11", "memory");
```

NAMING CONVENTIONS
------------------

We use 'CamelCase' for everything:
```cpp
struct Data;
size_t bufferSize;
char *mimeType();
```

EXCEPTIONS
----------

`main()`, `argc`, and `argv` do not follow our naming scheme:
```cpp
int main(int argc, char *argv[]) {

}
```

VARIABLE DECLARATIONS
---------------------

Declare any variables used within the function at the top of the function code. Sort by size and then by alphabetical order. Avoid initializing variables in the declarations:
```cpp
static char *Function(int a, int b, float c, int d) {
	extern u_char one;
	extern char two;
	struct foo three, *four;
	double five;
	int *six, seven;
	char *eight, *nine, ten;
}
```

GNU?
----

Lastly, print out a copy of the GNU coding standards and *burn it*. Do not read it, *burn it*, it doesn't deserve to be read.

AUTHOR
------

Ariston Lorenzo <me@ariston.dev>, Levi Frisleben <me@levihicks.dev>

