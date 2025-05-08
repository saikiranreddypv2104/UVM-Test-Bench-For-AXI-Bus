class slave_transaction extends uvm_object;
   `uvm_object_utils(slave_transaction)
   logic [3:0]  id;
   logic [3:0]  len;
   logic [2:0]  size;
   logic [31:0]	addr;
   logic [1:0]	burst;
   logic [31:0]	data[];
  logic [3:0] strb;
   function new(input string name="slave_transaction");
      super.new(name);
      data=new[0];      
   endfunction // new

   function void add_data(logic [31:0] data_transfer);
      data=new[data.size()+1](data);
      data[data.size()-1]=data_transfer;
   endfunction // add_data
  function void display(string tag);
    `uvm_info(tag,$sformatf("id:%0d len:%0d size:%0d addr:%0d burst:%0d data:%0p",id,len,size,addr,burst,data),UVM_NONE);
  endfunction
endclass // slave_transaction
