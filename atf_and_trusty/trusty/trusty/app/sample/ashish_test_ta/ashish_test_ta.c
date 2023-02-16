#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <trusty_std.h>
#include <trusty_ipc.h>
//#include <debug.h>

#define LOG_TAG	"ashish_test_ta"
#define TLOGE(fmt, ...) \
    fprintf(stderr, "%s: %d: " fmt, LOG_TAG, __LINE__,  ## __VA_ARGS__)

#define TEST_PORT  "com.android.trusty.ashish_test_ta"

#define IPC_ASHISH_TA_UUID \
	{ 0x7cad3798, 0x6ed5, 0x11ed, \
          { 0xa1, 0xeb, 0x02, 0x42, 0xac, 0x12, 0x00, 0x02 } }

int main(void)
{
	int rc;
//    	uevent_t uevt;
//    	handle_t handle;

	//static const uuid_t ashish_ta_uuid = IPC_ASHISH_TA_UUID;

	TLOGE("Ashish: Starting test Trusted Application, UART DEBUG Port: %d, UART default debug port: N-A \n", DEBUG_PORT);
	//uart_putc(3, '~' );
	//char var = '~';
	//platform_dputc( var );

	/* rc1 allows connections from secure world */
	rc = port_create(TEST_PORT, 1, 1024, IPC_PORT_ALLOW_TA_CONNECT);


	if (rc < 0) {
        	TLOGE("failed (%d) to create port for test TA for secure world\n", rc);
        	return rc;
   	}

	TLOGE("Created port:%d for ashish_test_ta application\n", rc);

    	//handle = (handle_t)rc;

    	/* wait infinitely long absent any messages */
    	//rc = wait(handle, &uevt, INFINITE_TIME);

	TLOGE("Waiting for ashish_test_ta2 to create port....\n");

	rc = connect("com.android.trusty.ashish_test_ta2", IPC_CONNECT_WAIT_FOR_PORT);

	if (rc < 0) {
		/* generate an event */
		TLOGE("Connection request was not successful on port:%d for ashish_test_ta application\n", rc);

	} else {
		TLOGE("Connection complete\n");
		abort();
	}

	TLOGE("Connection request successful to the port:%d for ashish_test_ta application\n", rc);

	//TLOGE("The TA application ashish_test_ta should not reach here\n");
		
	return 0; /* shouldn't get here */
}
