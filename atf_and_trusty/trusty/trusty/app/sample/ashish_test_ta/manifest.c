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
	 * UUID : {7cad3798-6ed5-11ed-a1eb-0242ac120002}
	 */


	{ 0x7cad3798, 0x6ed5, 0x11ed,
	  { 0xa1, 0xeb, 0x02, 0x42, 0xac, 0x12, 0x00, 0x02 } },

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

		/* four pages for stack */
		TRUSTY_APP_CONFIG_MIN_STACK_SIZE(4 * 4096),

                /* request two I/O mappings */
                TRUSTY_APP_CONFIG_MAP_MEM(1, 0x70000000, 0x1000),
                TRUSTY_APP_CONFIG_MAP_MEM(2, 0x70000804, 0x4)


		
	},
};
