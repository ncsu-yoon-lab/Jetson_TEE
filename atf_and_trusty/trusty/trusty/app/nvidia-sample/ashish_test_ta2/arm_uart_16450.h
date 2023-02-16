#ifndef _ARM_UART_16450_H_
#define _ARM_UART_16450_H_

#include <lib/common.h>
#include <trap.h>
#include <dev/interfaces/device.h>

extern gcc_data struct char_operation_t arm_uart_16450_call;
extern gcc_data struct device_life_cycle_t arm_uart_16450_life;

void arm_uart_16450_interrupt_handler(struct device_node_t *node, tf_t *tf);

typedef uint32_t console_id;

struct arm_uart_16450_t
{
    uintptr_t base;
    int id; /* optional id for multi-uart SOCs */
    bool echo_char;
    console_id console;
};


#endif /* _ARM_UART_16450_H_ */
