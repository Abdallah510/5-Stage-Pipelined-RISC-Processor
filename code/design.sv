`include "Stages.sv"
`include "Buffers.sv"
module CPU(clk);
  input clk;
  
  wire [31:0] F_instruction, F_PC;
  wire [31:0] D_instruction, D_PC;
  wire stall, kill;

  // === ID to ID/EX ===
  wire [31:0] src1_d, src2_d, immExt_d,pc_d;
  wire [3:0] regDest_d;
  wire [1:0] aluOp_d, WBData_d;
  wire aluSrc_d, regWrite_d, memWrite_d, memRead_d,check_SDW_d,count1_d,check_LDW_d,count2_d;

  // === ID/EX to EX ===
  wire [31:0] src1_e, src2_e, immExt_e, E_PC;
  wire [3:0] regDest_e;
  wire [1:0] aluOp_e, WBData_e;
  wire aluSrc_e, regWrite_e, memWrite_e, memRead_e,check_SDW_e,count1_e,check_LDW_e,count2_e;

  // === EX to EX/MEM ===
  wire [31:0] src2_out_ex,pc_ex;
  wire [31:0] M_PC;
  wire [3:0] regDest_ex;
  wire [1:0] WBData_ex;
  wire regWrite_ex, memWrite_ex, memRead_ex;

  // === EX/MEM to MEM ===
  wire [31:0] Data_M,pc_M,Result_M;
  wire [3:0] Rd_M;
  wire [1:0] WBData_M;
  wire regWrite_M, memWrite_M, memRead_M;

  // === MEM to MEM/WB ===
  wire [1:0] WBData_mem;
  wire [3:0] regDest_mem;
  wire regWrite_mem;
  // === MEM/WB to WB ===
  wire regWr_wb;
  wire [3:0] regDest_wb;
  
  // === Forwarding Wires ===
  wire [31:0] aluForward, memForward, WBForward;

  // === Hazard & Control ===
  wire [5:0] opcode;
  wire ZF, NF;
  wire [31:0] Rs;
  
  //First Stage
  
  instruction_fetch fetch(clk,stall,kill,ZF,NF,immExt_d,opcode,Rs,F_instruction,F_PC);
  
  IF_ID buff1(clk,stall,kill,F_instruction,F_PC,D_instruction,D_PC);
  
  //Second Stage
  
  instruction_decode dec(clk,D_instruction,D_PC,src1_d, src2_d,immExt_d,regDest_d,pc_d,memRead_d,memWrite_d,aluSrc_d,aluOp_d,regWrite_d,WBData_d,opcode,ZF, NF,regWrite_ex,regWrite_mem,regWr_wb,regDest_ex,regDest_mem,regDest_wb,memRead_ex,WBData_mem,kill,stall,aluForward,memForward, WBForward,Rs,check_SDW_d,count1_d,check_LDW_d,count2_d);
  
  ID_Ex buff2(clk,stall,src1_d,src2_d,regDest_d,immExt_d,aluSrc_d,aluOp_d,regWrite_d,memWrite_d,WBData_d,memRead_d,check_SDW_d,count1_d,check_LDW_d,count2_d,src1_e, src2_e,regDest_e,immExt_e,aluSrc_e,aluOp_e,regWrite_e,memWrite_e,WBData_e,memRead_e,pc_d,E_PC,check_SDW_e,count1_e,check_LDW_e,count2_e);
  
  //third Stage
  
  ExecutionStage ext(check_SDW_e,count1_e,check_LDW_e,count2_e,src1_e,src2_e,immExt_e,regDest_e,E_PC,regWrite_e,aluSrc_e,aluOp_e,memRead_e,memWrite_e,WBData_e,pc_ex,memRead_ex,memWrite_ex,WBData_ex,regWrite_ex,regDest_ex,aluForward,src2_out_ex);
  
  Ex_Mem buff3(clk,regWrite_ex,memRead_ex,memWrite_ex,WBData_ex,regDest_ex,src2_out_ex,aluForward,regWrite_M,memRead_M,memWrite_M,WBData_M,Rd_M,Data_M,Result_M,pc_ex,pc_M);
  
  //forth Stage
  
  MemoryStage mem(clk,Result_M,Rd_M,regWrite_M,Data_M,pc_M,memRead_M,memWrite_M,WBData_M,regWrite_mem,memForward,regDest_mem,WBData_mem);
  
  mem_wb buff4(clk,regWrite_mem,regDest_mem,memForward,regWr_wb,regDest_wb,WBForward);
  
  /*always @(posedge clk) begin
  $display("\n==== time %0t ====", $time);

  // Stage 1: Instruction Fetch
  $display("IF  => PC: %d | Instruction: %h", F_PC, F_instruction);

  // Stage 2: Instruction Decode
  $display("ID  => PC: %d | src1: %d | src2: %d | ImmExt: %d | RegDest: %0d | ALUOp: %b | ALUSrc: %b | RegWrite: %b | WBData: %b", 
           D_PC, src1_d, src2_d, immExt_d, regDest_d, aluOp_d, aluSrc_d, regWrite_d, WBData_d);

  // Stage 3: Execute
  $display("EX  => PC: %d | ALUResult: %h | src2: %h | RegDest: %0d | ALUOp: %b | WBData: %b", 
           E_PC, aluForward, src2_out_ex, regDest_ex, aluOp_e, WBData_e);

  // Stage 4: Memory Access
  $display("MEM => PC: %d | MemResult: %h | WriteData: %h | RegDest: %0d | MemRead: %b | MemWrite: %b | WBData: %b", 
           pc_M, memForward, Data_M, regDest_mem, memRead_M, memWrite_M, WBData_M);

  // Stage 5: Write Back
  $display("WB  => WBData: %h | RegDest: %0d | RegWrite: %b | WBDataSel: %b", 
           WBForward, regDest_wb, regWr_wb, WBData_mem);
end*/

  
endmodule