import uvm_pkg::*;
import pcie_pkg::*;
`include "uvm_macros.svh"
//--------------------------------------------------
class DLL_monitor_A extends uvm_monitor;
	`uvm_component_utils(DLL_monitor_A) 
	virtual PCIe_if_a intf_ha;
	PCIe_seq_item data;
	logic [2:0] format6;
	logic [4:0] T7;
	uvm_analysis_port #(PCIe_seq_item) DLL_mon_a_port; 
       //-----------------------------------------------	
	uvm_event tl_a;
	uvm_event dlp_a1;
	uvm_event dlp_a2; 
	uvm_event cpl_a2;
	uvm_event cpl_a3;
	uvm_event fmt_collect;
	uvm_event dllp_4;
	uvm_event completion1;
	uvm_event completion2;
//-------constructor new----------------------------
function new (string name="DLL_monitor_A",uvm_component parent);
	super.new(name,parent);
	DLL_mon_a_port = new ("DLL_mon_a_port", this);
endfunction
//----------build phase----------------------
function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	if(!uvm_config_db#(virtual PCIe_if_a)::get(this, "", "intf_ha", intf_ha))
		`uvm_fatal ("DLL_MONITOR A","cannot get() the interface, have you set it?")
endfunction
//--------------------run phase------------------
task run_phase (uvm_phase phase);
begin
	data = PCIe_seq_item::type_id::create("data"); 
	dlp_a1 =uvm_event_pool::get_global("ev13"); 
	dlp_a2= uvm_event_pool::get_global ("ev14"); 
	tl_a= uvm_event_pool::get_global("ev1"); 
	cpl_a2 = uvm_event_pool::get_global("cpl_a2"); 
	cpl_a3 = uvm_event_pool::get_global("compl_a3"); 
	fmt_collect =uvm_event_pool::get_global("collecting fmt");
	dllp_4 =uvm_event_pool::get_global("dllp_4"); 	
	completion1 = uvm_event_pool::get_global("cpl1");
	completion2 = uvm_event_pool::get_global("cpl2");

	forever 
	begin
		`uvm_info("MONITOR_A", "entering monitor a", UVM_LOW)
		collect_Hdr_Data(data);
		fmt_collect.wait_trigger;
		data.tlp_tl=intf_ha.TX_TL_A;
		`uvm_info(get_type_name(),$sformatf("TX_TL_A data is %0h", intf_ha.TX_TL_A), UVM_LOW)
		`uvm_info(get_type_name(), $sformatf("monitor data is %0h", data.tlp_tl), UVM_NONE)
		@(intf_ha.dll_mon_cb_a);
		DLL_mon_a_port.write(data);
		tl_a.trigger();
		dllp_dl(data);
	end
end
endtask
//------------------------------------------------------------------------
task dllp_dl(PCIe_seq_item data);
begin
	//dlp_a1.wait_trigger;
	`uvm_info(get_type_name(),"before dllp_4 wait trigger", UVM_LOW)
	dllp_4.wait_trigger;
	`uvm_info(get_type_name()," entering dllp_a", UVM_LOW)
	begin
		@(intf_ha.dll_mon_cb_a);
		data.DLLP_6=intf_ha.DLLP_5;
		`uvm_info(get_type_name(), $sformatf("DLLP_6 is %0h", data.DLLP_6), UVM_LOW)
		data.DLLP_type=data.DLLP_6[7:0];
		`uvm_info(get_type_name(), $sformatf("DLLP_type is %0h", data.DLLP_type), UVM_LOW)

		DLL_mon_a_port.write(data);
	end
	//dlp_a1.reset();
	dllp_4.reset();
	dlp_a2.trigger();
	`uvm_info(get_type_name(), $sformatf("after dlp_a2 trigger"), UVM_LOW)
	//------------------------------------------------------------------------
	`ifdef 3dw_tlp4
	begin
		format6 =data.tlp_tl[95:93];
		`uvm_info(get_type_name(), $sformatf("format6 is %0b tlp_tl format is %0b", format6,data.tlp_tl[95:93]), UVM_LOW)
		T7= data.tlp_tl[92:88]; 
		`uvm_info(get_type_name(), $sformatf("T7 is %0b tlp_tl format is %0b", T7, data.tlp_tl[92:88]), UVM_LOW)
	collecting_cmpl(data);
	end
	//------------------------------------------------------------------------
	`elsif 4dw_tlp4
	begin
		format6 = data.tlp_tl[127:125];
		`uvm_info(get_type_name(), $sformatf("format6 is %0b tlp_tl format is %0b", format6, data.tlp_tl[127:125]), UVM_LOW)
		T7 = data.tlp_tl[124:120];
		`uvm_info(get_type_name(), $sformatf("T7 is %0b tlp_tl format is %0b", T7, data.tlp_tl[124:120]), UVM_LOW)
	collecting_cmpl(data);
	end

	`endif
	//------------------------------------------------------------------------

end

endtask
//------------------------------------------------------------------------
task collecting_cmpl(PCIe_seq_item data);
begin
	//------------------------------------------------------------------------
	`ifdef rd5_cmpl
	begin
		`uvm_info("MONITOR_B", "entering collect cmpl", UVM_LOW)
		`uvm_info(get_type_name(), $sformatf("fmt6 in mon a is %0b", format6), UVM_LOW)
		if(format6 ==3'b000 ||format6==3'b001)
		if (T7 ==5'b00000 || T7 ==5'b00001 || T7==5'b00010 || T7==5'b00100)
		begin
			`uvm_info("MONITOR_A", "entering if condition in collect cmpl", UVM_LOW) 
			cpl_a2.wait_trigger;
			data.cpl_data2 = intf_ha.RX_DLL_A;
			`uvm_info(get_type_name(), $sformatf("in dll_mon a is %0h", intf_ha.RX_DLL_A), UVM_LOW) 
			`uvm_info(get_type_name(), $sformatf("DLL monitor cpl_data is %0h", data.cpl_data2), UVM_LOW)
			@(intf_ha.dll_mon_cb_a);
			//@(intf_ha.dll_mon_cb_a);
		end
			`uvm_info(get_type_name(), $sformatf("before cpl_a3 trigger"), UVM_LOW)
		cpl_a3.trigger(data);
			`uvm_info(get_type_name(), $sformatf("after cpl_a3 trigger"), UVM_LOW)
	end
	//--------------------------------
	`elsif wr5_cmpl
	begin
		`uvm_info("MONITOR_B", "entering collect cmpl", UVM_LOW)
		if (T7==5'b00010 | T7==5'b00100)
		begin
			`uvm_info("MONITOR_A", "entering if condition in collect cmpl", UVM_LOW)
			cpl_a2.wait_trigger;
			data.cpl_data2 = intf_ha.RX_DLL_A;
			`uvm_info(get_type_name(), $sformatf("in dll_mon a is %0h", intf_ha.RX_DLL_A), UVM_LOW)
			`uvm_info(get_type_name(), $sformatf("DLL monitor cpl_data is %0b",data.cpl_data2), UVM_LOW)
			@(intf_ha.dll_mon_cb_a);
		end
		cpl_a3.trigger(data);
	end
	`endif
	//--------------------------------
end
endtask
//-----------------------------------------------
task collect_Hdr_Data(PCIe_seq_item req);
begin
	`uvm_info(get_type_name(), $sformatf("before completion1 wait trigger"), UVM_LOW)
	completion1.wait_trigger;
	`uvm_info(get_type_name(), $sformatf("after completion1 wait trigger"), UVM_LOW)
	
	@(intf_ha.dll_mon_cb_a);
	req.Hdr_Data=intf_ha.TX_TL_A;
	@(intf_ha.dll_mon_cb_a);

	`uvm_info(get_type_name(), $sformatf("header and data from tl to dll is %0h,Hdr_Data is %0h", intf_ha.TX_TL_A,req.Hdr_Data), UVM_LOW)
	
	`uvm_info(get_type_name(), $sformatf("before completion2 trigger"), UVM_LOW)
	completion2.trigger(req);
	`uvm_info(get_type_name(), $sformatf("after completion2 trigger"), UVM_LOW)
end
endtask
//-----------------------------------------
endclass
