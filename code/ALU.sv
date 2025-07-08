module ALU(x,y,aluOP,result);
  input signed [31:0] x,y;
  input [1:0]aluOP;
  output reg signed [31:0] result; 
  always @(*)begin
    case(aluOP)
      2'b00: result = x+y;
      2'b01: result = x-y;
      2'b10: result = x|y;
      2'b11:begin 
        if (x==y)
          result =0;
        else if(x > y)
          result = 1;
         else
           result =-1;
      end
    endcase
  end
endmodule
