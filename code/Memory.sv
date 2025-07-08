module instMem(address,inst);
  input [31:0] address;
  output reg [31:0] inst;
  reg [31:0] rom[2000:0];
  initial begin 
    $readmemh("InstFile.dat",rom);
  end
  always @(address) begin 
    inst = rom[address];
  end
endmodule

module dataMem(clk,data_in,address,mem_r,mem_w,data_out);
  input clk,mem_r,mem_w;
  input [31:0] data_in, address;
  output reg [31:0] data_out;
  reg [31:0] ram_memory[2000:0];
  
  always @(posedge clk) begin
    if (mem_w)begin
      ram_memory[address] <= data_in;
    $display("WRITE: ram_memory[%0d] <= %h", address, data_in);
    end
  end
  
  always @(*) begin
    if (mem_r)
      data_out = ram_memory[address];
    else
      data_out = 32'b0;
  end
endmodule

