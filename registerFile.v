module RegisterFile(
    input clk,
    input [4:0] r1,
    input [4:0] r2,
    input [4:0] w,
    input [31:0] data_in,
    input we,
    output reg [31:0] data_out1,
    output reg [31:0] data_out2
)

always @(posedge clk)
begin
    if (we)
        registradores[w] <= data_in;
    data_out1 = registradores[r1];
    data_out2 = registradores[r2];
end

endmodule