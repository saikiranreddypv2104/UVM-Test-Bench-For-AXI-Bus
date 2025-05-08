class slave_agent  extends uvm_agent;
   `uvm_component_utils(slave_agent)
   slave_monitor sm;
   slave_driver  sd;

   function new(string name="salve_agent",uvm_component parent=null );
      super.new(name,parent);
   endfunction // new
   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sm=slave_monitor::type_id::create("sm",this);
       sd=slave_driver::type_id::create("sd",this);
   endfunction // build_phase

   virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
   endfunction // connect_phase
   
endclass // slave_agent
