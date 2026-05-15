import uvm_pkg::*;
import pcie_pkg::*;
`include "uvm_macros.svh"
//----------------------------------------------
class DLL_sequencer_A extends uvm_sequencer# (PCIe_seq_item);
	`uvm_component_utils (DLL_sequencer_A)

extern function new(string name = "DLL_sequencer_A", uvm_component parent);
 endclass
 
//constructor
function DLL_sequencer_A::new(string name="DLL_sequencer_A", uvm_component parent);
       	super.new(name, parent);
endfunction

