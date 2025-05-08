// Code your testbench here
// or browse Examples
`include "packages.sv"
module tb;
  
  axi_if axi();
  
  initial begin
    axi.resetn=0;
    axi.clk=0;
  end
  initial begin
    repeat(2) @(posedge axi.clk);
    axi.resetn=1;
  end
  always #5 axi.clk =~ axi.clk;
  
  initial begin
    @(posedge axi.clk);
    axi.resetn=0;
    repeat(3) @(posedge axi.clk);
    axi.resetn=1;
  end
  
  	initial begin
      uvm_config_db #(virtual axi_if)::set(null, "*", "axi", axi);
      run_test("test");//uvm test
  	end
  
    initial begin
    $dumpfile("dump.vcd"); $dumpvars;

  	end
endmodule