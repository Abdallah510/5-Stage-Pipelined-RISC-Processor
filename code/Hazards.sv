module forwarding(R,Rd_Ex,Rd_Mem,Rd_WB,WE_Ex,WE_Mem,WE_WB,forward);
  input [3:0] R,Rd_Ex,Rd_Mem,Rd_WB;
  input WE_Ex,WE_Mem,WE_WB;
  output reg [1:0] forward;
  
  always @(*) begin
    if (WE_Ex && R == Rd_Ex)
      forward = 2'b01;
    else if (WE_Mem && R == Rd_Mem)
      forward = 2'b10;
    else if (WE_WB && R == Rd_WB)
      forward = 2'b11;
    else
      forward = 2'b00;
  end
endmodule

module stall(MemR_Ex,forward_A,forward_B,WBData,stall);
  input MemR_Ex;
  input [1:0] forward_A,forward_B,WBData;
  output reg stall;
  
  initial stall = 1'b0;
  always @(*) begin
    if (MemR_Ex && (forward_A == 1 || forward_B == 1))
      stall = 1;
    else if(WBData==2 && (forward_A == 2 || forward_B == 2))
      stall = 1;
    else
       stall = 0;
  end
endmodule

module kill(opcode,ZF,NF,kill);
  input [5:0] opcode;
  input ZF,NF;
  output reg kill;
  
  initial kill = 1'b0;
  always @(*) begin
    if (opcode == 6'd10 && ZF) 
      kill = 1;
    else if (opcode == 6'd11 && !NF && !ZF) 
      kill = 1;
    else if (opcode == 6'd12 && NF && !ZF) 
      kill = 1;
    else if (opcode == 6'd13 ||opcode == 6'd14 || opcode == 6'd15) 
      kill = 1;
    else
      kill = 0;
    end
endmodule