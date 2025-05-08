
/////////////////////////////////////////////
//////////////transaction class/////////////
class transaction extends uvm_sequence_item;
  `uvm_object_utils(transaction)
  	rand bit unsigned [31:0] addr;
  	rand bit [31:0] data [];
  	rand bit [3:0] len;
  	randc bit [3:0] id;
  	rand bit [1:0] burst;
 	bit read=0;
  constraint burst_type{
  	burst==1;	
  }
  constraint addr_max_value {
    addr inside {[0:1000-len*8]};
    len>2;
  };
  constraint data_array_size{
    data.size() == len+1;
  
  }
  
  function new(input string name="transaction");
    super.new(name);
  endfunction
  function void add_data(logic [31:0] data_transfer);
      data=new[data.size()+1](data);
      data[data.size()-1]=data_transfer;
   endfunction // add_data
  
  function void display(input string tag);
    `uvm_info(tag,$sformatf("ADDR=%0d ID=%0d LEN=%0d data=%p burst_type=%0d read=%0d",addr,id,len,data,burst,read),UVM_NONE);
  endfunction
endclass
////////////////////////////////////////////