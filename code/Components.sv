module imm_extender (ext,imm_in,imm_out);
  	input [13:0] imm_in;
    input ext;
  	output reg [31:0] imm_out;

    always @(*) begin
      	if (!ext)
            imm_out = {18'b0, imm_in};
        else
            imm_out = {{18{imm_in[13]}}, imm_in};
    end

endmodule

module Split(
  input [31:0] Inst,
  output reg [5:0] OPCode,
  output reg [3:0] Rd, Rs, Rt,
  output reg [13:0] Imm
);
  always @(*) begin
    OPCode = Inst[31:26];
    Rd     = Inst[25:22];
    Rs     = Inst[21:18];
    Rt     = Inst[17:14];
    Imm    = Inst[13:0];
  end
endmodule
module Comparator32Bit (src,zeroF,negF);
  input [31:0]src;
  output reg zeroF,negF;
  always @(*)begin
    if (src == 0)begin
      zeroF=1;negF=0;end
    else if ($signed(src) < 0)begin
      zeroF=0;negF=1;end
    else begin
      zeroF=0;negF=0;end
  end
endmodule

