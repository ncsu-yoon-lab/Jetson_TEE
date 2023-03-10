/*
 * Copyright (c) 2013-2018, ARM Limited and Contributors. All rights reserved.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */
#ifndef __ASM_MACROS_COMMON_S__
#define __ASM_MACROS_COMMON_S__

	/*
	 * This macro is used to create a function label and place the
	 * code into a separate text section based on the function name
	 * to enable elimination of unused code during linking. It also adds
	 * basic debug information to enable call stack printing most of the
	 * time.
	 */
	.macro func _name
	/*
	 * Add Call Frame Information entry in the .debug_frame section for
	 * debugger consumption. This enables callstack printing in debuggers.
	 * This does not use any space in the final loaded binary, only in the
	 * ELF file.
	 * Note that a function manipulating the CFA pointer location (i.e. the
	 * x29 frame pointer on AArch64) should declare it using the
	 * appropriate .cfi* directives, or be prepared to have a degraded
	 * debugging experience.
	 */
	.cfi_sections .debug_frame
	.section .text.\_name, "ax"
	.type \_name, %function
	/*
	 * .cfi_startproc and .cfi_endproc are needed to output entries in
	 * .debug_frame
	 */
	.cfi_startproc
	\_name:
	.endm

	/*
	 * This macro is used to mark the end of a function.
	 */
	.macro endfunc _name
	.cfi_endproc
	.size \_name, . - \_name
	.endm

	/*
	 * Theses macros are used to create function labels for deprecated
	 * APIs. If ERROR_DEPRECATED is non zero, the callers of these APIs
	 * will fail to link and cause build failure.
	 */
#if ERROR_DEPRECATED
	.macro func_deprecated _name
	func deprecated\_name
	.endm

	.macro endfunc_deprecated _name
	endfunc deprecated\_name
	.endm
#else
	.macro func_deprecated _name
	func \_name
	.endm

	.macro endfunc_deprecated _name
	endfunc \_name
	.endm
#endif

	/*
	 * Helper assembler macro to count trailing zeros. The output is
	 * populated in the `TZ_COUNT` symbol.
	 */
	.macro count_tz _value, _tz_count
	.if \_value
	  count_tz "(\_value >> 1)", "(\_tz_count + 1)"
	.else
	  .equ TZ_COUNT, (\_tz_count - 1)
	.endif
	.endm

	/*
	 * This macro declares an array of 1 or more stacks, properly
	 * aligned and in the requested section
	 */
#define DEFAULT_STACK_ALIGN	(1 << 6)   /* In case the caller doesnt provide alignment */

	.macro declare_stack _name, _section, _size, _count, _align=DEFAULT_STACK_ALIGN
	count_tz \_align, 0
	.if (\_align - (1 << TZ_COUNT))
	  .error "Incorrect stack alignment specified (Must be a power of 2)."
	.endif
	.if ((\_size & ((1 << TZ_COUNT) - 1)) <> 0)
	  .error "Stack size not correctly aligned"
	.endif
	.section    \_section, "aw", %nobits
	.align TZ_COUNT
	\_name:
	.space ((\_count) * (\_size)), 0
	.endm


#endif /* __ASM_MACROS_COMMON_S__ */
