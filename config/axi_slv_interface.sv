`timescale 1ps/1ps

interface PCIe_if_a(input bit clk);
	logic[500:0] TX_TL_A;
	 //logic[320:0] TX_TL_A; 
	logic[500:0] TX_DLL_A; 
	//logic[367:0] TX_DLL_A; 
	logic linkup;
	logic DL_DOWN;
	logic DL_UP;
	logic [47:0]DLLP; 
	logic[47:0] DLLP_5;
	logic[47:0] DLLP_54;
	//logic[511:0] TX_PL_A; 
	logic[500:0] RX_TL_A; 
	//logic[320:0] RX_TL_A; 
	logic [500:0] RX_DLL_A; 
	//logic [367:0] RX_DLL_A; 
	//logic[511:0] RX_PL_A;
//--------------------------------------------
clocking TL_drv_cb_a @(posedge clk);
	default input #1 output #0;
	output TX_TL_A;
	input linkup;
	//input RX_TL;
endclocking
//------------------------------------------------------
clocking TL_mon_cb_a @(posedge clk);
	default input #1 output #0;
	input TX_TL_A;
	input linkup;
endclocking
//---------------------------------------------------------
clocking dll_drv_cb_a @(posedge clk);
       	default input #1 output #1ns; //transmitting operation
	output TX_DLL_A;
	output RX_TL_A;
	output DLLP;
	input linkup;
endclocking
//---------------------------------------
clocking dll_mon_cb_a @(posedge clk);
	default input #1 output #0;
	//transmitting operation
	input TX_TL_A;
	input linkup;
	// input TX_DLL_A;
endclocking
//-------------------------------------------------
clocking pl_drv_cb_a @(posedge clk);
	//default input #1 output #0;
	//transmitting operation
	output RX_DLL_A;
	output linkup;
	output DLLP_5;
endclocking
//-----------------------------------------
clocking pl_mon_cb_a @(posedge clk);
	default input #1 output #0;
	//transmitting operation
	input TX_DLL_A;
	input linkup;
endclocking

endinterface
