/*
 * Copyright (c) 2016-2018, ARM Limited and Contributors. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * Redistributions of source code must retain the above copyright notice, this
 * list of conditions and the following disclaimer.
 *
 * Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * Neither the name of ARM nor the names of its contributors may be used
 * to endorse or promote products derived from this software without specific
 * prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

#include <arch.h>
#include <asm_macros.S>
#include <common_def.h>
#include <memctrl_v2.h>
#include <tegra_def.h>

#define TEGRA194_STATE_SYSTEM_SUSPEND	0x5C7
#define TEGRA194_STATE_SYSTEM_RESUME	0x600D
#define TEGRA194_SMMU_CTX_SIZE		0x80D

	.align 4
	.globl	tegra194_cpu_reset_handler

/* CPU reset handler routine */
func tegra194_cpu_reset_handler
	/* check if we are exiting system suspend state */
	adr	x0, __tegra194_system_suspend_state
	ldr	x1, [x0]
	mov	x2, #TEGRA194_STATE_SYSTEM_SUSPEND
	lsl	x2, x2, #16
	add	x2, x2, #TEGRA194_STATE_SYSTEM_SUSPEND
	cmp	x1, x2
	bne	boot_cpu

	/* set system resume state */
	mov	x1, #TEGRA194_STATE_SYSTEM_RESUME
	lsl	x1, x1, #16
	mov	x2, #TEGRA194_STATE_SYSTEM_RESUME
	add	x1, x1, x2
	str	x1, [x0]
	dsb	sy

	/* prepare to relocate to TZSRAM */
	mov	x0, #BL31_BASE
	adr	x1, __tegra194_cpu_reset_handler_end
	adr	x2, __tegra194_cpu_reset_handler_data
	ldr	x2, [x2, #8]

	/* memcpy16 */
m_loop16:
	cmp	x2, #16
	b.lt	m_loop1
	ldp	x3, x4, [x1], #16
	stp	x3, x4, [x0], #16
	sub	x2, x2, #16
	b	m_loop16
	/* copy byte per byte */
m_loop1:
	cbz	x2, boot_cpu
	ldrb	w3, [x1], #1
	strb	w3, [x0], #1
	subs	x2, x2, #1
	b.ne	m_loop1

	/*
	 * Synchronization barriers to make sure that memory is flushed out
	 * before we start execution in SysRAM.
	 */
	dsb	sy
	isb

boot_cpu:
	adr	x0, __tegra194_cpu_reset_handler_data
	ldr	x0, [x0]
	br	x0
endfunc tegra194_cpu_reset_handler

	/*
	 * Tegra194 reset data (offset 0x0 - 0x2490)
	 *
	 * 0x0000: secure world's entrypoint
	 * 0x0008: BL31 size (RO + RW)
	 * 0x0010: SMMU context start
	 * 0x2490: SMMU context end
	 */

	.align 4
	.type	__tegra194_cpu_reset_handler_data, %object
	.globl	__tegra194_cpu_reset_handler_data
__tegra194_cpu_reset_handler_data:
	.quad	tegra_secure_entrypoint
	.quad	__BL31_END__ - BL31_BASE
	.globl	__tegra194_smmu_ctx_start

	.globl	__tegra194_system_suspend_state
__tegra194_system_suspend_state:
	.quad	0

	.align 4
__tegra194_smmu_context:
	.rept	TEGRA194_SMMU_CTX_SIZE
	.quad	0
	.endr
	.size	__tegra194_cpu_reset_handler_data, \
		. - __tegra194_cpu_reset_handler_data

	.align 4
	.globl	__tegra194_cpu_reset_handler_end
__tegra194_cpu_reset_handler_end:

	.globl tegra194_get_cpu_reset_handler_size
	.globl tegra194_get_cpu_reset_handler_base
	.globl tegra194_get_smmu_ctx_offset
	.globl tegra194_set_system_suspend_entry

/* return size of the CPU reset handler */
func tegra194_get_cpu_reset_handler_size
	adr	x0, __tegra194_cpu_reset_handler_end
	adr	x1, tegra194_cpu_reset_handler
	sub	x0, x0, x1
	ret
endfunc tegra194_get_cpu_reset_handler_size

/* return the start address of the CPU reset handler */
func tegra194_get_cpu_reset_handler_base
	adr	x0, tegra194_cpu_reset_handler
	ret
endfunc tegra194_get_cpu_reset_handler_base

/* return the size of the SMMU context */
func tegra194_get_smmu_ctx_offset
	adr	x0, __tegra194_smmu_context
	adr	x1, tegra194_cpu_reset_handler
	sub	x0, x0, x1
	ret
endfunc tegra194_get_smmu_ctx_offset

/* set system suspend state before SC7 entry */
func tegra194_set_system_suspend_entry
	mov	x0, #TEGRA_MC_BASE
	mov	x3, #MC_SECURITY_CFG3_0
	ldr	w1, [x0, x3]
	lsl	x1, x1, #32
	mov	x3, #MC_SECURITY_CFG0_0
	ldr	w2, [x0, x3]
	orr	x3, x1, x2			/* TZDRAM base */
	adr	x0, __tegra194_system_suspend_state
	adr	x1, tegra194_cpu_reset_handler
	sub	x2, x0, x1			/* offset in TZDRAM */
	mov	x0, #TEGRA194_STATE_SYSTEM_SUSPEND
	lsl	x0, x0, #16
	add	x0, x0, #TEGRA194_STATE_SYSTEM_SUSPEND
	str	x0, [x3, x2]			/* set value in TZDRAM */
	dsb	sy
	ret
endfunc tegra194_set_system_suspend_entry
