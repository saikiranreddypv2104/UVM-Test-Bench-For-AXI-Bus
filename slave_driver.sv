
class slave_driver  extends uvm_driver;
   `uvm_component_utils(slave_driver)
   virtual axi_if axi;
   slave_transaction address_write_array [int];
   slave_transaction address_read_array[int];
   slave_transaction tr;
   slave_transaction read_tr;
   reg [7:0] mem[1000] = '{default:0};
   /////////////////////////////////
   function new(string name="slave_driver",uvm_component parent=null);
      super.new(name,parent);
   endfunction // new
   
   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      uvm_config_db #(virtual axi_if)::get(null,"*","axi",axi);
      tr= slave_transaction::type_id::create("tr");
      read_tr=slave_transaction::type_id::create("read_tr");
   endfunction // build_phase
   
  task reset();
    forever begin
      @(negedge axi.resetn);
      
      axi.awready<=0;
      axi.wready<=0;
      axi.bvalid<=0;
      axi.arready<=0;
      
      axi.rvalid<=0;
      axi.rid<=0;
      axi.rdata<=0;
      axi.rlast<=0;
      axi.rresp<=0;
      axi.bvalid<=0;
      
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
   ///////////////////////////function to compute next address during INCR burst type 
   task write_address_lane();
      forever begin
         @(posedge axi.awvalid);
         @(posedge axi.clk);
         tr=new();
         tr.id=axi.awid;
         tr.len=axi.awlen;
         tr.addr=axi.awaddr;
         tr.size=axi.awsize;
         tr.burst=axi.awburst;
         address_write_array[tr.id]=tr;
         axi.awready<=1;
         @(posedge axi.clk);
         axi.awready<=0;
      end // forever begin
   endtask // write_address_lane
   //////////////////////////////////////
   bit first;
   reg [31:0] nextaddress;
  /////////////////////////////////////
   task write_data_lane();
     first=1;
      forever begin
         @(posedge axi.wvalid);
         @(posedge axi.clk);
         address_write_array[axi.wid].add_data(axi.wdata);
        if(first==1) begin
          nextaddress= address_write_array[axi.wid].addr;
          first=0;
        end
        nextaddress=data_wr_incr(axi.wstrb,nextaddress);
        axi.wready=1;
        // wirte_data_increment();
        if(axi.wlast) begin
          first=1;
          address_write_array[axi.wid].display("slave DRV");
        end
          @(posedge axi.clk);
         axi.wready=0;
      end
   endtask // write_data_lane
  //////////////////////////////////////////////////
   task write_resp_lane();
      forever begin
        axi.bvalid=0;
        @(posedge axi.wlast);//wait until the last beat recieved and give the response
        repeat(2) @(posedge axi.clk);
        axi.bvalid=1;
        if( (address_write_array[axi.wid].addr < 1000) && (address_write_array[axi.wid].size < 3'b011)) 
	   		axi.bresp = 2'b00;  ///okay
        else if (address_write_array[axi.wid].size > 3'b011)  
	   		axi.bresp = 2'b10; /////slverr
        else  
	   		axi.bresp = 2'b11;  ///no slave address   
         @(posedge axi.bready);
         @(posedge axi.clk);
         axi.bvalid=0;
      end
   endtask // write_resp_lane
   ////////////////////////////////////////////////
   task read_address_lane();
      forever begin
        @(posedge axi.arvalid);
        @(posedge axi.clk);
        read_tr=new("read_tr");
        read_tr.id=axi.arid;
        read_tr.len=axi.arlen;
        read_tr.size=axi.arsize;
        read_tr.addr=axi.araddr;
        read_tr.burst=axi.arburst;
        address_read_array[axi.arid]=read_tr;
        axi.arready=1;
        @(posedge axi.clk);
        axi.arready=0;
      end
   endtask // read_address_lane
   /////////////////////
   integer i;
   logic [31:0]	temp; 
   task read_data_lane();
     
     forever begin
         @(posedge axi.arvalid);
         repeat(3) @(posedge axi.clk);
         temp=axi.arid;       
         for(i=0;i<address_write_array[temp].data.size();i=i+1) begin
           repeat(3) @(posedge axi.clk);
             axi.rdata=address_write_array[temp].data[i];
             axi.rid=temp;
             axi.rstrb=4'b1111;
             axi.rresp=2'b00;
           if(i==address_write_array[temp].data.size()-1) begin
             axi.rlast=1;
           end
             else axi.rlast=0;
             axi.rvalid=1;
             @(posedge axi.rready);
             @(posedge axi.clk);
            axi.rvalid=0;
           end // for (i=0;i<address_write_array[temp].data.size();i=i+1)

         axi.rlast=0;
         axi.rvalid=0;
        
     end
   endtask // read_data_lane
	///////////////////////////
   task run_phase(uvm_phase phase);
      fork
        reset();
         write_address_lane();
         write_data_lane();
         write_resp_lane();
         read_address_lane();
         read_data_lane();
      join
   endtask 
  ////////////////////////////////////////////////////
  ////////////////////////////////////////////////////
  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    $writememh("file.txt", mem);
  endfunction
  
  ///////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  
   function bit[31:0] data_wr_incr (input [3:0] wstrb, input [31:0] awaddrt);
      
   	 bit [31:0] addr;
     reg [31:0] wdatat;
     wdatat=axi.wdata;
    unique case (wstrb)
      4'b0001: begin 
        mem[awaddrt] = wdatat[7:0];
        addr = awaddrt + 1;
      end
      
      4'b0010: begin 
        mem[awaddrt] = wdatat[15:8];
        addr = awaddrt + 1;
      end
      
      4'b0011: begin 
        mem[awaddrt] = wdatat[7:0];
        mem[awaddrt + 1] = wdatat[15:8];
        addr = awaddrt + 2;
      end
      
       4'b0100: begin 
         mem[awaddrt] = wdatat[23:16];
         addr = awaddrt + 1;
      end
      
       4'b0101: begin 
        mem[awaddrt] = wdatat[7:0];
         mem[awaddrt + 1] = wdatat[23:16];
         addr = awaddrt + 2;
      end
      
      
       4'b0110: begin 
         mem[awaddrt] = wdatat[15:8];
         mem[awaddrt + 1] = wdatat[23:16];
         addr = awaddrt + 2;
      end
      
       4'b0111: begin 
         mem[awaddrt] = wdatat[7:0];
         mem[awaddrt + 1] = wdatat[15:8];
         mem[awaddrt + 2] = wdatat[23:16];
         addr = awaddrt + 3;
      end
      
       4'b1000: begin 
         mem[awaddrt] = wdatat[31:24];
         addr = awaddrt + 1;
      end
      
       4'b1001: begin 
         mem[awaddrt] = wdatat[7:0];
         mem[awaddrt + 1] = wdatat[31:24];
         addr = awaddrt + 2;
      end
      
      
       4'b1010: begin 
         mem[awaddrt] = wdatat[15:8];
         mem[awaddrt + 1] = wdatat[31:24];
         addr = awaddrt + 2;
      end
      
      
       4'b1011: begin 
         mem[awaddrt] = wdatat[7:0];
         mem[awaddrt + 1] = wdatat[15:8];
         mem[awaddrt + 2] = wdatat[31:24];
         addr = awaddrt + 3;
      end
      
      4'b1100: begin 
         mem[awaddrt] = wdatat[23:16];
         mem[awaddrt + 1] = wdatat[31:24];
         addr = awaddrt + 2;
      end
 
      4'b1101: begin 
        mem[awaddrt] = wdatat[7:0];
        mem[awaddrt + 1] = wdatat[23:16];
        mem[awaddrt + 2] = wdatat[31:24];
        addr = awaddrt + 3;
      end
 
      4'b1110: begin 
        mem[awaddrt] = wdatat[15:8];
        mem[awaddrt + 1] = wdatat[23:16];
        mem[awaddrt + 2] = wdatat[31:24];
        addr = awaddrt + 3;
      end
      
      4'b1111: begin
        mem[awaddrt] = wdatat[7:0];
        mem[awaddrt + 1] = wdatat[15:8];
        mem[awaddrt + 2] = wdatat[23:16];
        mem[awaddrt + 3] = wdatat[31:24]; 
        addr = awaddrt + 4;      
      end
     endcase
    return addr;
  endfunction  
  /////////////////////////////////////////////////////////
  
  
     function bit [31:0] read_data_incr (input [31:0] addr, input [2:0] arsize);
      bit [31:0] nextaddr;
       reg [31:0] rdata;
      unique case(arsize)
        3'b000: begin
          rdata[7:0] = mem[addr];
          nextaddr = addr + 1;
       end
       
       3'b001: begin
       rdata[7:0]  = mem[addr];
       rdata[15:8] = mem[addr + 1];
       nextaddr = addr + 2;  
       end
       
       3'b010: begin
       rdata[7:0]    = mem[addr];
       rdata[15:8]   = mem[addr + 1];
       rdata[23:16]  = mem[addr + 2];
       rdata[31:24]  = mem[addr + 3];
       nextaddr = addr + 4;  
       end
      
      endcase
      
      return nextaddr;
     endfunction
  ///////////////////////////////////////////////////////////
endclass // slave_agent
