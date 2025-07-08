module RegFile(src1,src2,regDest,WE,clk,reg1,reg2,data);
  input  [3:0] src1, src2, regDest;
  input  [31:0] data;
  input  WE, clk;
  output [31:0] reg1, reg2;        
  reg signed [31:0] registers[14:0];     
  
  always @(posedge clk)begin
    if(WE)
      registers[regDest] <= data;
    //$display("Writing %h to register %d at time %0t", data, regDest, $time);
      end
  assign reg1 = registers[src1];
  assign reg2 = registers[src2];
  integer i;
  initial begin
    for (i = 0; i < 15; i = i + 1)
      registers[i] = 32'h00000000;
    end

  initial $monitor("at time = %0d:\nR0 = %0d  R1 = %0d  R2 = %0d  R3 = %0d\nR4 = %0d  R5 = %0d  R6 = %0d  R7 = %0d\nR8 = %0d  R9 = %0d R10 = %0d R11 = %0d\nR12 = %0d R13 = %0d R14 = %0d",
        $time, 
                   registers[0], registers[1], registers[2], registers[3],
                   registers[4], registers[5], registers[6], registers[7],
                   registers[8], registers[9], registers[10], registers[11],
                   registers[12], registers[13], registers[14]
    );

endmodule


