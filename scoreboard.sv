
// /////////////////////////////////////////////////////
// ////////////scoreboard///////////////////////////////
class sco extends uvm_scoreboard;
  `uvm_component_utils(sco)
  transaction data;
  uvm_analysis_imp #(transaction,sco) recv;
  transaction write_data_array[int];
  transaction read_data_array[int];
  
  function new(input string name="SCO",uvm_component parent=null);
    super.new(name,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    data=transaction::type_id::create("data");
    recv=new("analysis_imp",this);

    
  endfunction
  
  bit success=1;
  int i,j;
  int score=0;
  transaction temp;
  function void add_element(transaction data);
    temp=new data;
    if(data.read==0) begin
      write_data_array[temp.id]=temp;
    end
    else begin
      read_data_array[temp.id]=temp;
    end
    
  endfunction
  
  virtual function void write(transaction data);
    add_element(data);
  endfunction
  ///////////////////////////////////////////////////////
  function bit compare(transaction read,transaction write);
   
    
    if(write.len!=read.len) return 0;
    
    if(write.addr!=read.addr) return 0;
    
    foreach(write.data[i]) begin
      if(write.data[i] != read.data[i]) return 0;
    end
    
    return 1;
  endfunction
  /////////////////////////////////////////////////////////
  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    ////////////////////////////////////////////
    $display("write transactions");
    foreach (write_data_array[i]) begin
      write_data_array[i].display("SCO display");
    end
    $display("read transactiond");
    foreach (read_data_array[i]) begin
      read_data_array[i].display("SCO display");
    end
    ////////////////////////////////////////////
    foreach(read_data_array[i]) begin
      if(compare(read_data_array[i],write_data_array[i])) begin
        `uvm_info("SCO",          "###########",UVM_NONE);
        `uvm_info("SCO",$sformatf("# Test Passes ID:%0d #",i),UVM_NONE);
        `uvm_info("SCO",          "###########",UVM_NONE);
        score++;
      end
    end
    
    `uvm_info("SCO",          "###########",UVM_NONE);
    `uvm_info("SCO",$sformatf("# score=%0d #",score),UVM_NONE);
    `uvm_info("SCO",          "###########",UVM_NONE);
      
  endfunction

endclass