`include "Control.sv"
`include "Memory.sv"
`include "Components.sv"
`include "Hazards.sv"
`include "RegFile.sv"
`include "ALU.sv"
module instruction_fetch(clk,stall,kill,ZF,NF,immExt,opcode,Rs,instruction,next_PC);
  input clk, stall, kill, ZF, NF;
  input [31:0] immExt, Rs;
  input [5:0] opcode;
  output reg [31:0] instruction, next_PC;
  wire [31:0] inst;
  reg [31:0] PC;
  wire [31:0] nextPC;
  reg insert_NOP;

  PC_Control pc_control_unit(PC, immExt, ZF, NF, opcode,Rs, nextPC);
  instMem instruction_mem(PC, inst);

  initial begin
    instruction = 32'h00000000;
    PC = 0;
    insert_NOP = 0;
  end

  always @(posedge clk) begin
    if (!stall) begin
      if (insert_NOP) begin
        insert_NOP = 0;
        next_PC = PC;
      end else begin
        if (!kill)
          instruction = inst;
        else
          instruction = 32'h00000000;

        if (inst[31:26] == 6'd9 || inst[31:26] == 6'd8) begin
          insert_NOP = 1;
        end

        PC = nextPC;
        next_PC = nextPC;
      end
    end
  end
endmodule

module instruction_decode(clk,inst,pc_in,src1,src2,immExt,regDst,pc_out,memRd,memWr,aluSrc,aluOp,regWr,WBData,opcode,ZF,NF,regWr_ex,regWr_mem,regWr_wb,regDst_ex,regDst_mem,regDst_wb,memRd_ex,WBData_mem,kill,stall,aluForward,memForward,WBForward,Rs,check_SDW,count1,check_LDW,count2);
  
  input clk,regWr_ex,regWr_mem,regWr_wb,memRd_ex;
  input [1:0] WBData_mem;
  input [31:0] inst,pc_in,aluForward,memForward,WBForward;
  input [3:0]regDst_ex,regDst_mem,regDst_wb;
  output reg [31:0] src1,src2,immExt,pc_out,Rs;
  output reg memRd,memWr,aluSrc,regWr,ZF,NF,kill,stall;
  output reg [1:0] WBData,aluOp;
  output reg [5:0] opcode;
  output reg [3:0] regDst;
  output reg check_SDW;
  output reg count1;
  output reg check_LDW;
  output reg count2;
  
  wire immE,St;
  wire [3:0] rs,rt,rd;
  wire [5:0] op;
  wire [13:0] imm;
  reg [3:0] rt_sel;
  reg [1:0] forwardA,forwardB;
  wire [31:0] reg1,reg2;
  reg second_cycle;
 
  Split split(inst,op,rd,rs,rt,imm);
  Main_ALU_Control main(op,aluSrc,aluOp,regWr,memWr,WBData,memRd,immE,opcode,St);
  forwarding A(rs,regDst_ex,regDst_mem,regDst_wb,regWr_ex,regWr_mem,regWr_wb,forwardA);
  forwarding B(rt_sel,regDst_ex,regDst_mem,regDst_wb,regWr_ex,regWr_mem,regWr_wb,forwardB);
  RegFile RF(rs,rt_sel,regDst_wb,regWr_wb,clk,reg1,reg2,WBForward);
  imm_extender ext(immE,imm,immExt);
  stall st(memRd_ex,forwardA,forwardB,WBData_mem,stall);
  kill ki (opcode,ZF,NF,kill);
  
  initial begin
  	check_SDW = 0;
  	count1 = 0;
  	check_LDW = 0;
  	count2 = 0;
    second_cycle = 0;
  end
  always @(posedge clk)begin
    if (op == 6'd9)
      count1 = 1;
    if (op == 6'd8)
      count2 = 1;
    if (second_cycle)begin
      count1 = 0;
      count2 = 0;
      second_cycle = 0;
    end
  end
  
  always @(*)begin
    if(check_SDW && count1)begin
      check_SDW = 0;
      second_cycle = 1;
      regDst=rd+1;
    end
    else if(check_LDW && count2)begin
      check_LDW = 0;
      second_cycle = 1;
      regDst=rd+1;
    end
    else
      regDst=rd;
    if ((check_SDW || check_LDW) && regDst[0] == 1'b1 && !second_cycle)begin
      	$display("ERROR: Register number is not even! Rd = %0d", regDst);
    	$finish;
    end
    if (St)
      rt_sel=regDst;
    else
      rt_sel=rt;
    case (forwardA)
      2'b00: src1 = reg1;
      2'b01: src1 = aluForward;
      2'b10: src1 = memForward;
      2'b11: src1 = WBForward;
    endcase
   
    case (forwardB)
      2'b00: src2 = reg2;
      2'b01: src2 = aluForward;
      2'b10: src2 = memForward;
      2'b11: src2 = WBForward;
    endcase	
    Rs=src1;
    pc_out = pc_in;
    if (opcode == 6'd9)
       	check_SDW = 1;
    else if(opcode == 6'd8)
      	check_LDW = 1;
    if(op == 6'd15)
       regDst=6'd14;
  end
  Comparator32Bit com(src1,ZF,NF);
endmodule

module ExecutionStage(check_SDW,count1,check_LDW,count2,src1,src2,immExt,regDst_in,pc_in,regWr_in,aluSrc,aluOp,memRd_in,memWr_in,WBData_in,pc_out,memRd_ex,memWr_out,WBData_out,regWr_ex,regDst_ex,aluForward,src2_out);
  input check_SDW,count1,check_LDW,count2;
  input [31:0] src1,src2,immExt,pc_in;
  input [3:0]regDst_in;
  input[1:0]aluOp,WBData_in;
  input regWr_in,aluSrc,memRd_in,memWr_in;
  output reg [31:0] pc_out,aluForward,src2_out;
  output reg memRd_ex,memWr_out,regWr_ex;
  output reg [1:0] WBData_out;
  output reg [3:0] regDst_ex;
  
  reg [31:0] temp,in2;
  
  ALU execution(src1,in2,aluOp,aluForward);
  always @(*)begin
    //$display("x = %d", src1);
    //$display("y = %d",in2);
    if(check_SDW && count1)
      temp =immExt+1;
    else if(check_LDW && count2)
      temp =immExt+1;
    else
      temp=immExt;
    if(!aluSrc)
      in2=src2;
    else
      in2=temp;
    pc_out=pc_in;
    memRd_ex=memRd_in;
    memWr_out=memWr_in;
    regWr_ex=regWr_in;
    src2_out=src2;
    WBData_out=WBData_in;
    regDst_ex=regDst_in;
  end
endmodule
    
module MemoryStage(clk,aluRes,regDst,regWr,dataIn,pc,memRd,memWr,WBData,regWr_mem,memForward,regDst_mem,WBData_mem);
  
  input clk,memRd,memWr,regWr;
  input [31:0] aluRes,pc,dataIn;
  input[3:0] regDst;
  input [1:0] WBData;
  output reg [31:0] memForward;
  output reg regWr_mem;
  output reg [3:0] regDst_mem;
  output reg [1:0]WBData_mem;
  
  wire [31:0] memoryData;
  dataMem ReadData(clk,dataIn,aluRes,memRd,memWr, memoryData);
  
  always @(*) begin
    if(WBData==0)
      memForward=aluRes;
    else if (WBData==1)
      memForward=memoryData;
    else
      memForward=pc;
    regDst_mem=regDst;
    WBData_mem=WBData;
    regWr_mem=regWr;  
  end  
endmodule    