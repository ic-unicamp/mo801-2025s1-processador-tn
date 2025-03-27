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
reg [3:0] aluControl;
reg [31:0] srcA, srcB;

// ===== Temporários para acesso a memória(LW) =====
reg [31:0] pc = 0;
reg [31:0] temp_data_in; 

// ===== Instância da ALU =====
ALU alu_instance (
  .aluControl(aluControl),
  .srcA(srcA),
  .srcB(srcB),
  .aluResult(aluResult)
);

reg [7:0] state = 8'b00000000; // estado

// ===== wires =====
wire [6:0] opt; // guarda a opção
assign opt = data_in[6:0];
wire [4:0] rd;
assign rd  = data_in[11:7];
wire [4:0] rs1;
assign rs1 = data_in[19:15];
wire [4:0] rs2;
assign rs2 = data_in[24:20];

// ===== Imm wires =====
wire [11:0] immL;
assign immL = data_in[31:20];
wire [11:0] immS;
assign immS = {data_in[31:25], data_in[11:7]};
wire [31:0] immB;
assign immB = {{20{data_in[31]}}, data_in[7], data_in[30:25], data_in[11:8], 1'b0};
wire [31:0]  immJAL;
assign immJAL = {{12{data_in[31]}}, data_in[19:12], data_in[20], data_in[30:21], 1'b0};


/*RegisterFile register_file_instance(
    .clk(clk),
    .r1(rs1),
    .r2(rs2),
    .w(rd),
    .data_in(rd),
    .we(we),
    .data_out1(r),
    .data_out2(rs2)
)*/


reg [31:0] registers [0:31]; // registradores

// ===== DEBUG VARIABLES =====
reg print_state  = 1'b0; // variável para saber se deveria-se printar o estado
reg print_decode = 1'b0;

// ===== Constantes de estado =====
parameter FETCH           = 8'b00000000;
parameter DECODE          = 8'b00000001;
parameter ADDI_1          = 8'b00000010;
parameter ALU_RESULT      = 8'b00000011;
parameter ADD_1           = 8'b00000100;
parameter SUB_1           = 8'b00000101;
parameter LW_1            = 8'b00000110;
parameter LW_2            = 8'b00000111;
parameter LW_3            = 8'b00001000;
//parameter LW_4            = 8'b00001001;
parameter SW_1            = 8'b00001010;
parameter SW_2            = 8'b00001011;
parameter SW_3            = 8'b00001100;
parameter BNE_1           = 8'b00001101;
parameter BEQ_1           = 8'b00001110;
parameter BLT_1           = 8'b00001111;
parameter BLE_1           = 8'b00010000;
parameter BGT_1           = 8'b00010001;
parameter BGE_1           = 8'b00010010;
parameter BRANCH_RESULT_1 = 8'b00010011;
parameter BRANCH_RESULT_2 = 8'b00010100;
parameter AND_1           = 8'b00010101;
parameter XOR_1           = 8'b00010110;
parameter OR_1            = 8'b00010111;
parameter JAL_1           = 8'b00011000;
parameter JAL_2           = 8'b00011001;
parameter SLL_1           = 8'b00011010;
parameter SRL_1           = 8'b00011011;


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
// SW_1 => SW_2 => SW_3
parameter LW   = 7'b0000011;
// LW rd,offset(rs1)
// rd = M[offset + rs1]
// LW_1 => LW_2 => LW_3
parameter BEQ_BNE  = 7'b1100011;
// BEQ r1, r2, offset
// if(r1 == r2) pc += offset
// BNE r1, r2, offset
// if(r1 != r2) pc += offset
parameter NOP      = 7'b1111111;
//No op
parameter JAL      = 7'b1101111;
// JAL r1, offset
// r1 = pc; pc = pc + offset
parameter SLL      = 7'b0110011;
// SLL rd, r1, r2
// rd = r1 << r2
// SRL rd, r1, r2
// rd = r1 >> r2

// ===== Constantes de controle da alu =====
parameter ALU_ADD = 4'b0000;
parameter ALU_SUB = 4'b0001;
parameter ALU_MUL = 4'b0010; // NOT NEEDED FOR CURRENT INSTRUCTION SET
parameter ALU_DIV = 4'b0011; // NOT NEEDED FOR CURRENT INSTRUCTION SET
parameter ALU_AND = 4'b0100;
parameter ALU_OR  = 4'b0101;
parameter ALU_XOR = 4'b0110;
parameter ALU_LS  = 4'b0111;
parameter ALU_RS  = 4'b1000;
parameter ALU_EQ  = 4'b1001;
parameter ALU_NEQ = 4'b1010;
parameter ALU_LT  = 4'b1011;
parameter ALU_LTE = 4'b1100;
parameter ALU_GT  = 4'b1101;
parameter ALU_GTE = 4'b1110;

always @(posedge clk) begin
  if (resetn == 1'b0) begin
    address <= 32'h00000000;
  end else begin 
    // ===== Unidade de controle =====
    if (print_state) begin //printa o estado
      $display("State: %h", state);
    end

    data_out = 32'h00000000; // zera data_out para que pare de dar data para fora
    
    case(state) // máquina de estado
      FETCH: begin // ler instrução
        we = 0; // faz a memória ler no clock
        address <= pc;
        state = DECODE;
      end
      DECODE: begin // ler decodifica a instrução
        if(print_decode)
          $display("decoding instruction %b (%d)", opt, opt);
        case(opt)
          NOP: begin
            state = FETCH;
            pc <= pc + 4;
          end
          ADDI: begin
            state = ADDI_1;
          end
          ADD_SUB: begin
            case(data_in[14:12])
              3'b000: begin
                if( data_in[30]) 
                  state = SUB_1;
                else 
                  state = ADD_1;
              end
              3'b001: begin
                state = SLL_1;
              end
              3'b100: begin
                state = XOR_1;
              end
              3'b101: begin
                state = SRL_1;
              end
              3'b110: begin
                state = OR_1;
              end
              3'b111: begin
                state = AND_1;
              end
            endcase
          end
          SW: begin
            state = SW_1;
          end
          LW: begin
            state = LW_1;
          end
          BEQ_BNE: begin
            if(data_in[12])
              state = BNE_1;
            else
              state = BEQ_1;
          end
          JAL: begin
            state = JAL_1;
          end
          default: begin
            $display("ERROR: NOT SUPPORTED INSTRUCTION");
            $finish;
          end
        endcase
      end

      // ===== Add/Sub =====
      ADDI_1: begin
        // rd = registers[data_in[19:15]];
        // imm = data_in[31:20];
        srcA = data_in[31:20]; //imm
        srcB = registers[rs1]; //r1
        aluControl = ALU_ADD;
        state = ALU_RESULT;
      end
      ADD_1: begin
        srcA = registers[rs1];
        srcB = registers[rs2];
        aluControl = ALU_ADD;
        state = ALU_RESULT;
      end
      SUB_1: begin
        srcA = registers[rs1];
        srcB = registers[rs2];
        aluControl = ALU_SUB;
        state = ALU_RESULT;
      end
      AND_1: begin
        srcA = registers[rs1];
        srcB = registers[rs2];
        aluControl = ALU_AND;
        state = ALU_RESULT;
      end
      XOR_1: begin
        // rd = registers[data_in[11:7]]
        // r1 = registers[data_in[19:15]]
        // r2 = registers[data_in[24:20]]
        srcA = registers[rs1];
        srcB = registers[rs2];
        aluControl = ALU_XOR;
        state = ALU_RESULT;
      end
      OR_1: begin
        // rd = registers[data_in[11:7]]
        // r1 = registers[data_in[19:15]]
        // r2 = registers[data_in[24:20]]
        srcA = registers[rs1];
        srcB = registers[rs2];
        aluControl = ALU_OR;
        state = ALU_RESULT;
      end
      SLL_1: begin
        srcA = registers[rs1];
        srcB = registers[rs2];
        aluControl = ALU_LS;
        state = ALU_RESULT;
      end
      SRL_1: begin
        srcA = registers[rs1];
        srcB = registers[rs2];
        aluControl = ALU_RS;
        state = ALU_RESULT;
      end

      ALU_RESULT: begin
        if(rd != 0)
          registers[rd] = aluResult;
        state = FETCH;
        pc <= pc + 4;
      end

      // ===== LW =====
      LW_1: begin
        // offset = data_in[31:20]
        srcA = immL;
        srcB = rs1;
        aluControl = ALU_ADD;
        
        state = LW_2;
      end
      LW_2: begin
        we = 0;
        address = aluResult;
        state = LW_3;
        temp_data_in = data_in;
      end
      LW_3: begin
        if(rd != 0)
          registers[rd] = data_in;
        $display("Loaded from position %d value %d to register %d", aluResult, data_in, rd);
        state = FETCH;
        pc <= pc + 4;
        address <= 32'h00000000;
      end

      // ===== SW =====
      SW_1: begin
        // offset = {datas_in[31:25], data_in[11:7]}
        srcA = immS;
        srcB = rs1;
        aluControl = ALU_ADD;
        
        state = SW_2;
      end
      SW_2: begin
        address = aluResult; // NÃO FAÇO SHIFT NO STORE
        $display("Storing on position %d value %d", aluResult, registers[data_in[24:20]]);
        data_out = registers[rs2];
        we = 1;
        state = SW_3;
      end
      SW_3: begin
        we = 0;
        state = FETCH;
        pc <= pc + 4; // devolve o PC
      end

      // ===== BNE =====
      BNE_1: begin
        srcA = registers[rs1];
        srcB = registers[rs2];
        aluControl = ALU_NEQ;
        state = BRANCH_RESULT_1;
      end

      // ===== BEQ =====
      BEQ_1: begin
        // r1     = registers[data_in[19:15]]
        // r2     = registers[data_in[24:20]]
        srcA = registers[rs1]; //r1
        srcB = registers[rs2]; //r2
        aluControl = ALU_EQ;
        state = BRANCH_RESULT_1;
      end

      // ===== BLT =====
      BLT_1: begin
        srcA = registers[rs1];
        srcB = registers[rs2];
        aluControl = ALU_LT;
        state = BRANCH_RESULT_1;
      end

      // ===== BLE =====
      BLE_1: begin
        srcA = registers[rs1];
        srcB = registers[rs2];
        aluControl = ALU_LTE;
        state = BRANCH_RESULT_1;
      end

      // ===== BRT =====
      BGT_1: begin
        srcA = registers[rs1];
        srcB = registers[rs2];
        aluControl = ALU_GT;
        state = BRANCH_RESULT_1;
      end

      // ===== BRE =====
      BGE_1: begin
        srcA = registers[rs1];
        srcB = registers[rs2];
        aluControl = ALU_GTE;
        state = BRANCH_RESULT_1;
      end

      BRANCH_RESULT_1: begin
        if(aluResult)begin
          srcA = pc;
          srcB = immB;
          aluControl = ALU_ADD;
          state = BRANCH_RESULT_2;
        end else begin
          pc <= pc + 4;
          state = FETCH; 
        end
      end
      BRANCH_RESULT_2: begin
        pc <= aluResult;
        state = FETCH;
      end

      // ===== JAL =====
      JAL_1: begin
        // offset = {{20{data_in[31]}}, data_in[31], data_in[19:12], data_in[20], data_in[30:21], 0'b0}
        // rd     = registers[data_in[11:7]]
        srcA = immJAL;
        srcB = pc; 
        aluControl = ALU_ADD;
        registers[rd] = pc;
        state = JAL_2;
      end
      JAL_2: begin
        pc <= aluResult;
        state = FETCH;
      end

      default: begin
        // Estado inválido (nunca deve acontecer)
        pc <= pc + 4;
        state <= FETCH;
        $display("ERROR: DEFAULT CORE STATE REACHED");
        $finish;
      end
    endcase
  end
end

integer i;
initial begin
  for (i = 0; i < 32; i = i + 1) begin
    registers[i] = 32'h00000000;
  end
end

endmodule;