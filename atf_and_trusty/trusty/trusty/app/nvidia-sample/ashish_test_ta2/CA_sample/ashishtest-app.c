#include <stdio.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>
#include <tipc.h>

#define TIPC_DEFAULT_DEVNAME "/dev/trusty-ipc-dev0"
#define SERVICE_NAME "com.android.trusty.ashish_test_ta2"

static const char *dev_name = TIPC_DEFAULT_DEVNAME;
static const char *service_name = SERVICE_NAME;

int main(void){
        printf("Trying to connect TA ashish_test_ta from rich OS...\n");
        int rc;

        rc = tipc_connect(dev_name, service_name);

        if(rc < 0){
                fprintf(stderr, "Failed to connect to secure service\n");
        }
	
	printf("Connection to secure OS success!!\n");

        return 0;
}
