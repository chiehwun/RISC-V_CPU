module alu_ctrl(
    input      [2:0]  Funct3,
    input      [6:0]  Funct7,
    input      [2:0]  ALUOP,
    output reg [3:0]  ALUCtrl
);
always @ ( * ) begin
  case(ALUOP)
  0:  ALUCtrl <= {Funct7[5], Funct3[2:0]};
  1:  ALUCtrl <= 4'b0;
  2: begin
    if(Funct3 == 3'b101)
      ALUCtrl <= {Funct7[5], Funct3[2:0]};
    else
      ALUCtrl <= {1'b0, Funct3[2:0]};
  end
  3:  ALUCtrl <= 4'b0;
  4:  ALUCtrl <= 4'b0;
  5:  begin
    if(Funct3 == 3'b0 || Funct3 == 3'b1)
      ALUCtrl <= 4'b1000;
    else if(Funct3 == 3'b100 || Funct3 == 3'b101)
      ALUCtrl <= 4'b0010;
    else if(Funct3 == 3'b110 || Funct3 == 3'b111)
      ALUCtrl <= 4'b0011;
    else
      ALUCtrl <= 4'b0;  // else
  end
  // 7:
  default:  ALUCtrl <= 4'b0;  // default
  endcase
end
endmodule // alu_ctrl

module decoder(
    input      [6:0]  opcode,
    input      [2:0]  Funct3,
    input      [1:0]  alu_out,
    output reg        RegWrite,
    output reg [2:0]  ALUOP,
    output reg [1:0]  D2B,
    output reg        PC2RegSrc,
    output reg        ALUSrc,
    output reg        ALUSrc1,
    output reg        RDSrc,
    output reg        MemRead,
    output reg [3:0]  MemWrite,
    output reg        Mem2Reg,
    output reg [2:0]  ImmType,
    output reg [1:0]  cyc_cnt
);
  always @ ( * ) begin
    ALUSrc1     = 0;
    cyc_cnt     = 0;
    Mem2Reg     = 0;
    MemWrite  = 4'b0;
    case(opcode)
    7'b0110011: begin
      RegWrite  = 1; ALUOP     = 0;     D2B     = 2;
      PC2RegSrc = 0; ALUSrc    = 0;     RDSrc   = 1;
      MemRead   = 0; ImmType   = 0;
    end
    7'b0000011: begin // Load: lw, lb, lh, lbu, lhu
      RegWrite  = 1; ALUOP     = 1;     D2B     = 2;
      PC2RegSrc = 0; ALUSrc    = 1;     RDSrc   = 0;
      MemRead   = 1; Mem2Reg   = 1;
      ImmType   = 0; cyc_cnt   = 1;
      MemWrite  = 4'b0000;
    end
    7'b0010011: begin
      RegWrite  = 1; ALUOP     = 2;     D2B     = 2;
      PC2RegSrc = 0; ALUSrc    = 1;     RDSrc   = 1;
      MemRead   = 0; ImmType   = 0;
    end
    7'b1100111: begin
      RegWrite  = 1; ALUOP     = 3;     D2B     = 0;
      PC2RegSrc = 1; ALUSrc    = 1;     RDSrc   = 0;
      MemRead   = 0; ImmType   = 0;
    end
    7'b0100011: begin   // sw, sb, sh
      RegWrite  = 0; ALUOP     = 4;     D2B     = 2;
      PC2RegSrc = 0; ALUSrc    = 1;     RDSrc   = 0;
      MemRead   = 1; Mem2Reg   = 1;
      ImmType   = 1;
      // if(alu_out == 2'b11)
      //   MemWrite  = 4'b1000;
      // else if(alu_out == 2'b10)
      //   MemWrite  = 4'b0100;
      // else if(alu_out == 2'b01)
      //   MemWrite  = 4'b0010;
      // else // alu_out == 2'b00)
      if(Funct3 == 3'b010)      // sw
        MemWrite  = 4'b1111 << alu_out;
      else if(Funct3 == 3'b000) // sb
        MemWrite  = 4'b0001 << alu_out;
      else if(Funct3 == 3'b001) // sh
        MemWrite  = 4'b0011 << alu_out;
      else
        MemWrite  = 4'b0000;    // idle
    end
    7'b1100011: begin
      RegWrite  = 0; ALUOP     = 5;     D2B     = 3;
      PC2RegSrc = 0; ALUSrc    = 0;     RDSrc   = 0;
      MemRead   = 0; ImmType   = 2;
    end
    7'b0010111: begin
      RegWrite  = 1; ALUOP     = 6;     D2B     = 2;
      PC2RegSrc = 0; ALUSrc    = 1;     RDSrc   = 0;
      MemRead   = 0; ImmType   = 3;
    end
    7'b0110111: begin
      RegWrite  = 1; ALUOP     = 7;     D2B     = 2;
      PC2RegSrc = 0; ALUSrc    = 1;     RDSrc   = 1;
      MemRead   = 1; ImmType   = 3; ALUSrc1   = 1;
    end
    7'b1101111: begin  // JAL
      RegWrite  = 1; ALUOP     = 8;     D2B     = 1;
      PC2RegSrc = 1; ALUSrc    = 0;     RDSrc   = 0;
      MemRead   = 0; ImmType   = 4;
    end
    default: begin
      RegWrite  = 0; ALUOP     = 0;     D2B     = 0;
      PC2RegSrc = 0; ALUSrc    = 0;     RDSrc   = 0;
      MemRead   = 0; Mem2Reg = 0;
      ImmType   = 0;
    end
    endcase
  end

endmodule // decoder

// DELAY_TRIG
module delay_trigger (
  input           clk, rst,
  input     [1:0] cyc_cnt,
  output reg      trigger
);
reg [2:0] counter;
always @ ( posedge rst, posedge clk, cyc_cnt ) begin
  if(rst || counter >= cyc_cnt) begin
    trigger = 1;
    counter = 0;
  end
  else if(cyc_cnt > 0 && counter < cyc_cnt) begin
    trigger = 0;
    counter = counter + 1;
  end
end

endmodule // delay_trigger

module bnch_ctrl (
  input      [31:0]   alu_out,
  input               ZeroFlag,
  input      [1:0]    D2B,
  input      [2:0]    Funct3,
  output reg [1:0]    BranchCtrl
);
always @ ( * ) begin
  if (D2B == 3) begin
    case (Funct3)
      3'b000: BranchCtrl <= (ZeroFlag == 1? 1:2);
      3'b001: BranchCtrl <= (ZeroFlag == 1? 2:1);
      3'b100: BranchCtrl <= (ZeroFlag == 1? 2:1);
      3'b101: BranchCtrl <= (ZeroFlag == 1? 1:2);
      3'b110: BranchCtrl <= (ZeroFlag == 1? 2:1);
      3'b111: BranchCtrl <= (ZeroFlag == 1? 1:2);
      default: BranchCtrl <= 2;
    endcase
  end
  else
    BranchCtrl <= D2B;
end
endmodule // bnch_ctrls

module imm_gen (
  input       [31:0]  instr,
  input       [2:0]   ImmType,
  input       [2:0]   ALUOP,
  output reg  [31:0]  imm
);
always @ ( * ) begin
  case(ImmType)
  0:  imm <= {{20{instr[31]}}, instr[31:20]};
  // <store>
  1:  imm <= {{20{instr[31]}}, instr[31:25], instr[11:7]};
  2:  imm <= {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
  3:  imm <= {instr[31:12], 12'b0};
  4:  imm <= {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
  default: imm <= 32'b0;
  endcase
end
endmodule // imm

module mux3(
    input      [1:0]  BranchCtrl,
    input      [31:0] ALU_out,
    input      [31:0] pc_imm,
    input      [31:0] pc_sel,
    output reg [31:0] pc_in
);
always @ ( * ) begin
  case (BranchCtrl)
    0: pc_in <= ALU_out;
    1: pc_in <= pc_imm;
    2: pc_in <= pc_sel;
    default: pc_in <= pc_sel;
  endcase
end
endmodule // mux3

module mux_add_pc (
  input         PC2RegSrc,
  input  [31:0] pc_out,
  input  [31:0] imm,
  output [31:0] pc_to_reg,
  output [31:0] pc_imm
);
  wire [31:0]   w0;
  wire [31:0]   w1;
  assign w0         = pc_out + imm;
  assign w1         = pc_out + 4;
  assign pc_to_reg  = (PC2RegSrc == 0)? w0 : w1;
  assign pc_imm     = w0;
endmodule // mux_add_pc

module mux_2 (
  input         SEL,
  input  [31:0] IN0,
  input  [31:0] IN1,
  output [31:0] OUT
);
  assign OUT = SEL == 0? IN0:IN1;
endmodule // mux_rdsrc

// MUX_MEM
module mux_mem (
  input       [2:0]   Funct3,
  input       [31:0]  data_out,
  output reg  [31:0]  mem_out
);
  always @ ( * ) begin
    case(Funct3)
    3'b010:   mem_out = data_out;                                 // lw
    3'b000:   mem_out = {{24{data_out[7]}}, data_out[7:0]};      // lb
    3'b001:   mem_out = {{16{data_out[15]}}, data_out[15:0]};     // lh
    3'b100:   mem_out = {24'b0, data_out[7:0]};                   // lbu
    3'b101:   mem_out = {16'b0, data_out[15:0]};                  // lhu
    default:  mem_out = 32'b0;
    endcase
  end
endmodule // mux_mem

// MEM_DATA_SHIFT
module  mem_data_shift(
  input       [4:0]   addr,
  input       [31:0]  rs2_data,
  output reg  [31:0]  data_in
);
always @ ( * ) begin
  data_in = rs2_data << (addr << 3);  // rs2_data << (addr*8)
end
endmodule // MEM_DATA_SHIFT
