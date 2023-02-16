#include <trusty_app_manifest.h>
#include <stddef.h>
#include <stdio.h>

trusty_app_manifest_t TRUSTY_APP_MANIFEST_ATTRS trusty_app_manifest =
{
	/*
	 * Each trusted app UUID should have a unique UUID that is
	 * generated from a UUID generator such as
         * https://www.uuidgenerator.net/
	 *
	 * UUID : {92b92883-f96a-4177-97d1-69b2e278a46f}
	 * UUID 1: {7cad3798-6ed5-11ed-a1eb-0242ac120002}
	 * UUID 2: {ab8b35bd-7fb8-42f5-aa28-3cca9a2eb6dc}
	 */


	{ 0xab8b35bd, 0x7fb8, 0x42f5,
	  { 0xaa, 0x28, 0x3c, 0xca, 0x9a, 0x2e, 0xb6, 0xdc } },

	/* Optional configuration options here */
	{

		//TRUSTY_APP_CONFIG_MIN_HEAP_SIZE(MIN_HEAP_SIZE),
		//TRUSTY_APP_CONFIG_MIN_STACK_SIZE(MIN_STACK_SIZE),

		/* SE register mapping */
		//TRUSTY_APP_CONFIG_MAP_MEM(1, TEGRA_SE_BASE, TEGRA_SE_SIZE),

		/* I/O mapping request */
		//TRUSTY_APP_CONFIG_MAP_MEM(0, TEGRA_DEVICE_ADDR, TEGRA_DEVICE_ADDR_LEN),

		/* fuse mapping */
		//TRUSTY_APP_CONFIG_MAP_MEM(2, TEGRA_FUSE_BASE, TEGRA_FUSE_SIZE),
		

		/* four pages for heap */
                TRUSTY_APP_CONFIG_MIN_HEAP_SIZE(4 * 4096),

		/* one page for stack */
		TRUSTY_APP_CONFIG_MIN_STACK_SIZE(4096),

                /* request two I/O mappings */
		//Vishrut I/O map of serial-- not sure of size: larger size should not cause any issue
		TRUSTY_APP_CONFIG_MAP_MEM(1, 0xc280000, 0x100)


		
	},
};
