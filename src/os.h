#pragma once
#include "graphics.h"
#include "string.h"
#include "math.h"
#include "bootloader.h"
#include "memory.h"
#include "gdt.h"
#include "interrupts/idt.h"
#include "interrupts/interrupts.h"
#include "io.h"
#include "keyboard.h"
#include <stdint.h>

extern uint64_t KernelStart;
extern uint64_t KernelEnd;

int InitOS(BootData* bootdata);
int StartOS(BootData* bootdata);