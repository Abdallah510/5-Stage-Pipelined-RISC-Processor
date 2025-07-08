module Main_ALU_Control(opCode_In,aluSrc,aluOp,regWrite,memWrite,WBData,memRead,extOP,opCode_Out,St);
  input [5:0]opCode_In;
  output reg aluSrc,regWrite,memWrite,memRead,extOP;
  output reg[1:0]aluOp,WBData;
  output reg [5:0]opCode_Out;
  output reg St;
  
  reg [14:0] ROM[63:0]; 
  
  initial begin 
    $readmemb("ControlSignals.dat",ROM);
  end
  always @(opCode_In) begin
    extOP= ROM[opCode_In][14];        
  	regWrite= ROM[opCode_In][13];
  	aluSrc= ROM[opCode_In][12];
  	aluOp= ROM[opCode_In][11:10];
    memRead = ROM[opCode_In][9];
    memWrite= ROM[opCode_In][8];
  	WBData= ROM[opCode_In][7:6];
  	opCode_Out= ROM[opCode_In][5:0];        
   	St=0;
    //$display("opCode=%d -> ROM=%b aluOp=%b regWr=%b memRd=%b", opCode_In, ROM[opCode_In], aluOp, regWrite, memRead);
    if (opCode_In == 6'd7 || opCode_In == 6'd9)
      St=1;
  end
endmodule
      
      
      
 module PC_Control(current_PC,immExt,ZF,NF,opcode,Rs,Next_PC);
    input [31:0] current_PC,Rs;
   	input [31:0] immExt;
    input ZF,NF;
    input [5:0] opcode;
    output reg [31:0] Next_PC;

    initial Next_PC = 0;
   always @(*) begin
        case (opcode)
            6'd0:  Next_PC = current_PC + 1;
          	6'd10: if (ZF)
                    	Next_PC = current_PC + immExt-1;
            	   else 
                    	Next_PC = current_PC + 1;
          6'd11:if (!NF && !ZF)
                    	Next_PC = current_PC + immExt-1;
            	   else 
                    	Next_PC = current_PC + 1;
          6'd12: if (NF && !ZF)
                    	Next_PC = current_PC + immExt-1;
            	   else 
                    	Next_PC = current_PC + 1;
            6'd13: Next_PC = Rs;
            6'd14, 6'd15: Next_PC = current_PC + immExt-1;
            default:Next_PC = current_PC + 1;
        endcase
    end
endmodule