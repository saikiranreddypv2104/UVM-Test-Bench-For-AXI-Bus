
////////////////////////////////////////////
/////////////driver/////////////////////////
class driver extends uvm_driver #(transaction);
  `uvm_component_utils(driver)
  transaction tr;
  virtual axi_if axi;
  transaction address[$];
  function new(input string path="DRV",uvm_component parent =null);
    super.new(path,parent);
    $display("driver created");
  endfunction
 
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  
    tr=transaction::type_id::create("tr");
    uvm_config_db #(virtual axi_if) :: get(this,"*","axi",axi);
  endfunction
  //////////////////////////////////////////
  task reset();//reseting the apb slave
    forever begin
      @(negedge axi.resetn);
      //////////////////////
      axi.awvalid<=0;
      axi.awid<=0;
      axi.awlen<=0;
      axi.awsize<=0;
      axi.awaddr<=0;
      axi.awburst<=0;
      ///////////////
      axi.wvalid<=0;
      axi.wid<=0;
      axi.wdata<=0;
      axi.wstrb<=0;
      axi.wlast<=0;
      /////////////
      axi.bready<=0;
      axi.bid<=0;
      axi.bresp<=0;
      /////////////
      axi.arvalid<=0;
      axi.arready<=0;
      axi.arid<=0;
      axi.arlen<=0;
      axi.arsize<=0;
      axi.araddr<=0;
      axi.arburst<=0;
      /////////////
      axi.rready<=0;
    end
  endtask
  ////////////////////////////////////////////////write address channel 
  task write_address_channel(input transaction tr);
      @(posedge axi.clk);
      axi.awaddr=tr.addr;
      axi.awlen=tr.len;//number of the transactions
      axi.awid=tr.id;//for nor give a fixed id
      axi.awsize=2;//we are giving 2 because 2**2=4 4bytes ~32bits of data is transafered
      axi.awburst=2'b01;//fixed burst type
      axi.awvalid=1;
      @(posedge axi.awready);
      @(posedge axi.clk);
      axi.awvalid=0;
  endtask
  ////////////////////////////////////////////////write data channel
  task write_data_channel(input transaction tr);
     // @(posedge axi.awvalid)
      @(posedge axi.clk);
      axi.wid=tr.id;
      axi.wstrb=4'b1111;
    for(int i=0;i<tr.len+1;i=i+1) begin
        axi.wvalid=1;
        axi.wdata=tr.data[i];
        if(i==tr.len) axi.wlast=1;
        else axi.wlast=0;
        @(posedge axi.wready);
        @(posedge axi.clk);
        axi.wvalid=0;
        axi.wlast=0;
        @(posedge axi.clk);
      end
      axi.wvalid=0;
      axi.wlast=0;
  endtask
  ////////////////////////////////////////////////
  task write_response(transaction tr);
    $display("waiting for bvalid read response channel bvaid:%0d",axi.bvalid);
    //@(posedge axi.bvalid);
    @(posedge axi.clk);
    $display("bvalid is high , making bready high");
    axi.bready=1;
    //
    case(axi.bresp)
      2'b00:$display("------------------>[DRV] ID:%0d RESPONSE:OKAY",tr.id);
      2'b01:$display("------------------>[DRV] ID:%0d RESPONSE:EXOKAY",tr.id);
      2'b10:$display("------------------>[DRV] ID:%0d RESPONSE:SLVERR",tr.id);
      2'b11:$display("------------------>[DRV] ID:%0d RESPONSE:DECERR",tr.id);
    endcase
    //
    if (axi.bresp!=2'b00)
    repeat(2) @(posedge axi.clk);
    axi.bready=0;
  endtask
  ////////////////////////////////////////////////
  task write(input transaction tr);
    fork
      write_address_channel(tr);
      write_data_channel(tr);
      $display("write address and data channels is completed");
      write_response(tr);
    join
  endtask
  ////////////////////////////////////////////
  task read_address_channel(input transaction tr);  
    @(posedge axi.clk);
        axi.araddr=tr.addr;
        axi.arlen=tr.len;//number of the transactions
        axi.arid=tr.id;//for nor give a fixed id
        axi.arsize=2;//we are gi
        axi.arburst=2'b01;//INCREMENTAL burst type
        axi.arvalid=1;
        @(posedge axi.arready);
        @(posedge axi.clk);
        axi.arvalid=0;
  endtask
  integer count=0;
  //////////////////////////////read data channel
    task read_data_channel(input transaction tr);
      @(negedge axi.arvalid);
     forever begin 
      
       wait (axi.rvalid);
       @(posedge axi.clk);
       axi.rready<=1;
       if(axi.rlast==1) begin
         
          @(negedge axi.rvalid);
          @(posedge axi.clk);
          axi.rready<=0;
          break;
       end
       @(negedge axi.rvalid);
       @(posedge axi.clk);
       axi.rready<=0;
     end
     
  	endtask

  ////////////////////////////////////////////
  task write_out_of_order();
    foreach(address[i]) begin
      write_address_channel(address[i]);
      repeat(20) @(posedge axi.clk);
    end
     $display("writing address is done");
    address.shuffle();
    foreach(address[i]) begin
      write_data_channel(address[i]);
    end
  endtask
  //////////////////////////////////////////
  task read(transaction tr);
    fork
      read_address_channel(tr);
      read_data_channel(tr);
    join
  endtask
  ////////////////////////////////////////////
  bit write_done=0;
  virtual task run_phase(uvm_phase phase);
      
      forever begin
        seq_item_port.get_next_item(tr);//ask for the data
        if(tr.read==0) begin
          address.push_front(tr);
        end
        else begin
          if(write_done==1) read(tr);
          else begin
            write_out_of_order();
            write_done=1;
            read(tr);
          end
        end
        seq_item_port.item_done();//send the done signal    
      end
    
  endtask
  
endclass