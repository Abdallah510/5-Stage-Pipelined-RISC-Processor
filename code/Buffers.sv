module IF_ID(clk,stall,kill,F_instruction,F_PC,D_instruction,D_PC);
  input clk,stall,kill;
  input [31:0] F_instruction,F_PC;
  output reg [31:0] D_instruction,D_PC;
  
  always @(posedge clk) begin
    if (!stall) begin
      	if (kill)
        	D_instruction = 32'h00000000;
      	else 
        	D_instruction = F_instruction;
     	D_PC = F_PC;
    end
  end
endmodule

module ID_Ex(clk,stall,src1_d,src2_d,regDest_d,imm_d,aluSrc_d,aluOp_d,regWrite_d,memWrite_d,WBData_d,memRead_d,check_SDW_d,count1_d,check_LDW_d,count2_d,
               src1_e,src2_e,regDest_e,imm_e,aluSrc_e,aluOp_e,regWrite_e,memWrite_e,WBData_e,memRead_e,D_PC,E_PC,check_SDW_e,count1_e,check_LDW_e,count2_e);
    
  	input [31:0] src1_d,src2_d,D_PC,imm_d;
  	input [1:0]aluOp_d,WBData_d;
    input [3:0]regDest_d;
    input aluSrc_d,regWrite_d,memWrite_d,clk,stall,memRead_d,check_SDW_d,count1_d,check_LDW_d,count2_d;
    
 	output reg [31:0] src1_e,src2_e,E_PC,imm_e;
  	output reg [1:0]aluOp_e,WBData_e;
    output reg [3:0]regDest_e;
    output reg aluSrc_e,regWrite_e,memWrite_e,memRead_e,check_SDW_e,count1_e,check_LDW_e,count2_e;
    
    always @(posedge clk)begin
      if(!stall)begin
        src1_e=src1_d;
        src2_e=src2_d;
        regDest_e=regDest_d;
        imm_e=imm_d;
        aluSrc_e=aluSrc_d;
        aluOp_e=aluOp_d;
        regWrite_e=regWrite_d;
        memWrite_e=memWrite_d;
        WBData_e=WBData_d;
        memRead_e=memRead_d;
        E_PC=D_PC;
        check_SDW_e = check_SDW_d;
        count1_e = count1_d;
        check_LDW_e = check_LDW_d;
        count2_e = count2_d;
      end
      else begin
        src1_e=src1_d;
        src2_e=src2_d;
        regDest_e=regDest_d;
        imm_e=imm_d;
        aluSrc_e=1'b0;
        aluOp_e=2'b00;
        regWrite_e=1'b0;
        memWrite_e=1'b0;
        WBData_e=2'b00;
        memRead_e=1'b0;
        check_SDW_e = 1'b0;
        count1_e = 1'b0;
        check_LDW_e = 1'b0;
        count2_e = 1'b0;
        E_PC=D_PC;
      end
    end
  endmodule
                
module Ex_Mem(clk,WE_Ex,MemR_Ex,MemW_Ex,WB_Ex,Rd_Ex,Data_Ex,Result_Ex,
              WE_Mem, MemR_Mem,MemW_Mem,WB_Mem,Rd_Mem,Data_Mem,Result_Mem,E_PC,M_PC);
  
  input clk,WE_Ex,MemR_Ex,MemW_Ex;
  input[1:0] WB_Ex;
  input [3:0] Rd_Ex;
  input [31:0] Data_Ex,Result_Ex,E_PC;
  output reg WE_Mem, MemR_Mem,MemW_Mem;
  output reg [1:0] WB_Mem;
  output reg [3:0] Rd_Mem;
  output reg [31:0] Data_Mem,Result_Mem,M_PC;
  
  always @(posedge clk) begin
    WE_Mem = WE_Ex;
    MemR_Mem = MemR_Ex;
    MemW_Mem = MemW_Ex;
    WB_Mem = WB_Ex;
    Rd_Mem = Rd_Ex;
    Data_Mem = Data_Ex;
    Result_Mem = Result_Ex;
    M_PC=E_PC;
  end
  
endmodule

module mem_wb(clk,regWrite_m,regDest_m,WBData_m,regWrite_wb,regDest_wb,WBData_wb);
  input [31:0] WBData_m;
  input clk,regWrite_m;
  input [3:0]regDest_m;
  output reg [31:0]WBData_wb;
  output reg regWrite_wb;
  output reg [3:0]regDest_wb;
  always @(posedge clk)begin
    regWrite_wb=regWrite_m;
    regDest_wb=regDest_m;
    WBData_wb=WBData_m;
  end
endmodule