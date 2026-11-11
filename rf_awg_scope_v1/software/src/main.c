/******************************************************************************
 *
 * Copyright (C) 2018 Xilinx, Inc.  All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
 * OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 * Except as contained in this notice, the name of the Xilinx shall not be used
 * in advertising or otherwise to promote the sale, use or other dealings in
 * this Software without prior written authorization from Xilinx.
 *
 ******************************************************************************/
/****************************************************************************/
/**
 *
 * @file xrfdc_mts_example.c
 *
 * RFSoC MultiTile Sync Example test application
 *
 * This example calls the RFdc Multi-tile-sync (MTS) API with the
 * following configuration:
 * Tiles to Sync: DAC0, DAC1, ADC0, ADC1, ADC2, ADC3.
 * <pre>
 *
 * MODIFICATION HISTORY:
 *
 * Ver   Who    Date     Changes
 * ----- -----  -------- -----------------------------------------------------
 * 3.1   jm     01/24/18 First release
 * 5.0   sk     09/05/18 Rename XRFdc_MTS_RMW_DRP as XRFdc_ClrSetReg.
 * 5 0   mus    08/18/18 Updated to remove xparameters.h dependency for linux
 *                       platform.
 *
 * </pre>
 *
 *****************************************************************************/

/***************************** Include Files ********************************/

#include "xparameters.h"
#include "rfsoc_cfg.h"
#include "io_control.h"
#include "platform_drivers.h"
#include "spi_ctrl.h"
#include "xtime_l.h"
#include "xrfdc.h"
#include "xrfdc_dcp.h"
#include "xsdps.h"
#include "xadc.h"
#include "gps_read.h"
#include "xil_cache.h"
/************************** Constant Definitions ****************************/

/*
 * The following constants map to the XPAR parameters created in the
 * xparameters.h file. They are defined here such that a user can easily
 * change all the needed parameters in one place.
 */

#define RFDC_DEVICE_ID 	XPAR_XRFDC_0_DEVICE_ID
#define DAC_EXPECTED_RATE_GSPS 9.0
#define ADC_EXPECTED_RATE_GSPS 5.0
#define DAC_FABRIC_CLOCK_HZ 562500000U
#define ADC_FABRIC_CLOCK_HZ 416666667U

/**************************** Type Definitions ******************************/


/***************** Macros (Inline Functions) Definitions ********************/


/************************** Function Prototypes *****************************/

/************************** Variable Definitions ****************************/
uint32_t axi_lite_addr = XPAR_UP_AXI_0_BASEADDR;
volatile uint32_t init_stage_debug = 0;
/* Separate cache lines let JTAG and the running CPU exchange boot flags. */
volatile uint32_t awg_clock_ready __attribute__((aligned(64))) = 0;
volatile uint32_t awg_pl_program_ack __attribute__((aligned(64))) = 0;
volatile uint32_t lmk_lock_debug = 0;
volatile uint32_t qmc_debug = 0;
extern spi_device lmk04828_spi;
XRFdc RFdcInstPtr;
uint64_t FS;
uint16_t auxdac=1600;
/* The reference rf_adda_demo uses CLKIN1 external mode with PLL1 bypassed;
 * in this mode PLL1 lock status is expected low while PLL2 must lock. */
uint32_t ref_ext_en = 0;
uint32_t sample_rate;
uint32_t clock_1pps;
XRFdc_DSA_Settings SettingsPtr;
uint32_t txatt[8] = { 40500, 40500, 40500, 40500, 40500, 40500, 40500, 40500 };
/****************************************************************************/
/**
 *
 * Main function that invokes the MTS example in this file.
 *
 * @param	None.
 *
 * @return
 *		- XRFDC_SUCCESS if the example has completed successfully.
 *		- XRFDC_FAILURE if the example has failed.
 *
 * @note		None.
 *
 *****************************************************************************/
