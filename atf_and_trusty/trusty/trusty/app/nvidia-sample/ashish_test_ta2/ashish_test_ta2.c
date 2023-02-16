#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <trusty_std.h>
#include <trusty_ipc.h>

//------------------------------- for uart driver


//#include <arch/arch.h>
//#include <arch/x86.h>  -- added by vishrut
//#include <arch/arm/mem_layout.h>
//#include <dev/arm_gicv2.h>
//#include <dev/console.h>
//#include <lib/error.h>
//#include <lib/gcc.h>
//#include <lib/types.h>
//#include <lib/sleep.h>

//#include "arm_uart_16450.h"

#if (_platform_ == _plat_tegra186_)
//#include <dev/interfaces/reset.h>
//#include <dev/interfaces/clock_controller.h>
//#include <dev/platform_tegrax2.h>
//#include <dev/tegrax2_bpmp.h>
//#include <lib/sleep.h>		//compiler path
#include "platform.h"		//in same directory or absolute path
#endif


// Register Offsets
#define THR 0x00 /* Transmit Holding Register */
#define RBR 0x00 /* Receiver Buffer Register */
#define DLL 0x00 /* Divisor Latch LSByte Register */
#define IER 0x04 /* Interrupt Enable Register */
#define DLH 0x04 /* Divisor Latch MSByte Register */
#define FCR 0x08 /* FIFO Control Register */
#define IIR 0x08 /* Interrupt Identification Register */
#define LCR 0x0c /* Line Control Register */
#define MCR 0x10 /* Modem Control Register */
#define LSR 0x14 /* Line Status Register */
#define MSR 0x18 /* Modem Status Register */
#define SPR 0x1c /* Scratchpad Register */
#define VSR 0x2c /* Vendor Status Register */
#define ASR 0x3c /* Auto-baud Sensing Register */

// LCR Masks
#define LCR_DLAB (1u << 7u)

// LSR Masks
#define LSR_RX_FIFO_EMPTY (1u << 9u)
#define LSR_TX_FIFO_FULL (1u << 8u)
#define LSR_FIFOE (1u << 7u)
#define LSR_TMTY (1u << 6u)
#define LSR_THRE (1u << 5u) // 0 = Full, 1 = Empty
#define LSR_BRK (1u << 4u)
#define LSR_FERR (1u << 3u)
#define LSR_PERR (1u << 2u)
#define LSR_OVRF (1u << 1u)
#define LSR_RDR (1u << 0u)

// LSR tx statuses
#define TX_BUSY 0u
#define TX_READY 1u

struct arm_uart_16450_t
{
    uintptr_t base;
    int id; /* optional id for multi-uart SOCs */
    bool echo_char;
    uint32_t console;
};


//--------------------------------------uart driver ends

#define LOG_TAG	"ashish_test_ta2"
#define TLOGE(fmt, ...) \
    fprintf(stderr, "%s: %d: " fmt, LOG_TAG, __LINE__,  ## __VA_ARGS__)

#define TEST_PORT  "com.android.trusty.ashish_test_ta2"

#define IPC_ASHISH_TA_2_UUID \
	{ 0xab8b35bd, 0x7fb8, 0x42f5, \
          { 0xaa, 0x28, 0x3c, 0xca, 0x9a, 0x2e, 0xb6, 0xdc } }

static void handle_port_event(const uevent_t * evnt) {
  uuid_t peer_uuid;

  if ((evnt->event & IPC_HANDLE_POLL_ERROR) ||
    (evnt->event & IPC_HANDLE_POLL_HUP) ||
    (evnt->event & IPC_HANDLE_POLL_MSG) ||
    (evnt->event & IPC_HANDLE_POLL_SEND_UNBLOCKED)) {
    /* should never happen with port handles */
    TLOGE("error event (0x%x) for port - ashish_test_ta2 - (%d)\n",
    	evnt->event, evnt->handle);
    	abort();
  }
  if (evnt->event & IPC_HANDLE_POLL_READY) {
    /* incoming connection: accept it */
    int rc = accept(evnt->handle, &peer_uuid);
    if (rc < 0) {
      	TLOGE("failed (%d) to accept on port - ashish_test_ta2 - %d\n",
        rc, evnt->handle);
      return;
    }

    TLOGE("ashish_test_ta2 successfully connected with ashish_test_ta on port - %d\n", evnt->handle);
  }
}


int main(void)
{
	int rc;
    	uevent_t uevt;
    	handle_t handle_port;

	//static const uuid_t ashish_ta_uuid2 = IPC_ASHISH_TA_2_UUID;

	TLOGE("Ashish: Starting test Trusted Application - 2\n");

	/* rc1 allows connections from secure world */
	rc = port_create(TEST_PORT, 1, 1024, IPC_PORT_ALLOW_TA_CONNECT | IPC_PORT_ALLOW_NS_CONNECT);


	if (rc < 0) {
        	TLOGE("failed (%d) to create port for test TA2 for secure world\n", rc);
        	return rc;
   	}


	TLOGE("Created port:%d for ashish_test_ta2 application\n", rc);

    	handle_port = (handle_t)rc;

	TLOGE("Waiting for any connection\n");

	while (true) {

		uevt.handle = INVALID_IPC_HANDLE;
    		uevt.event = 0;
    		uevt.cookie = NULL;

    		/* wait forever */
    		rc = wait(handle_port, &uevt, INFINITE_TIME);
    		if (rc == 0) {
      		
			/* got an event */
      			handle_port_event(&uevt);
    		} else {
      			TLOGE("wait returned (%d)\n", rc);
      			abort();
   		}
  	}

    	/* wait infinitely long absent any messages */
    	//rc = wait(handle, &uevt, INFINITE_TIME);
    	
	return 0; /* shouldn't get here */
}


