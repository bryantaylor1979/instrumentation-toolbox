/*!
 * \file sample-dynamic.c
 *
 * \author FTDI
 * \date 20110512
 *
 * Copyright © 2011 Future Technology Devices International Limited
 * Company Confidential
 *
 * Project: libMPSSE
 * Module: SPI Sample Application - Interfacing 94LC56B SPI EEPROM
 *
 * Rivision History:
 * 0.1 - 20110512 - Initial version
 * 0.2 - 20110801 - Changed LatencyTimer to 255
 * 				  Attempt to open channel only if available
 *				  Added & modified macros
 */

#include<stdio.h>
#include<stdlib.h>

#ifdef _WIN32
#include<windows.h>
#endif

#ifdef __linux
#include<dlfcn.h>
#endif
#include "libMPSSE_spi.h"
#include "ftd2xx.h"

#ifdef _WIN32
	#define GET_FUN_POINTER	GetProcAddress
	#define CHECK_ERROR(exp) {if(exp==NULL){printf("%s:%d:%s():  NULL expression encountered \n",__FILE__, __LINE__, __FUNCTION__);exit(1);}else{;}};
#endif

#ifdef __linux
	#define GET_FUN_POINTER	dlsym
	#define CHECK_ERROR(exp) {if(dlerror() != NULL){printf("line %d: ERROR dlsym\n",__LINE__);}}
#endif
#define APP_CHECK_STATUS(exp) {if(exp!=FT_OK){printf("%s:%d:%s(): status(0x%x) != FT_OK\n",__FILE__, __LINE__, __FUNCTION__,exp);exit(1);}else{;}};
#define CHECK_NULL(exp){if(exp==NULL){printf("%s:%d:%s():  NULL expression encountered \n",__FILE__, __LINE__, __FUNCTION__);exit(1);}else{;}};

#define SPI_DEVICE_BUFFER_SIZE		584
#define SPI_WRITE_COMPLETION_RETRY		10
#define RETRY_COUNT_EEPROM		10
#define CHANNEL_B			    1
#define CHANNEL_A	            0
#define SPI_SLAVE_0				0
#define SPI_SLAVE_1				1
#define SPI_SLAVE_2				2
#define PWM			            24

/* Options-Bit0: If this bit is 0 then it means that the transfer size provided is in bytes */
#define	SPI_TRANSFER_OPTIONS_SIZE_IN_BYTES			0x00000000
/* Options-Bit0: If this bit is 1 then it means that the transfer size provided is in bytes */
#define	SPI_TRANSFER_OPTIONS_SIZE_IN_BITS			0x00000001
/* Options-Bit1: if BIT1 is 1 then CHIP_SELECT line will be enables at start of transfer */
#define	SPI_TRANSFER_OPTIONS_CHIPSELECT_ENABLE		0x00000002
/* Options-Bit2: if BIT2 is 1 then CHIP_SELECT line will be disabled at end of transfer */
#define SPI_TRANSFER_OPTIONS_CHIPSELECT_DISABLE		0x00000004

typedef FT_STATUS (*pfunc_SPI_GetNumChannels)(uint32 *numChannels);
pfunc_SPI_GetNumChannels p_SPI_GetNumChannels;
typedef FT_STATUS (*pfunc_SPI_GetChannelInfo)(uint32 index, FT_DEVICE_LIST_INFO_NODE *chanInfo);
pfunc_SPI_GetChannelInfo p_SPI_GetChannelInfo;
typedef FT_STATUS (*pfunc_SPI_OpenChannel)(uint32 index, FT_HANDLE *handle);
pfunc_SPI_OpenChannel p_SPI_OpenChannel;
typedef FT_STATUS (*pfunc_SPI_InitChannel)(FT_HANDLE handle, ChannelConfig *config);
pfunc_SPI_InitChannel p_SPI_InitChannel;
typedef FT_STATUS (*pfunc_SPI_CloseChannel)(FT_HANDLE handle);
pfunc_SPI_CloseChannel p_SPI_CloseChannel;
typedef FT_STATUS (*pfunc_SPI_Read)(FT_HANDLE handle, uint8 *buffer, uint32 sizeToTransfer, uint32 *sizeTransfered, uint32 options);
pfunc_SPI_Read p_SPI_Read;
typedef FT_STATUS (*pfunc_SPI_Write)(FT_HANDLE handle, uint8 *buffer, uint32 sizeToTransfer, uint32 *sizeTransfered, uint32 options);
pfunc_SPI_Write p_SPI_Write;
typedef FT_STATUS (*pfunc_SPI_IsBusy)(FT_HANDLE handle, bool *state);
pfunc_SPI_IsBusy p_SPI_IsBusy;