int main(void)
{
	/* rf_mode is only four bits; retain the full diagnostic stage in RAM. */
#define INIT_STAGE(_n) do { init_stage_debug = (_n); } while (0)

	int Status;
	extern void awg_enable_driver_log(void);
	awg_enable_driver_log();
	print("**************************************************\n\r");
	print("********RFEVM CH8 trxloop begin MOD RFSOM*********\n\r");
	print("**************************************************\n\r");
	printf("Please wait...\n");
	INIT_STAGE(1);
	int32_t platform_status = platform_init();
	if (platform_status != XST_SUCCESS) {
		INIT_STAGE(platform_status);
		printf("AWG INIT FAILED: platform initialization status=%ld\r\n", (long)platform_status);
		return XRFDC_FAILURE;
	}
	printf("AWG INIT: platform initialized\r\n");
	INIT_STAGE(2);
//	gpio_set_value(TRX_SW, 1);
//	gpio_set_value(FDDTDD_SW, 1);
	/* LMK04828 RESET is active-high.  Hold it high long enough to reset the
	 * device, then drive it low to release the part before programming SPI.
	 * The previous low-then-high sequence left the clock chip permanently in
	 * reset, so every SPI read returned zero and both PLLs timed out. */
	gpio_set_value(LMK_RESET, 1);
	mdelay(10);
	gpio_set_value(LMK_RESET, 0);
	mdelay(10);
	printf("AWG INIT: LMK reset released\r\n");
	/* LMK pin-select mode: SEL1=0, SEL0=1 selects CLKIN1, wired to the
	 * board's 10 MHz TCXO. CLKIN0 is the external reference connector. */
	gpio_set_value(LMK_REF_SELECT0, 1);
	gpio_set_value(LMK_REF_SELECT1, 0);
	gpio_set_value(LMK_SYNC, 0);
	/**************************************************************************/
	/*****      configure system clock					                  *****/
	/**************************************************************************/
//	int32_t val;
//	val = iic_init(IIC_DEVICE_ID);
//	if (val == 0) {
//		printf("IIC Setup PASSED\r\n");
//		uint8_t iicdata[2];
//		for (int i = 0; i < sizeof(iicdata); i++) {
//			val = i2c_reg_read(0x50, i, &iicdata[i]);
//			mdelay(10);
//		}
//		auxdac = iicdata[0] | (iicdata[1] << 8);
//		printf("auxdac value read from eeprom %d\n", auxdac);
//		if (auxdac >= 2000 || auxdac < 1000)
//			auxdac = 1600;
//	}
	printf("AWG INIT: configuring LMK\r\n");
	INIT_STAGE(10);
	int32_t lmk_status = lmk04828_init(&lmk04828_spi, 200e6);
	if (lmk_status != 0) {
		printf("AWG INIT FAILED: LMK configuration status=%ld\r\n", (long)lmk_status);
		return XRFDC_FAILURE;
	}
	lmk04828_update_man_dac(&lmk04828_spi, auxdac);
	int32_t lock_pll1 = -1;
	int32_t lock_pll2 = -1;
	int cyc = 0;
	unsigned lock_polls = 0;
	INIT_STAGE(11);
	while (((lock_pll1 != ref_ext_en) || lock_pll2 != 1 || cyc < 100) && lock_polls < 3000) {
		int32_t pll1_status = lmk04828_spi_read(&lmk04828_spi, 0X182);
		int32_t pll2_status = lmk04828_spi_read(&lmk04828_spi, 0X183);
		if (pll1_status < 0 || pll2_status < 0) {
			printf("AWG INIT FAILED: LMK lock status SPI read error pll1=%ld pll2=%ld\r\n",
				(long)pll1_status, (long)pll2_status);
			return XRFDC_FAILURE;
		}
		lock_pll1 = (pll1_status >> 1) & 0x1;
		lock_pll2 = (pll2_status >> 1) & 0x1;
		lmk_lock_debug = ((uint32_t)(lock_pll1 & 1) << 0) |
			((uint32_t)(lock_pll2 & 1) << 1) | ((uint32_t)lock_polls << 8);
		lock_polls++;
//		printf("read from rf1_lmk04828 pll1_lock=0x%lx\n", lock_pll1);
//		printf("read from rf1_lmk04828 pll2_lock=0x%x\n", lock_pll2);
		if (lock_pll2 == 1 && (lock_pll1 == ref_ext_en)) {
			lock_pll2 = 1;
			lock_pll1 = ref_ext_en;
			cyc++;
		} else {
			lock_pll2 = 0;
			lock_pll1 = (~ref_ext_en) & 0x1;
			cyc = 0;
			mdelay(10);
		}
	}

	printf("LMK PLL status: pll1_lock=0x%x pll2_lock=0x%x consecutive=%d polls=%u\r\n",
		lock_pll1, lock_pll2, cyc, lock_polls);
	if (cyc < 100) {
		printf("AWG INIT FAILED: LMK PLL lock timeout\r\n");
		return XRFDC_FAILURE;
	}

//	if(lock_pll1 == 1 && lock_pll2 == 1)
//	{
//		printf("rf1_lmk04828 pll1 and pll2 locked \n");
//		printf("lmk04828 config successful \n");
//	}
//	else
//	{
//		printf("read from rf1_lmk04828 pll1_lock=0x%x\n", lock_pll1);
//		printf("read from rf1_lmk04828 pll2_lock=0x%x\n", lock_pll2);
//		printf("lmk04828 config fail \n");
//		return 0;
//	}


	gpio_set_value(LMK_SYNC, 0);
	mdelay(1);
	gpio_set_value(LMK_SYNC, 1);
	mdelay(1);
	gpio_set_value(LMK_SYNC, 0);
	lmk04828_update_sysref_pulse(&lmk04828_spi);
	gpio_set_value(LMK_SYNC, 0);
	lmk04828_set_sysref_shots(&lmk04828_spi, 0);
	mdelay(1);
	mdelay(500);
	Status = AXI_REG_READ(0XFF5E0000, 0X00000200U);
	printf("CRL_APB_BOOT_MODE_USER=%x\n", Status);
	/* LMK reset interrupts PL_CLK. Load PL only after all LMK clock writes
	 * finish, so its MMCM starts with a stable reference. Until the host
	 * acknowledges the matching PL, this code accesses PS peripherals only. */
	INIT_STAGE(15);
	awg_pl_program_ack = 0;
	Xil_DCacheFlushRange((INTPTR)&awg_pl_program_ack, 64U);
	awg_clock_ready = 0x434C4B31U; /* CLK1 */
	Xil_DCacheFlushRange((INTPTR)&awg_clock_ready, 64U);
	printf("AWG CLOCK READY: LMK configured; waiting for matching PL programming\r\n");
	unsigned pl_wait_ms = 0;
	for (;;) {
		Xil_DCacheInvalidateRange((INTPTR)&awg_pl_program_ack, 64U);
		if (awg_pl_program_ack == 0x504C4F4BU) break; /* PLOK */
		if (++pl_wait_ms >= 120000U) {
			printf("AWG INIT FAILED: PL programming acknowledgement timeout; use scripts/program.tcl\r\n");
			return XRFDC_FAILURE;
		}
		mdelay(1);
	}
	AXI_REG_WRITE(axi_lite_addr, 7 * 4, 0);
	AXI_REG_WRITE(axi_lite_addr, 1 * 4, 0);
	printf("AWG INIT: matching PL loaded after stable LMK clocks\r\n");
	printf("AWG INIT: initializing RF data converter\r\n");
	INIT_STAGE(20);
	Status = RFdcDcp_initial(&RFdcInstPtr, RFDC_DEVICE_ID);
	if (Status != XRFDC_SUCCESS) {
		printf("AWG INIT FAILED: RFDC driver initialization status=%d\r\n", Status);
		return XRFDC_FAILURE;
	}
	printf("AWG INIT: RFDC driver initialized\r\n");
	INIT_STAGE(21);
	for (int i = 0; i < 4; i++) {
		if (XRFdc_Reset(&RFdcInstPtr, XRFDC_DAC_TILE, i) != XRFDC_SUCCESS) return XRFDC_FAILURE;
		if (XRFdc_Reset(&RFdcInstPtr, XRFDC_ADC_TILE, i) != XRFDC_SUCCESS) return XRFDC_FAILURE;
	}
	printf("AWG INIT: RFDC tiles reset\r\n");
	Status = AXI_REG_READ(XPAR_XRFDC_0_BASEADDR, XRFDC_ADC_PATHS_ENABLED_OFFSET);
	printf("ADC_PATHS_ENABLED=%x\n", Status);
	Status = AXI_REG_READ(XPAR_XRFDC_0_BASEADDR, XRFDC_DAC_PATHS_ENABLED_OFFSET);
	printf("DAC_PATHS_ENABLED=%x\n", Status);
	SettingsPtr.Attenuation = 0;
	SettingsPtr.DisableRTS = 1;
	for (int i = 0; i < 4; i++)
		for (int j = 0; j < 2; j++) {
//			Status = XRFdc_SetDACVOP(&RFdcInstPtr, i, j * 2, txatt[i * 2 + j]);
//			printf("tile=%d,block=%d,XRFdc_SetDACVOP,Status=%d\n", i, j, Status);
			Status = XRFdc_SetDSA(&RFdcInstPtr, i, j, &SettingsPtr);
			Status = XRFdc_GetDSA(&RFdcInstPtr, i, j, &SettingsPtr);
			Status = XRFdc_SetDither(&RFdcInstPtr, i, j, 1);
			printf("tile=%d,block=%d,Attenuation=%f,Status=%d\n", i, j,
					SettingsPtr.Attenuation, Status);
		}
    mdelay(1);
	uint32_t val_out;
	val_out = AXI_REG_READ(XPAR_XRFDC_0_BASEADDR, 0);
	printf("ip revision=%x\n", val_out);
	val_out = AXI_REG_READ(XPAR_XRFDC_0_BASEADDR, 0x18084);
	printf("adc tile1 clock_dector=%x\n", val_out);
	val_out = AXI_REG_READ(XPAR_XRFDC_0_BASEADDR, 0x1c084);
	printf("adc tile2 clock_dector=%x\n", val_out);
	val_out = AXI_REG_READ(XPAR_XRFDC_0_BASEADDR, 0x04084);
	printf("dac tile0 clock_dector=%x\n", val_out);
	val_out = AXI_REG_READ(XPAR_XRFDC_0_BASEADDR, 0x0c084);
	printf("dac tile2 clock_dector=%x\n", val_out);
	FS = RFdcInstPtr.ADC_Tile[0].PLL_Settings.SampleRate * 1e9;
	INIT_STAGE(22);
	printf("DAC converter samplerate=%lluHz\n",
		(unsigned long long)(RFdcInstPtr.DAC_Tile[0].PLL_Settings.SampleRate * 1e9));
	printf("ADC converter samplerate=%ldHz\n", FS);
	/* Metadata is fixed; do not declare READY for another converter rate. */
	for (int tile=0; tile<4; ++tile) {
		double adc_rate=RFdcInstPtr.ADC_Tile[tile].PLL_Settings.SampleRate;
		double dac_rate=RFdcInstPtr.DAC_Tile[tile].PLL_Settings.SampleRate;
		if (adc_rate<(ADC_EXPECTED_RATE_GSPS-0.000001) ||
		    adc_rate>(ADC_EXPECTED_RATE_GSPS+0.000001) ||
		    dac_rate<(DAC_EXPECTED_RATE_GSPS-0.000001) ||
		    dac_rate>(DAC_EXPECTED_RATE_GSPS+0.000001)) {
			printf("AWG INIT FAILED: converter rate mismatch tile %d\n",tile);
			return XRFDC_FAILURE;
		}
	}
	printf("AWG INIT: RFDC configured rates ADC 5 GSPS / DAC 9 GSPS match (not a frequency measurement)\r\n");
	for (int type = XRFDC_ADC_TILE; type <= XRFDC_DAC_TILE; ++type) {
		int source_tile = (type == XRFDC_ADC_TILE) ? 1 : 2;
		uint32_t pll_locked = 0;
		XRFdc_PLL_Settings pll = {0};
		if (XRFdc_GetPLLConfig(&RFdcInstPtr, type, source_tile, &pll) != XRFDC_SUCCESS ||
		    XRFdc_GetPLLLockStatus(&RFdcInstPtr, type, source_tile, &pll_locked) != XRFDC_SUCCESS ||
		    pll_locked != XRFDC_PLL_LOCKED) {
			printf("AWG INIT FAILED: %s source tile %d PLL not locked\r\n",
			       type == XRFDC_ADC_TILE ? "ADC" : "DAC", source_tile);
			return XRFDC_FAILURE;
		}
		printf("AWG PLL: %s tile %d ref=%.6f MHz, sample=%.6f GSPS, refdiv=%u feedback=%u outdiv=%u lock=%u\r\n",
		       type == XRFDC_ADC_TILE ? "ADC" : "DAC", source_tile,
		       pll.RefClkFreq, pll.SampleRate, pll.RefClkDivider,
		       pll.FeedbackDivider, pll.OutputDivider, pll_locked);
		double expected_rate = (type == XRFDC_ADC_TILE) ? ADC_EXPECTED_RATE_GSPS : DAC_EXPECTED_RATE_GSPS;
		if (pll.RefClkFreq < 199.999999 || pll.RefClkFreq > 200.000001 ||
		    pll.RefClkDivider == 0U || pll.OutputDivider == 0U) {
			printf("AWG INIT FAILED: RFDC source PLL reference does not match LMK 200 MHz outputs\r\n");
			return XRFDC_FAILURE;
		}
		double derived_rate = 0.2 * pll.FeedbackDivider / pll.RefClkDivider / pll.OutputDivider;
		if (derived_rate < expected_rate - 0.000001 || derived_rate > expected_rate + 0.000001) {
			printf("AWG INIT FAILED: PLL divider readback gives %.6f GSPS with 200 MHz reference\r\n", derived_rate);
			return XRFDC_FAILURE;
		}
	}
	INIT_STAGE(23);
	/* Converter clocks and bypass datapaths are fixed in the generated bitstream. */
	AXI_REG_WRITE(axi_lite_addr, 4 * 4, DAC_FABRIC_CLOCK_HZ / 4U);
	printf("AWG INIT: RFDC datapath uses bitstream configuration (DAC x1, ADC x1, mixer bypass)\r\n");
	INIT_STAGE(40);
	INIT_STAGE(41);
//	Status = qmc_settings(&RFdcInstPtr, XRFDC_DAC_TILE);
	mdelay(100);
	printf("AWG INIT: starting MTS\r\n");
	INIT_STAGE(50);
	Status=-1;
	for (int mts_attempt=1; mts_attempt<=10 && Status != XRFDC_SUCCESS; ++mts_attempt) {
		Status = RFdcDcp_Example(&RFdcInstPtr, &lmk04828_spi);
		if (Status != XRFDC_SUCCESS) {
			printf("AWG INIT: MTS attempt %d/10 failed, status=0x%08x\r\n",
			       mts_attempt, (unsigned int)Status);
			mdelay(500);
		}
	}
	if (Status != XRFDC_SUCCESS) {
		printf("AWG INIT FAILED: MTS retries exhausted, status=%d\r\n", Status);
		return XRFDC_FAILURE;
	}
	printf("RFdcDcp initial Successful\n");
	printf("AWG INIT: RF initialization stages complete\r\n");
	INIT_STAGE(90);
	//set yunsdr axi lite
	val_out = AXI_REG_READ(axi_lite_addr, 0);
	printf("The SDR model is %d(4x4) rev V3!\n", val_out & 0xFFFF);
	val_out = AXI_REG_READ(axi_lite_addr, 98 * 4);
	printf("The FPGA firmware version=0x%8x\n", val_out);
	val_out = AXI_REG_READ(axi_lite_addr, 99 * 4);
	printf("The fw lasted build at %02x:%02x:%02x\n", val_out >> 16 & 0xff,
			val_out >> 8 & 0xff, val_out & 0xff);
	printf("The sw lasted build at %s %s\n", __TIME__, __DATE__);
	//set yunsdr axi lite
	AXI_REG_WRITE(axi_lite_addr, 2 * 4, 0);			//pps_disable
	AXI_REG_WRITE(axi_lite_addr, 5 * 4, 512);		//phase
	AXI_REG_WRITE(axi_lite_addr, 6 * 4, 0);			//rf_mode
	Status = xadc_initial(XPAR_PSU_AMS_DEVICE_ID);
	if (Status == 0) {
		printf("Xadc Setup PASSED\r\n");
	}
	printf("MRF4 initial successful!\n");
	AXI_REG_WRITE(axi_lite_addr, 7 * 4, 1); 	//config done
	INIT_STAGE(99);
	AXI_REG_WRITE(axi_lite_addr, 1 * 4, 1); 	//mtime_start

	gpio_set_value(LMK_SYNC, 1);
	float temp;
	xadc_read_temp(&temp);
	printf("fpga temperature=%lf\n",temp);

	XTime tEnd, tCur;
	int time_flag = 0;
	printf("AWG READY: DAC=9000000000 real samples/s, ADC=5000000000 raw samples/s, data clocks=%u/%uHz\n",
		DAC_FABRIC_CLOCK_HZ, ADC_FABRIC_CLOCK_HZ);
	printf("DAC remains at zero; load wave RAM and START using JTAG.\n");
	while (1) {
		if (!time_flag) {
			XTime_GetTime(&tCur);
			time_flag = 1;
		} else {
			XTime_GetTime(&tEnd);
			if ((tEnd - tCur) >= COUNTS_PER_SECOND * 1) {
				xadc_read_temp(&temp);
				printf("fpga temp=%2.1f", temp);
				printf("; AWG controlled over JTAG");
				printf("\n");
				time_flag = 0;
			}
		}
	}
	return XRFDC_SUCCESS;
}
