/*
 * xrfdc_dcp.c
 *
 *  Created on: 2020年5月29日
 *      Author: lichen
 */
#include "xrfdc.h"
#include "rfsoc_cfg.h"
#include "platform_drivers.h"
#include "spi_ctrl.h"
#include "io_control.h"
extern uint64_t FS;
extern uint32_t axi_lite_addr;
int RFdcDcp_initial(XRFdc *RFdcInstPtr,u16 RFdcDeviceId)
{
	s32 Status;
	XRFdc_Config *ConfigPtr;
//	XRFdc RFdcInst;      /* RFdc driver instance */
//	RFdcInstPtr = &RFdcInst;
#ifndef __BAREMETAL__
	struct metal_device *device;
	struct metal_io_region *io;
	int ret = 0;
#endif


	ConfigPtr = XRFdc_LookupConfig(RFdcDeviceId);
	if (ConfigPtr == NULL) {
		return XRFDC_FAILURE;
	}

	Status = XRFdc_CfgInitialize(RFdcInstPtr, ConfigPtr);
	if (Status != XRFDC_SUCCESS) {
		printf("RFdc Init Failure\n\r");
		return XRFDC_FAILURE;
	}

#ifndef __BAREMETAL__
	ret = metal_device_open(BUS_NAME, RFDC_DEV_NAME, &device);
	if (ret) {
		printf("ERROR: Failed to open device %s.\n", DeviceName);
		return XRFDC_FAILURE;
	}

	/* Map RFDC device IO region */
	io = metal_device_io_region(device, 0);
	if (!io) {
		printf("ERROR: Failed to map RFDC regio for %s.\n",
				device->name);
		return XRFDC_FAILURE;
	}
	RFdcInstPtr->device = device;
	RFdcInstPtr->io = io;
#endif
	return 0;
}
int RFdcDcp_Example(XRFdc *RFdcInstPtr, spi_device * spi) {
	u32 factor;
	s32 status_adc, status_dac, i;
	u32 mts_enable = 0;
	u32 dac_ref_tile = 0, adc_ref_tile = 0;
	XRFdc_IPStatus ip_status = { 0 };
	uint32_t div = AXI_REG_READ(axi_lite_addr, 4 * 4) / (FS / 160);
	printf("=== RFdc Initialized - Running Multi-tile Sync div=%d===\n",div);

	/* ADC MTS Settings */
	XRFdc_MultiConverter_Sync_Config ADC_Sync_Config;

	/* DAC MTS Settings */
	XRFdc_MultiConverter_Sync_Config DAC_Sync_Config;

	/* Synchronize only tiles that contain an enabled block 0. */
	XRFdc_GetIPStatus(RFdcInstPtr, &ip_status);
	DAC_Sync_Config.Tiles = 0;
	ADC_Sync_Config.Tiles = 0;
	for (i = 0; i < 4; ++i) {
		if (ip_status.DACTileStatus[i].IsEnabled &&
		    (ip_status.DACTileStatus[i].BlockStatusMask & 1U)) {
			DAC_Sync_Config.Tiles |= 1U << i;
			XRFdc_GetMTSEnable(RFdcInstPtr, XRFDC_DAC_TILE, i, &mts_enable);
			printf("AWG MTS: DAC tile %d state=%u blocks=0x%x mts=%u\r\n",
			       i, ip_status.DACTileStatus[i].TileState,
			       ip_status.DACTileStatus[i].BlockStatusMask, mts_enable);
		}
		if (ip_status.ADCTileStatus[i].IsEnabled &&
		    (ip_status.ADCTileStatus[i].BlockStatusMask & 1U)) {
			ADC_Sync_Config.Tiles |= 1U << i;
			XRFdc_GetMTSEnable(RFdcInstPtr, XRFDC_ADC_TILE, i, &mts_enable);
			printf("AWG MTS: ADC tile %d state=%u blocks=0x%x mts=%u\r\n",
			       i, ip_status.ADCTileStatus[i].TileState,
			       ip_status.ADCTileStatus[i].BlockStatusMask, mts_enable);
		}
	}
	printf("AWG MTS: selected DAC tiles=0x%x ADC tiles=0x%x\r\n",
	       DAC_Sync_Config.Tiles, ADC_Sync_Config.Tiles);
	if (DAC_Sync_Config.Tiles == 0U || ADC_Sync_Config.Tiles == 0U) {
		printf("AWG MTS FAILED: no enabled block-0 tile found\r\n");
		return XRFDC_FAILURE;
	}
	while ((DAC_Sync_Config.Tiles & (1U << dac_ref_tile)) == 0U) ++dac_ref_tile;
	while ((ADC_Sync_Config.Tiles & (1U << adc_ref_tile)) == 0U) ++adc_ref_tile;
	printf("AWG MTS: reference DAC tile=%u ADC tile=%u\r\n",
	       dac_ref_tile, adc_ref_tile);

	/* Run MTS for the ADC & DAC */
	status_dac = lmk04828_set_sysref_sync_cont(spi);
	if (status_dac != XST_SUCCESS) {
		printf("AWG MTS FAILED: cannot enable continuous SYSREF, status=%ld\r\n",
		       (long)status_dac);
		return (int)status_dac;
	}
	mdelay(1);
	gpio_set_value(LMK_SYNC, 1);
	mdelay(10);
	int sync = -1;
	while (sync != 0) {
		sync = 0;
		printf("\n\r=== Run DAC Sync ===\n\r");
		XRFdc_MultiConverter_Init(&DAC_Sync_Config, NULL, NULL, dac_ref_tile);
		/* Keep the mask derived from the enabled RFDC tiles above. */
//		if (FS == 4915.2e6) // || FS == 3600e6
//			DAC_Sync_Config.Target_Latency = 5760 / div; //5440;
//		else
		DAC_Sync_Config.Target_Latency = -1;
		status_dac = XRFdc_MultiConverter_Sync(RFdcInstPtr, XRFDC_DAC_TILE,
				&DAC_Sync_Config);
		if (status_dac == XRFDC_MTS_OK) {
			printf("INFO : DAC Multi-Tile-Sync completed successfully\n\r");
		} else {
			printf("INFO : DAC Multi-Tile-Sync failed, raw status=0x%08x\r\n",
			       (unsigned int)status_dac);
			sync = -1;
			gpio_set_value(LMK_SYNC, 0);
//			mdelay(10);
//			gpio_set_value(LMK_SYNC, 1);
//			mdelay(10);
			return (int)status_dac;
		}
		for (i = 0; i < 4; i++) {
			if ((1 << i) & DAC_Sync_Config.Tiles) {
				/* Offset is the per-tile FIFO correction applied by MTS.
				 * Different offsets are valid; the driver checks alignment
				 * and correction limits before returning XRFDC_MTS_OK. */
					printf("DAC%d: Latency(T1) =%3d, Adjusted Delay"
							"Offset=%3d\n\r", i, DAC_Sync_Config.Latency[i],
							DAC_Sync_Config.Offset[i]);
			}
		}
	}
	sync = -1;
	while (sync != 0) {
		sync = 0;
		printf("\n\r=== Run ADC Sync ===\n\r");
		/* Initialize ADC MTS Settings */
		XRFdc_MultiConverter_Init(&ADC_Sync_Config, NULL, NULL, adc_ref_tile);
		/* Keep the mask derived from the enabled RFDC tiles above. */
//		if (FS == 4915.2e6) // || FS == 3600e6
//			ADC_Sync_Config.Target_Latency = 1520 / div; //1520;
//		else
		ADC_Sync_Config.Target_Latency = -1;
		status_adc = XRFdc_MultiConverter_Sync(RFdcInstPtr, XRFDC_ADC_TILE,
				&ADC_Sync_Config);
		if (status_adc == XRFDC_MTS_OK) {
			printf("INFO : ADC Multi-Tile-Sync completed successfully\n\r");
		} else {
			printf("INFO : ADC Multi-Tile-Sync failed, raw status=0x%08x\r\n",
			       (unsigned int)status_adc);
			sync = -1;
			gpio_set_value(LMK_SYNC, 0);
//			mdelay(10);
//			gpio_set_value(LMK_SYNC, 1);
//			mdelay(10);
			return (int)status_adc;
		}
		for (i = 0; i < 4; i++) {
			if ((1 << i) & ADC_Sync_Config.Tiles) {
				/* Valid per-tile corrections need not be limited to one. */
					printf("ADC%d: Latency(T1) =%3d, Adjusted Delay"
							"Offset=%3d\n\r", i, ADC_Sync_Config.Latency[i],
							ADC_Sync_Config.Offset[i]);
			}
		}
	}
	gpio_set_value(LMK_SYNC, 0);
	status_adc = lmk04828_set_sysref_sync_shots(spi);
	if (status_adc != XST_SUCCESS) {
		printf("AWG MTS FAILED: cannot select pulsed SYSREF, status=%ld\r\n",
		       (long)status_adc);
		return (int)status_adc;
	}
	mdelay(10);
	status_adc = XRFdc_MTS_Sysref_Config(RFdcInstPtr, &DAC_Sync_Config, &ADC_Sync_Config, 1);
	if (status_adc != XRFDC_MTS_OK) {
		printf("AWG MTS FAILED: final SYSREF capture configuration, status=0x%08x\r\n",
		       (unsigned int)status_adc);
		return (int)status_adc;
	}
	/* Preserve the mixer bypass and no-interpolation settings from the bitstream. */
	gpio_set_value(LMK_SYNC, 1);
	gpio_set_value(LMK_SYNC, 0);
	/****************************************************************************/
	//RReport Overall Latency in T1 (Sample Clocks) and
	// Offsets (in terms of PL words) added to each FIFO
	/****************************************************************************/
	printf("\n\n\r=== Multi-Tile Sync Report ===\n\r");
	for (i = 0; i < 4; i++) {
		if ((1 << i) & DAC_Sync_Config.Tiles) {
			XRFdc_GetInterpolationFactor(RFdcInstPtr, i, 0, &factor);
			printf("DAC%d: Latency(T1) =%3d, Adjusted Delay"
					"Offset(T%d) =%3d\n\r", i, DAC_Sync_Config.Latency[i],
					factor, DAC_Sync_Config.Offset[i]);
		}
	}
	for (i = 0; i < 4; i++) {
		if ((1 << i) & ADC_Sync_Config.Tiles) {
			XRFdc_GetDecimationFactor(RFdcInstPtr, i, 0, &factor);
			printf("ADC%d: Latency(T1) =%3d, Adjusted Delay"
					"Offset(T%d) =%3d\n\r", i, ADC_Sync_Config.Latency[i],
					factor, ADC_Sync_Config.Offset[i]);
		}
	}

	return 0;
}

