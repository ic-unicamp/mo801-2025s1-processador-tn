module RegisterFile(
    input clk,
    input [4:0] r1,
    input [4:0] r2,
    input [4:0] w,
    input [31:0] data_in,
    input we,
    output reg [31:0] data_out1,
    output reg [31:0] data_out2
);
parameter print_reg_write = 1'b0;

reg [31:0] registradores[0:31];
always @(posedge clk)
begin
    if (we && w != 0) begin
        
        registradores[w] <= data_in;
    end
    if(print_reg_write && we)
      $display("r[%d] = %d", w, data_in);
    data_out1 = registradores[r1];
    data_out2 = registradores[r2];
end

integer i;
initial begin
  for (i = 0; i < 32; i = i + 1) begin
    registradores[i] = 32'h00000000;
  end
end

endmodule