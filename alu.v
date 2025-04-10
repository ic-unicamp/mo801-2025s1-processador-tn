// ===== ALU =====
module ALU(
  input [3:0] aluControl,
  input [31:0] srcA, 
  input [31:0] srcB,
  output reg [31:0] aluResult
);

// ===== constantes de aluControl =====
parameter ADD = 4'b0000;
parameter SUB = 4'b0001;
parameter AND = 4'b0010;
parameter RA  = 4'b0011;
parameter OR  = 4'b0100;
parameter XOR = 4'b0101;
parameter LS  = 4'b0110;
parameter RS  = 4'b0111;
parameter EQ  = 4'b1000;
parameter NEQ = 4'b1001;
parameter LT  = 4'b1010;
parameter LTS = 4'b1011;
parameter GE  = 4'b1100;
parameter GES = 4'b1101;

reg print_alu_resp = 1'b1;

always @(*) begin
  case(aluControl)
    ADD: aluResult = srcA +  srcB;
    SUB: aluResult = srcA -  srcB;
    AND: aluResult = srcA &  srcB;
    RA : aluResult = $signed(srcA) << srcB;
    OR : aluResult = srcA |  srcB;
    XOR: aluResult = srcA ^  srcB;
    LS : aluResult = srcA << srcB;
    RS : aluResult = srcA >> srcB;
    EQ : aluResult = srcA == srcB;
    NEQ: aluResult = srcA != srcB;
    LT : aluResult = srcA <  srcB;
    LTS: aluResult = $signed(srcA) < $signed(srcB);
    GE : aluResult = srcA >= srcB;
    GES: aluResult = $signed(srcA) > $signed(srcB); 
    
    default: aluResult = 32'h00000000; // Operação inválida
  endcase
  if(print_alu_resp)
    $display("ALU: %d(srcA) %h %d(srcB) = %d(aluResult)", $signed(srcA), aluControl, $signed(srcB), $signed(aluResult));

end

endmodule;