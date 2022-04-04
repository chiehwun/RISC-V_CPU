module register_file(
    input             clk, rst,
    input      [4:0]  RS1Addr,
    input      [4:0]  RS2Addr,
    input      [4:0]  RDAddr,
    input      [31:0] DIN,
    input             WEN,  // write enable
    output /*reg*/ [31:0] RS1Data, RS2Data
);
integer i;
reg [31:0]  x[31:0];  // 32-bits register has #32
assign RS1Data = x[RS1Addr];
assign RS2Data = x[RS2Addr];

always @ ( rst ) begin
  if(rst == 1) begin
    x[0]   <= 32'b0;
  end
end

always @ ( negedge clk ) begin
  if(WEN == 1 && RDAddr != 32'b0) begin // prevent JALR bug: $0 cannot be overwritten
    x[RDAddr] <= DIN;
  end
end
endmodule

module register(
  input             clk, rst,
  input      [31:0] reg_in,
  input             WEN,
  output reg [31:0] reg_out
);
reg [31:0] temp;

always @ ( posedge rst, posedge clk, negedge clk, reg_in ) begin
  if(rst == 1) begin
    temp      <= 32'b0;
    reg_out   <= 32'b0;
  end
  else begin
    if(WEN == 1)
      temp      <= reg_in;
    else
      reg_out  <= temp;
  end
end
endmodule
