module core( // modulo de um core
  input clk, // clock
  input resetn, // reset que ativa em zero
  output reg [31:0] address, // endereço de saída - pc
  output reg [31:0] data_out, // dado de saída
  input [31:0] data_in, // dado de entrada
  output reg we // write enable
);
// ===== Variáveis da alu =====
wire [31:0] aluResult;
reg [2:0] aluControl;
reg [31:0] srcA, srcB;

// ===== Temporários para acesso a memória(LW) =====
reg [31:0] tempPC;
reg [31:0] temp_data_in; 

// ===== Instância da ALU =====
ALU alu_instance (
  .aluControl(aluControl),
  .srcA(srcA),
  .srcB(srcB),
  .aluResult(aluResult)
);

reg [7:0] state = 8'b00000000; // estado
reg [6:0] opt; // guarda a opção
reg [31:0] registers [0:31]; // registradores

// ===== DEBUG VARIABLES =====
reg print_state = 1'b0; // variável para saber se deveria-se printar o estado
reg hard_debug = 1'b0;

// ===== Constantes de estado =====
parameter FETCH       = 8'b00000000;
parameter DECODE      = 8'b00000001;
parameter ADDI_1      = 8'b00000010;
parameter ALU_RESULT  = 8'b00000011;
parameter ADD_1       = 8'b00000100;
parameter SUB_1       = 8'b00000101;
parameter LW_1        = 8'b00000110;
parameter LW_2        = 8'b00000111;
parameter LW_3        = 8'b00001000;
parameter SW_1        = 8'b00001001;
parameter SW_2        = 8'b00001010;
parameter SW_3        = 8'b00001011;


// ===== Constantes de comando =====
parameter ADDI = 7'b0010011;
// ADDI rd, r1, imm
// rd = r1 + imm 
// ADDI_1 => ALU_RESULT
parameter ADD_SUB  = 7'b0110011;
// ADD rd, r1, r2
// rd = r1 + r2
// ADD_1 => ALU_RESULT
// SUB rd, r1, r2
// rd = r1 - r2
// SUB_1 => ALU_RESULT
parameter SW   = 7'b0100011;
// SW rs2,offset(rs1)
// mem[r1 + offset] = r2
// SW_1 => 
parameter LW   = 7'b0000011;
// LW rd,offset(rs1)
// rd = M[offset + rs1]
// LW_1 => LW_2 => LW_3

// ===== Constantes de controle da alu =====
parameter ALU_ADD = 3'b000;
parameter ALU_SUB = 3'b001;
parameter ALU_MUL = 3'b010;
parameter ALU_DIV = 3'b011;

always @(posedge clk) begin
  if (resetn == 1'b0) begin
    address <= 32'h00000000;
  end else begin 
    // ===== Unidade de controle =====

    if (print_state) begin //printa o estado
      $display("State: %h", state);
    end
    
    case(state) // máquina de estado
      FETCH: begin // ler instrução
        we = 0; // faz a memória ler no clock
        state = DECODE;
      end
      DECODE: begin // ler decodifica a instrução
        opt = data_in[6:0]; 
        if(hard_debug)
          $display("decoding instruction %h", opt);
        case(opt)
          ADDI: begin
            state = ADDI_1;
          end
          ADD_SUB: begin
            if( data_in[30] == 1'b0 )
              state = ADD_1;
            else
              state = SUB_1;
          end
          SW: begin
            state = SW_1;
          end
          LW: begin
            state = LW_1;
          end
        endcase
      end
      ADDI_1: begin
        // rd = registers[data_in[19:15]];
        // r1  = registers[data_in[11-7]];
        // imm = data_in[31:20];
        srcA = data_in[31:20]; //imm
        srcB = registers[data_in[19:15]]; //r1
        aluControl = ALU_ADD;
        state = ALU_RESULT;
      end
      ADD_1: begin
        // rd = registers[data_in[11:7]]
        // r1 = registers[data_in[19:15]]
        // r2 = registers[data_in[24:20]]
        srcA = registers[data_in[19:15]]; //r1
        srcB = registers[data_in[24:20]]; //r2
        aluControl = ALU_ADD;
        state = ALU_RESULT;
      end
      SUB_1: begin
        // rd = registers[data_in[11:7]]
        // r1 = registers[data_in[19:15]]
        // r2 = registers[data_in[24:20]]
        srcA = registers[data_in[19:15]]; //r1
        srcB = registers[data_in[24:20]]; //r2
        aluControl = ALU_SUB;
        state = ALU_RESULT;
      end
      ALU_RESULT: begin
        if(data_in[11:7] != 0)
          registers[data_in[11:7]] = aluResult;// rd
        if(hard_debug)
          $display("register[%h]: %d", data_in[11:7], registers[data_in[11:7]]);
        state = FETCH;
        address <= address + 4;
      end
      LW_1: begin
        // offset = data_in[31:20]
        // rd = registers[data_in[11-7]]
        // r1 = registers[data_in[19-15]]
        srcA = data_in[31:20];
        srcB = registers[data_in[19:15]];
        aluControl = ALU_ADD;
        
        state = LW_2;
      end
      LW_2: begin
        tempPC = address; // salvo o PC
        temp_data_in = data_in;
        address[13:2] = aluResult;
        we = 0;
        state = LW_3;
      end
      LW_3: begin
        registers[temp_data_in[11:7]] = data_in;
        $display("Loaded on register %d value %d from position", temp_data_in[11:7], data_in, aluResult);
        state = FETCH;
        address <= tempPC + 4;
      end
      SW_1: begin
        // offset = {data_in[31:25], data_in[11:7]}
        // r1 = registers[data_in[19-15]]
        // r2 = registers[data_in[24-20]]
        srcA = {data_in[31:25], data_in[11:7]};
        srcB = registers[data_in[19-15]];
        aluControl = ALU_ADD;
        
        state = SW_2;
      end
      SW_2: begin
        tempPC = address; // salvo o PC
        address = aluResult;
        $display("Storing on position %d value %d", aluResult, registers[data_in[24:20]]);
        data_out = registers[data_in[24:20]];
        we = 1;
        state = SW_3;
      end
      SW_3: begin
        we = 0;
        state = FETCH;
        address <= tempPC + 4; // devolve o PC
      end
      default: begin
        // Estado inválido (nunca deve acontecer)
        address <= address + 4;
        state <= FETCH;
        $display("ERROR: DEFAULT CORE STATE REACHED");
        $finish;
      end
    endcase
  end
  data_out = 32'h00000000;
end

integer i;
initial begin
  for (i = 0; i < 32; i = i + 1) begin
    registers[i] = 32'h00000000;
  end
end

endmodule;

// ===== ALU =====
module ALU(
  input [2:0] aluControl,
  input [31:0] srcA, 
  input [31:0] srcB,
  output reg [31:0] aluResult
);

// ===== constantes de aluControl =====
parameter ADD = 3'b000;
parameter SUB = 3'b001;
parameter MUL = 3'b010;
parameter DIV = 3'b011;

reg print_alu_resp = 1;

always @(*) begin
  case(aluControl)
    ADD: aluResult = srcA + srcB; // Soma
    SUB: aluResult = srcA - srcB; // Subtração
    MUL: aluResult = srcA * srcB;
    DIV: aluResult = srcA / srcB;
    default: aluResult = 32'h00000000; // Operação inválida
  endcase
  if(print_alu_resp)
    $display("ALU: %d(srcA) %h %d(srcB) = %d(aluResult)", srcA, aluControl, srcB, aluResult);
end

endmodule;