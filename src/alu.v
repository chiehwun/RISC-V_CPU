module alu(
    input      [31:0] ALU_in1, ALU_in2,
    input      [3:0]  ALU_ctrl,
    output reg        Zero,
    output reg [31:0] ALU_out
);

always @ (ALU_in1 or ALU_in2 or ALU_ctrl) begin
  case(ALU_ctrl)
  4'b0000: ALU_out = $signed(ALU_in1) + $signed(ALU_in2);             //ADD
  4'b1000: ALU_out = ALU_in1 - ALU_in2;                               //SUB
  4'b0001: ALU_out = $unsigned(ALU_in1) << $unsigned(ALU_in2[4:0]);   //SLL
  4'b0010: ALU_out = $signed(ALU_in1) < $signed(ALU_in2)? 1:0;        //SLT
  4'b0011: ALU_out = ALU_in1 < ALU_in2? 1:0;                          //SLTU
  4'b0100: ALU_out = ALU_in1 ^ ALU_in2;                               //XOR
  4'b0101: ALU_out = ALU_in1 >> ALU_in2[4:0];                         //SRL
  4'b1101: ALU_out = $signed(ALU_in1) >>> ALU_in2[4:0];                        //SRA
  4'b0110: ALU_out = ALU_in1 | ALU_in2;                               //OR
  4'b0111: ALU_out = ALU_in1 & ALU_in2;                               //AND
  default: ALU_out = 32'b0;
  endcase
  if(ALU_out == 0)
    Zero = 1;
  else
    Zero = 0;
end
endmodule
