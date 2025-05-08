class slave_monitor  extends uvm_monitor;
   `uvm_component_utils(slave_monitor)
  virtual axi_if axi;
  function new(string name="slave_monitor",uvm_component parent=null );
      super.new(name,parent);
   endfunction // new
   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      uvm_config_db #(virtual axi_if)::get(null,"*","axi",axi);
   endfunction // build_phase
   
endclass // slave_agent
