// Please include verilog file if you write module in other file
//`include "register.v"
//`include "alu.v"
//`include "ctrl.v"

module CPU(
    input             clk,
    input             rst,
    input      [31:0] data_out,
    input      [31:0] instr_out,
    output            instr_read,   // 1
    output            data_read,
    output     [31:0] instr_addr,   // pc_out
    output     [31:0] data_addr,
    output /*reg*/ [3:0]  data_write,   // reg
    output /*reg*/ [31:0] data_in       // reg
);
/* Wire declaration */
// program_counter PC
wire [31:0] pc_out;
wire [31:0] pc_in;
// decoder DECODER
wire        RegWrite;
wire [2:0]  ALUOP;
wire        PC2RegSrc;
wire        ALUSrc;
wire        ALUSrc1;
wire        RDSrc;
wire        MemRead;
wire [3:0]  MemWrite;
wire        Mem2Reg;
wire [1:0]  D2B;
wire [1:0]  cyc_cnt;
wire        regwrite_in;
// imm IMM_GEN
wire [2:0]  ImmType;  // input
wire [31:0] imm;      // output
// register_file REG_FILE
wire [31:0] rs1_data;
wire [31:0] rs2_data;
wire [31:0] rd_data;
// register IFID
wire [31:0] instr;    // input
wire [31:0] IFID_WEN;
// alu ALU
wire [3:0]  ALUCtrl;
wire        ZeroFlag;
wire [31:0] alu_out;
// mux_3 MUX3
wire [1:0]  BranchCtrl;
wire [31:0] pc_imm;
// wire [31:0] pc_4;
// mux_2 MUX_PC2REG
wire [31:0] pc_to_reg;
// mux_2 MUX_ALUSRC
wire [31:0] alu_in2;
// mux_2 MUX_ALUSRC1
wire [31:0] alu_in1;
// mux_2 MUX_PCorALUOUT
wire [31:0] pc_or_alu_out;
// mux_2 MUX_MEM2REG
// mux_2 MUX_DELAY
wire        sel_delay;
wire [31:0] pc2mux3;
// mux_mem MUX_MEM
wire [31:0] mem_out;
// SRAM i_DM layout
assign data_read  = MemRead;
assign data_write = MemWrite;
assign data_addr = alu_out;
// SRAM i_IM layout
assign instr_addr = pc_out;
assign instr_read = clk;
assign instr      = instr_out;



register_file REGISTER_FILE(
  .clk      ( clk               ),
  .rst      ( rst               ),
  .RS1Addr  ( instr[19:15]      ),
  .RS2Addr  ( instr[24:20]      ),
  .RDAddr   ( instr[11:7]       ),
  .DIN      ( rd_data           ),
  .WEN      ( RegWrite          ),
  .RS1Data  ( rs1_data          ),   //output
  .RS2Data  ( rs2_data          )    //output
);


register PC(
  .clk      ( clk       ),
  .rst      ( rst       ),
  .WEN      ( clk       ),
  .reg_in   ( pc_in     ),
  .reg_out  ( pc_out    )    // output
);

alu ALU(
  .ALU_in1  ( alu_in1  ),
  .ALU_in2  ( alu_in2   ),
  .ALU_ctrl ( ALUCtrl   ),
  .Zero     ( ZeroFlag  ),    // output
  .ALU_out  ( alu_out   )     // output
);


alu_ctrl ALU_CTRL(
  .Funct3   ( instr[14:12]      ),
  .Funct7   ( instr[31:25]      ),
  .ALUOP    ( ALUOP             ),
  .ALUCtrl  ( ALUCtrl           )   // output
);

decoder DECODER(
  .opcode     ( instr[6:0]        ),  // input
  .Funct3     ( instr[14:12]      ),  // input
  .alu_out    ( alu_out[1:0]      ),
  .RegWrite   ( regwrite_in       ),
  .ALUOP      ( ALUOP             ),
  .D2B        ( D2B               ),
  .PC2RegSrc  ( PC2RegSrc         ),
  .ALUSrc     ( ALUSrc            ),
  .ALUSrc1    ( ALUSrc1           ),
  .RDSrc      ( RDSrc             ),
  .MemRead    ( MemRead           ),
  .MemWrite   ( MemWrite          ),
  .Mem2Reg    ( Mem2Reg           ),
  .ImmType    ( ImmType           ),
  .cyc_cnt    ( cyc_cnt           )
);

delay_trigger DELAY_TRIG(
  .clk      ( clk       ),
  .rst      ( rst       ),
  .cyc_cnt  ( cyc_cnt   ),
  .trigger  ( sel_delay )   // ouput
);

mux_2 MUX_DELAY(
  .SEL  ( sel_delay       ),
  .IN0  ( pc_out          ),  // delay
  .IN1  ( pc_out + 4      ),
  .OUT  ( pc2mux3         )   // ouput
  );

mux_2 MUX_REGWDELAY(
  .SEL  ( cyc_cnt == 0    ),
  .IN0  ( sel_delay       ),  // delay(load)
  .IN1  ( regwrite_in     ),
  .OUT  ( RegWrite        )   // ouput
  );

bnch_ctrl BNCH_CTRL(
  .alu_out    ( alu_out           ),
  .ZeroFlag   ( ZeroFlag          ),
  .D2B        ( D2B               ),
  .Funct3     ( instr[14:12]      ),
  .BranchCtrl ( BranchCtrl        )     // output
);

imm_gen IMM_GEN(
  .instr    ( instr     ),
  .ImmType  ( ImmType   ),
  .imm      ( imm       )           // output
);

mux3 MUX3(
  .BranchCtrl ( BranchCtrl  ),
  .ALU_out    ( alu_out     ),
  .pc_imm     ( pc_imm      ),
  .pc_sel     ( pc2mux3     ),
  .pc_in      ( pc_in       )       // output
);

mux_add_pc MUX_ADD_PC(
  .PC2RegSrc  ( PC2RegSrc   ),
  .pc_out     ( pc_out      ),
  .imm        ( imm         ),
  .pc_imm     ( pc_imm      ),  // output
  .pc_to_reg  ( pc_to_reg   )   // output
);

mux_2 MUX_ALUSRC(
  .SEL  ( ALUSrc    ),
  .IN0  ( rs2_data  ),
  .IN1  ( imm       ),
  .OUT  ( alu_in2   )
);

mux_2 MUX_ALUSRC1(
  .SEL  ( ALUSrc1   ),
  .IN0  ( rs1_data  ),
  .IN1  ( 32'b0     ),
  .OUT  ( alu_in1   )
);

mux_2 MUX_PCorALUOUT(
  .SEL  ( RDSrc         ),
  .IN0  ( pc_to_reg     ),
  .IN1  ( alu_out       ),
  .OUT  ( pc_or_alu_out )
);

mux_2 MUX_MEM2REG(
  .SEL  ( Mem2Reg       ),
  .IN0  ( pc_or_alu_out ),
  .IN1  ( mem_out       ),
  .OUT  ( rd_data       )
);

mux_mem MUX_MEM(
  .Funct3   ( instr[14:12]  ),
  .data_out ( data_out      ),
  .mem_out  ( mem_out       )   // output
);

mem_data_shift MEM_DATA_SHIFT(
  .addr     ( {3'b0, alu_out[1:0]}  ),
  .rs2_data ( rs2_data              ),
  .data_in  ( data_in               )   // output
);
endmodule
