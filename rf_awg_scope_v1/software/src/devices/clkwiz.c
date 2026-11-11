#include "io_control.h"
#include "clkwiz.h"
#include <stdio.h>

/* Bounded lock waits; MMCM input=153.6 MHz, multiplier=8, divide=20. */
int clkwiz(uint32_t base, uint32_t frequency) {
    unsigned n;
    if (frequency != 61440000U) return -1;
    for (n=0; n<1000000; ++n)
        if (AXI_REG_READ(base, 4) & 1U) break;
    if (n==1000000) return -1;
    AXI_REG_WRITE(base, 0x208, 20);
    AXI_REG_WRITE(base, 0x25c, 3);
    for (n=0; n<1000000; ++n)
        if (AXI_REG_READ(base, 4) & 1U) break;
    if (n==1000000 || AXI_REG_READ(base, 0x208) != 20) return -1;
    printf("AWG data_clk configured=61440000Hz\n");
    return 0;
}
