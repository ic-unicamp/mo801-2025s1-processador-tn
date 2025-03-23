module memory(
  input [31:0] address,
  input [31:0] data_in,
  output reg [31:0] data_out,
  input we
);

reg [31:0] mem[0:1024]; // 16KB de memória
integer i;

always @(address or data_in or we) begin
  if (we) begin
    mem[address] = data_in;
    $display("DATA_IN_MEM : %d", data_in);
    $display("DATA_OUT_MEM: %d", data_out);
  end
  data_out = mem[address[13:2]]; 
  // le do 13 ao 2, ignora os 2 primeiros do address pois esses tem de ser descartados no RISCV
  // Pega os 10 próximos bits (Já que a memória tem 1024 posições, é preciso de 10 bits).
  // Pega o endereço e coloca em data_out, o endereço terá mem[address[13:2]] tem 32 bits
  // basicamente lê da memória que está em address 
end


initial begin
  for (i = 0; i < 1024; i = i + 1) begin
    mem[i] = 32'h00000000;
  end
  $readmemh("memory.mem", mem);
end

endmodule