uint32 channels;

ChannelConfig channelConf;
uint8 buffer[SPI_DEVICE_BUFFER_SIZE];
FT_HANDLE ftHandle;
FT_HANDLE ftHandle_A;
FT_HANDLE ftHandle_B;
int VAL_3[3];
int VAL_2[2];

FT_STATUS write_spi_cmd(FT_HANDLE handle, uint16 data)
{
	uint32 sizeToTransfer = 0;
	uint32 sizeTransfered=0;
	bool writeComplete=0;
	uint32 retry=0;
	bool state;
	FT_STATUS status;

	/* Write  bits data + CS_Low */
	sizeToTransfer=8;
	sizeTransfered=0;
	buffer[0] = (data);
	ftHandle = (handle);
	
	status = p_SPI_Write(ftHandle, buffer, sizeToTransfer, &sizeTransfered, 
	SPI_TRANSFER_OPTIONS_SIZE_IN_BITS|
	SPI_TRANSFER_OPTIONS_CHIPSELECT_DISABLE);
	APP_CHECK_STATUS(status);
	return status;
}

void openChannels()	
{
		FT_STATUS status;
		status = p_SPI_OpenChannel(CHANNEL_A,&ftHandle_A);
		APP_CHECK_STATUS(status);
		printf("Open Channel A handle=%x\n",ftHandle_A);
		status = p_SPI_InitChannel(ftHandle_A,&channelConf);
			
		
		status = p_SPI_OpenChannel(CHANNEL_B,&ftHandle_B);
		APP_CHECK_STATUS(status);
		printf("Open Channel B handle=%x\n",ftHandle_B);
		status = p_SPI_InitChannel(ftHandle_B,&channelConf);
}

void writeTerminator_CorrectionValue()
{
	write_spi_cmd(ftHandle_B, 0x20);
	write_spi_cmd(ftHandle_A, 0x80);
}

void writeTerminator_Enables()
{
	write_spi_cmd(ftHandle_B, 0x30);
	write_spi_cmd(ftHandle_A, 0x80);
}

void writeTerminator_Currents()
{
	write_spi_cmd(ftHandle_B, 0x10);
	write_spi_cmd(ftHandle_A, 0x80);
}

int * Two_12_TO_Three_8(int VAL_2[2])
{
	    static int VAL_3[3];
		int CarryUp;

		// VAL2 LSB Sep
		CarryUp = VAL_2[0] >> 8; // (F)FF -> 15
		VAL_3[0] = VAL_2[0] - CarryUp*256; // FFF - 15*256 = 255

		// VAL2 MSB Sep
		VAL_3[2] = VAL_2[1] >> 4; // (FF)F = 255
		VAL_3[1] = (VAL_2[1] - VAL_3[2]*16)*16  + CarryUp;

		return VAL_3;

}		

void writePair(int VAL_2[2])
{
	//printf("VAL_2[0] = %d\n",  VAL_2[0]);
	//printf("VAL_2[1] = %d\n",  VAL_2[1]);
	int *VAL;
	VAL = Two_12_TO_Three_8(VAL_2);
	write_spi_cmd(ftHandle_B, VAL[2]);
	write_spi_cmd(ftHandle_B, VAL[1]);
	write_spi_cmd(ftHandle_B, VAL[0]); 
//	printf("VAL_3[0] = %d\n",       VAL[0]);
	//printf("VAL_3[1] = %d\n",		VAL[1]);
	//printf("VAL_3[2] = %d\n",		VAL[2]);
}

void writeValues(int Currents[48])
{
	    int i;
	    for(i=0;i<PWM;i++)
		{
//			printf("indicies: %d, %d\n",i*2,i*2+1);
			VAL_2[0] = Currents[i*2];
			VAL_2[1] = Currents[i*2+1];
//			printf("currents: %d, %d\n",VAL_2[0],VAL_2[1]);
			writePair(VAL_2);
		}	
}


