#ifndef __t186ref_build_t186_config_h_H
#define __t186ref_build_t186_config_h_H
#define LK 1
#define MMU_USER_SIZE_SHIFT 25
#define WITH_NO_PHYS_RELOCATION 1
#define HEAP_GROW_SIZE 65536
#define TIMER_ARM_GENERIC_SELECTED CNTPS
#define WORKAROUND_CVE_2018_3639 1
#define DEBUG_PORT 1
#define ARM_CLUSTER0_INIT_L2 1
#define MMU_IDENT_SIZE_SHIFT 39
#define MEMBASE 0XFFFFFFFFEA800000
#define MEMSIZE 0X8000000
#define VMEMSIZE 0X8000000
#define MMU_WITH_TRAMPOLINE 1
#define SOC_T186 1
#define ROC_FLUSH_ENABLE 1
#define ARM64_CPU_ 1
#define ARM_ISA_ARMV8 1
#define IS_64BIT 1
#define ARCH_DEFAULT_STACK_SIZE 4096
#define WITH_SMP 1
#define SMP_MAX_CPUS 8
#define SMP_CPU_CLUSTER_SHIFT 8
#define SMP_CPU_ID_BITS 24
#define KERNEL_ASPACE_BASE 0XFFFFFFFFE0000000
#define KERNEL_ASPACE_SIZE 0X0000000020000000
#define KERNEL_BASE 0XFFFFFFFFEA800000
#define KERNEL_LOAD_OFFSET 0
#define PLATFORM_HAS_DYNAMIC_TIMER 1
#define WITH_TRUSTY_IPC 1
#define WITH_SYSCALL_TABLE 1
#define UTHREAD_WITH_MEMORY_MAPPING_SUPPORT 1
#define PROJECT_T186 1
#define PROJECT "T186"
#define TARGET_T186 1
#define TARGET "T186"
#define PLATFORM_T18X 1
#define PLATFORM "T18X"
#define ARCH_ARM64 1
#define ARCH "ARM64"
#define DEBUG 0
#define WITH_APP 1
#define WITH_DEV 1
#define WITH_DEV_INTERRUPT_ARM_GIC 1
#define WITH_DEV_TIMER_ARM_GENERIC 1
#define WITH_KERNEL 1
#define WITH_KERNEL_VM 1
#define WITH_LIB_BOOT_PROFILER 1
#define WITH_LIB_DEBUG 1
#define WITH_LIB_FIXED_POINT 1
#define WITH_LIB_HEAP 1
#define WITH_LIB_LIBC 1
#define WITH_LIB_MEMLOG 1
#define WITH_LIB_SM 1
#define WITH_LIB_SYSCALL 1
#define WITH_LIB_TRUSTY 1
#define WITH_LIB_UTHREAD 1
#define WITH_LIB_VERSION 1
#define WITH_PLATFORM 1
#define WITH_TARGET 1
#define LK_DEBUGLEVEL 0
#define GLOBAL_INCLUDES "_I__T186REF_BUILD_T186__ILK_TRUSTY_INCLUDE__ILK_COMMON_INCLUDE__ITEGRA_PUBLIC_INCLUDE__IAPP_INCLUDE__IEXTERNAL_INCLUDE__IEXTERNAL_HEADERS_INCLUDE__ILIB_INCLUDE__IDEVICE_NVIDIA_T186_INCLUDE__ITEGRA_PUBLIC_TARGET_T186_INCLUDE__ITEGRA_PUBLIC_PLATFORM_T18X_INCLUDE__ITEGRA_PUBLIC_PLATFORM_TEGRA_COMMON_INCLUDE__ILK_COMMON_ARCH_ARM64_INCLUDE__ILK_COMMON_DEV_INTERRUPT_ARM_GIC_INCLUDE__ILK_COMMON_DEV_TIMER_ARM_GENERIC_INCLUDE__ITEGRA_PUBLIC_LIB_BOOT_PROFILER_INCLUDE__ILK_TRUSTY_LIB_SM_INCLUDE__ILK_TRUSTY_LIB_TRUSTY_INCLUDE__ILK_COMMON_LIB_FIXED_POINT_INCLUDE__ILK_TRUSTY_LIB_SYSCALL_INCLUDE__ILK_TRUSTY_LIB_UTHREAD_INCLUDE__ILK_TRUSTY_LIB_UTHREAD_ARCH_ARM64_INCLUDE__ILK_TRUSTY_LIB_VERSION_INCLUDE"
#define GLOBAL_COMPILEFLAGS "_G__FNO_BUILTIN__FINLINE__INCLUDE___T186REF_BUILD_T186_CONFIG_H__W__WALL__WNO_MULTICHAR__WNO_UNUSED_PARAMETER__WNO_NONNULL_COMPARE__FFUNCTION_SECTIONS__FDATA_SECTIONS"
#define GLOBAL_OPTFLAGS "_O2"
#define GLOBAL_CFLAGS "__STD GNU99__WERROR_IMPLICIT_FUNCTION_DECLARATION__WSTRICT_PROTOTYPES__WWRITE_STRINGS__WEXTRA__WFORMAT__WFORMAT_SECURITY__WUNUSED_FUNCTION__WERROR"
#define GLOBAL_CPPFLAGS "_FNO_EXCEPTIONS__FNO_RTTI__FNO_THREADSAFE_STATICS"
#define GLOBAL_ASMFLAGS "_DASSEMBLY"
#define GLOBAL_LDFLAGS "__LLK_TRUSTY__LLK_COMMON__LTEGRA_PUBLIC__LAPP__LEXTERNAL__LEXTERNAL_HEADERS__LLIB__LDEVICE_NVIDIA_T186___GC_SECTIONS"
#endif
