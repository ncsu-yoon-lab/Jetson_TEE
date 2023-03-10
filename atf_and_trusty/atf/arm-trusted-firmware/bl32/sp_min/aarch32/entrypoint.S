/*
 * Copyright (c) 2016-2017, ARM Limited and Contributors. All rights reserved.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */

#include <arch.h>
#include <asm_macros.S>
#include <bl_common.h>
#include <context.h>
#include <el3_common_macros.S>
#include <runtime_svc.h>
#include <smccc_helpers.h>
#include <smccc_macros.S>
#include <xlat_tables_defs.h>

	.globl	sp_min_vector_table
	.globl	sp_min_entrypoint
	.globl	sp_min_warm_entrypoint


vector_base sp_min_vector_table
	b	sp_min_entrypoint
	b	plat_panic_handler	/* Undef */
	b	handle_smc		/* Syscall */
	b	plat_panic_handler	/* Prefetch abort */
	b	plat_panic_handler	/* Data abort */
	b	plat_panic_handler	/* Reserved */
	b	plat_panic_handler	/* IRQ */
	b	plat_panic_handler	/* FIQ */


/*
 * The Cold boot/Reset entrypoint for SP_MIN
 */
func sp_min_entrypoint
#if !RESET_TO_SP_MIN
	/* ---------------------------------------------------------------
	 * Preceding bootloader has populated r0 with a pointer to a
	 * 'bl_params_t' structure & r1 with a pointer to platform
	 * specific structure
	 * ---------------------------------------------------------------
	 */
	mov	r11, r0
	mov	r12, r1

	/* ---------------------------------------------------------------------
	 * For !RESET_TO_SP_MIN systems, only the primary CPU ever reaches
	 * sp_min_entrypoint() during the cold boot flow, so the cold/warm boot
	 * and primary/secondary CPU logic should not be executed in this case.
	 *
	 * Also, assume that the previous bootloader has already set up the CPU
	 * endianness and has initialised the memory.
	 * ---------------------------------------------------------------------
	 */
	el3_entrypoint_common					\
		_set_endian=0					\
		_warm_boot_mailbox=0				\
		_secondary_cold_boot=0				\
		_init_memory=0					\
		_init_c_runtime=1				\
		_exception_vectors=sp_min_vector_table

	/* ---------------------------------------------------------------------
	 * Relay the previous bootloader's arguments to the platform layer
	 * ---------------------------------------------------------------------
	 */
	mov	r0, r11
	mov	r1, r12
#else
	/* ---------------------------------------------------------------------
	 * For RESET_TO_SP_MIN systems which have a programmable reset address,
	 * sp_min_entrypoint() is executed only on the cold boot path so we can
	 * skip the warm boot mailbox mechanism.
	 * ---------------------------------------------------------------------
	 */
	el3_entrypoint_common					\
		_set_endian=1					\
		_warm_boot_mailbox=!PROGRAMMABLE_RESET_ADDRESS	\
		_secondary_cold_boot=!COLD_BOOT_SINGLE_CPU	\
		_init_memory=1					\
		_init_c_runtime=1				\
		_exception_vectors=sp_min_vector_table

	/* ---------------------------------------------------------------------
	 * For RESET_TO_SP_MIN systems, BL32 (SP_MIN) is the first bootloader
	 * to run so there's no argument to relay from a previous bootloader.
	 * Zero the arguments passed to the platform layer to reflect that.
	 * ---------------------------------------------------------------------
	 */
	mov	r0, #0
	mov	r1, #0
#endif /* RESET_TO_SP_MIN */

	bl	sp_min_early_platform_setup
	bl	sp_min_plat_arch_setup

	/* Jump to the main function */
	bl	sp_min_main

	/* -------------------------------------------------------------
	 * Clean the .data & .bss sections to main memory. This ensures
	 * that any global data which was initialised by the primary CPU
	 * is visible to secondary CPUs before they enable their data
	 * caches and participate in coherency.
	 * -------------------------------------------------------------
	 */
	ldr	r0, =__DATA_START__
	ldr	r1, =__DATA_END__
	sub	r1, r1, r0
	bl	clean_dcache_range

	ldr	r0, =__BSS_START__
	ldr	r1, =__BSS_END__
	sub	r1, r1, r0
	bl	clean_dcache_range

	bl	smc_get_next_ctx

	/* r0 points to `smc_ctx_t` */
	/* The PSCI cpu_context registers have been copied to `smc_ctx_t` */
	b	sp_min_exit
endfunc sp_min_entrypoint


/*
 * SMC handling function for SP_MIN.
 */
