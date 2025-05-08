/////////////////////////////////////////////////////
////////////////monitor//////////////////////////////
class monitor extends uvm_monitor;
  `uvm_component_utils(monitor)
  transaction write_data,read_data;
  transaction write_data_array[int],read_data_array[int];
  integer j;
  integer i;
  virtual axi_if axi;
  uvm_analysis_port #(transaction) send;
  function new(input string path="MON",uvm_component parent=null);
    super.new(path,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    send=new("analysis_port",this);
    write_data = transaction::type_id::create("write_data");
    read_data = transaction::type_id::create("read_data");
    uvm_config_db #(virtual axi_if)::get(null,"*","axi",axi);
  endfunction
  
  task record_address_write();
    forever begin
      @(posedge axi.awvalid);
      write_data = transaction::type_id::create("write_data");
      write_data.len=axi.awlen;
      write_data.addr=axi.awaddr;
      write_data.burst=axi.awburst;
      write_data.id=axi.awid;
      write_data.data=new[0];
      write_data.read=0;
      write_data_array[axi.awid]=write_data;
    end
  endtask
  task record_data_write();
    forever begin
      @(posedge axi.wvalid);
      write_data_array[axi.wid].add_data(axi.wdata);
      if(axi.wlast)  send.write(write_data_array[axi.wid]);
    end
  endtask
  task record_address_read();
    forever begin  
   	  @(posedge axi.arvalid);
      read_data= transaction::type_id::create("read_data");
      read_data.len=axi.arlen;
      read_data.addr=axi.araddr;
      read_data.burst=axi.arburst;
      read_data.id=axi.arid;
      read_data.data=new[0];
      read_data.read=1;
      read_data_array[axi.arid]=read_data;
    end
  endtask
  task record_data_read();
    forever begin
      @(posedge axi.rvalid);
      read_data_array[axi.rid].add_data(axi.rdata);
      if(axi.rlast)  send.write(read_data_array[axi.rid]);
    end
  endtask
  
  
  task run_phase(uvm_phase phase);
    fork
      record_address_write();
      record_data_write();
      record_address_read();
      record_data_read();
    join
  endtask
  
  
 endclass