// ===== ALU =====
module ALU(
  input [4:0] aluControl,
  input [31:0] srcA, 
  input [31:0] srcB,
  output reg [31:0] aluResult
);

// ===== constantes de aluControl =====
parameter ADD = 5'b00000;
parameter SUB = 5'b00001;
parameter AND = 5'b00010;
parameter RA  = 5'b00011;
parameter OR  = 5'b00100;
parameter XOR = 5'b00101;
parameter LS  = 5'b00110;
parameter RS  = 5'b00111;
parameter EQ  = 5'b01001;
parameter NEQ = 5'b01010;
parameter LT  = 5'b01011;
parameter LTS = 5'b01101;
parameter GE  = 5'b01111;
parameter GES = 5'b10000; //  TODO - REMOVER NÃO USADOS

reg print_alu_resp = 1'b1;

always @(*) begin
  case(aluControl)
    ADD: aluResult = srcA +  srcB; // Soma
    SUB: aluResult = srcA -  srcB; // Subtração
    AND: aluResult = srcA &  srcB;
    RA : aluResult = $signed(srcA) << srcB;// TODO TERMINAR ISSO
    OR : aluResult = srcA |  srcB;
    XOR: aluResult = srcA ^  srcB;
    LS : aluResult = srcA << srcB;
    RS : aluResult = srcA >> srcB;
    EQ : aluResult = srcA == srcB;
    NEQ: aluResult = srcA != srcB;
    LT : aluResult = srcA <  srcB;
    LTE: aluResult = srcA <= srcB;
    GT : aluResult = srcA >  srcB;
    GTE: aluResult = srcA >= srcB;
    LTS: aluResult = $signed(srcA) < $signed(srcB);
    GTS: aluResult = $signed(srcA) > $signed(srcB); // TODO FALTANDO ESPAÇO
    
    default: aluResult = 32'h00000000; // Operação inválida
  endcase
  if(print_alu_resp)
    $display("ALU: %d(srcA) %h %d(srcB) = %d(aluResult)", $signed(srcA), aluControl, $signed(srcB), $signed(aluResult));

end

endmodule;