func handle_smc
	/* On SMC entry, `sp` points to `smc_ctx_t`. Save `lr`. */
	str	lr, [sp, #SMC_CTX_LR_MON]

	smccc_save_gp_mode_regs

	/*
	 * `sp` still points to `smc_ctx_t`. Save it to a register
	 * and restore the C runtime stack pointer to `sp`.
	 */
	mov	r2, sp				/* handle */
	ldr	sp, [r2, #SMC_CTX_SP_MON]

	ldr	r0, [r2, #SMC_CTX_SCR]
	and	r3, r0, #SCR_NS_BIT		/* flags */

	/* Switch to Secure Mode*/
	bic	r0, #SCR_NS_BIT
	stcopr	r0, SCR
	isb

	/*
	 * Set PMCR.DP to 1 to prohibit cycle counting whilst in Secure Mode.
	 * Also, the PMCR.LC field has an architecturally UNKNOWN value on reset
	 * and so set to 1 as ARM has deprecated use of PMCR.LC=0.
	 */
	ldcopr	r0, PMCR
	orr	r0, r0, #(PMCR_LC_BIT | PMCR_DP_BIT)
	stcopr	r0, PMCR

	ldr	r0, [r2, #SMC_CTX_GPREG_R0]	/* smc_fid */
	/* Check whether an SMC64 is issued */
	tst	r0, #(FUNCID_CC_MASK << FUNCID_CC_SHIFT)
	beq	1f
	/* SMC32 is not detected. Return error back to caller */
	mov	r0, #SMC_UNK
	str	r0, [r2, #SMC_CTX_GPREG_R0]
	mov	r0, r2
	b	sp_min_exit
1:
	/* SMC32 is detected */
	mov	r1, #0				/* cookie */
	bl	handle_runtime_svc

	/* `r0` points to `smc_ctx_t` */
	b	sp_min_exit
endfunc handle_smc

/*
 * The Warm boot entrypoint for SP_MIN.
 */
func sp_min_warm_entrypoint
	/*
	 * On the warm boot path, most of the EL3 initialisations performed by
	 * 'el3_entrypoint_common' must be skipped:
	 *
	 *  - Only when the platform bypasses the BL1/BL32 (SP_MIN) entrypoint by
	 *    programming the reset address do we need to set the CPU endianness.
	 *    In other cases, we assume this has been taken care by the
	 *    entrypoint code.
	 *
	 *  - No need to determine the type of boot, we know it is a warm boot.
	 *
	 *  - Do not try to distinguish between primary and secondary CPUs, this
	 *    notion only exists for a cold boot.
	 *
	 *  - No need to initialise the memory or the C runtime environment,
	 *    it has been done once and for all on the cold boot path.
	 */
	el3_entrypoint_common					\
		_set_endian=PROGRAMMABLE_RESET_ADDRESS		\
		_warm_boot_mailbox=0				\
		_secondary_cold_boot=0				\
		_init_memory=0					\
		_init_c_runtime=0				\
		_exception_vectors=sp_min_vector_table

	/*
	 * We're about to enable MMU and participate in PSCI state coordination.
	 *
	 * The PSCI implementation invokes platform routines that enable CPUs to
	 * participate in coherency. On a system where CPUs are not
	 * cache-coherent without appropriate platform specific programming,
	 * having caches enabled until such time might lead to coherency issues
	 * (resulting from stale data getting speculatively fetched, among
	 * others). Therefore we keep data caches disabled even after enabling
	 * the MMU for such platforms.
	 *
	 * On systems with hardware-assisted coherency, or on single cluster
	 * platforms, such platform specific programming is not required to
	 * enter coherency (as CPUs already are); and there's no reason to have
	 * caches disabled either.
	 */
	mov	r0, #DISABLE_DCACHE
	bl	bl32_plat_enable_mmu

#if HW_ASSISTED_COHERENCY || WARMBOOT_ENABLE_DCACHE_EARLY
	ldcopr	r0, SCTLR
	orr	r0, r0, #SCTLR_C_BIT
	stcopr	r0, SCTLR
	isb
#endif

	bl	sp_min_warm_boot
	bl	smc_get_next_ctx
	/* r0 points to `smc_ctx_t` */
	/* The PSCI cpu_context registers have been copied to `smc_ctx_t` */
	b	sp_min_exit
endfunc sp_min_warm_entrypoint

/*
 * The function to restore the registers from SMC context and return
 * to the mode restored to SPSR.
 *
 * Arguments : r0 must point to the SMC context to restore from.
 */
func sp_min_exit
	monitor_exit
endfunc sp_min_exit
