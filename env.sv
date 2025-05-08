/////////////////////////////////////////////////////
/////////////environment/////////////////////////////
class env extends uvm_env;
  `uvm_component_utils(env)
  agent a;
  slave_agent slave_agt;
  sco s;
  function new(input string path="env",uvm_component parent=null);
    super.new(path,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    a=agent::type_id::create("AGENT",this);
    s=sco::type_id::create("SCO",this);
    slave_agt=slave_agent::type_id::create("slave_agt",this);
  endfunction
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    a.m.send.connect(s.recv);
  endfunction
  
endclass