int main()
{
#ifdef _WIN32
#ifdef _MSC_VER
	HMODULE h_libMPSSE;
#else
	HANDLE h_libMPSSE;
#endif
#endif
#ifdef __linux
	void *h_libMPSSE;
#endif
	FT_STATUS status;
	FT_DEVICE_LIST_INFO_NODE devList;
	uint8 address=0;
	uint16 data;
	int i,j;
	uint32 sizeToTransfer, sizeTransfered;
	channelConf.ClockRate = 5000000;
	channelConf.LatencyTimer= 255;
	channelConf.configOptions = SPI_CONFIG_OPTION_MODE0;
	channelConf.Pin = 0x00000000;/* FinalVal-FinalDir-InitVal-InitDir (for dir: 0=in, 1=out) */ 

	/* load library */
#ifdef _WIN32
#ifdef _MSC_VER
	h_libMPSSE = LoadLibrary(L"libMPSSE.dll");
#else
	h_libMPSSE = LoadLibrary("libMPSSE.dll");
#endif

	CHECK_NULL(h_libMPSSE);
#endif

#if __linux
	h_libMPSSE = dlopen("libMPSSE.so",RTLD_LAZY);
	if(!h_libMPSSE)
	{
		printf("Failed loading libMPSSE.so\n");
	}
#endif
	/* init function pointers */
	p_SPI_GetNumChannels = (pfunc_SPI_GetNumChannels)GET_FUN_POINTER(h_libMPSSE, "SPI_GetNumChannels");
	CHECK_NULL (p_SPI_GetNumChannels);
	p_SPI_GetChannelInfo = (pfunc_SPI_GetChannelInfo)GET_FUN_POINTER(h_libMPSSE, "SPI_GetChannelInfo");
	CHECK_NULL(p_SPI_GetChannelInfo);
	p_SPI_OpenChannel = (pfunc_SPI_OpenChannel)GET_FUN_POINTER(h_libMPSSE, "SPI_OpenChannel");
	CHECK_NULL(p_SPI_OpenChannel);	
	p_SPI_InitChannel = (pfunc_SPI_InitChannel)GET_FUN_POINTER(h_libMPSSE, "SPI_InitChannel");
	CHECK_NULL(p_SPI_InitChannel);
	p_SPI_Read = (pfunc_SPI_Read)GET_FUN_POINTER(h_libMPSSE, "SPI_Read");
	CHECK_NULL(p_SPI_Read);
	p_SPI_Write = (pfunc_SPI_Write)GET_FUN_POINTER(h_libMPSSE, "SPI_Write");
	CHECK_NULL(p_SPI_Write);
	p_SPI_CloseChannel = (pfunc_SPI_CloseChannel)GET_FUN_POINTER(h_libMPSSE, "SPI_CloseChannel");
	CHECK_NULL(p_SPI_CloseChannel);
	p_SPI_IsBusy = (pfunc_SPI_IsBusy)GET_FUN_POINTER(h_libMPSSE, "SPI_IsBusy");
	CHECK_NULL(p_SPI_IsBusy);
	
	status = p_SPI_GetNumChannels(&channels);
	APP_CHECK_STATUS(status);
	printf("Number of available SPI channels = %d\n",channels);
	if(channels>0)
	{
		for(i=0;i<channels;i++)
		{
			status = p_SPI_GetChannelInfo(i,&devList);
			APP_CHECK_STATUS(status);

			printf("Information on channel number %d:\n",i);
			/*print the dev info*/
			printf("		Flags=0x%x\n",devList.Flags); 
			printf("		Type=0x%x\n",devList.Type); 
			printf("		ID=0x%x\n",devList.ID); 
			printf("		LocId=0x%x\n",devList.LocId); 
			printf("		SerialNumber=%s\n",devList.SerialNumber); 
			printf("		Description=%s\n",devList.Description); 
			printf("		ftHandle=0x%x\n",devList.ftHandle);/*always 0 unless open*/
		}
		

		openChannels();

	    write_spi_cmd(ftHandle_A, 0xFF);
		
		// CORRECTION VALUE
		static int Correction[48];
		Correction[33] = 0; //WHITE
		Correction[32] = 0; //RED
		Correction[35] = 0; //GREEN
		writeValues(Correction);
		writeTerminator_CorrectionValue();

		// ENABLE OUTPUTS
		static int Enables[48];
		Enables[33] = 0; //WHITE
		Enables[32] = 0; //RED
		Enables[35] = 0; //GREEN
		writeValues(Enables);
		writeTerminator_Enables();


		// CURRENT
		static int Currents[48];
		Currents[33] = 20; //WHITE
		Currents[32] = 20; //RED
		Currents[35] = 20; //GREEN
		writeValues(Currents);
		writeTerminator_Currents();
		
		status = p_SPI_CloseChannel(ftHandle_A);
		status = p_SPI_CloseChannel(ftHandle_B);
	} 
	return 0;	
}