module memory(
  input clk,
  input [31:0] address,
  input [31:0] data_in,
  output [31:0] data_out,
  input we
);

reg [31:0] mem[0:1024]; // 16KB de memória

wire [31:0] DEBUG_512;
assign DEBUG_512 = mem[512];

integer i;

assign data_out = mem[address[13:2]];

always @(posedge clk) begin
  if (we) begin
    mem[address[13:2]] = data_in;
  end
end


initial begin
  for (i = 0; i < 1024; i = i + 1) begin
    mem[i] = 32'h00000000;
  end
  $readmemh("memory.mem", mem);
end

endmodule
