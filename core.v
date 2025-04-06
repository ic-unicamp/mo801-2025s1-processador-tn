module core( // modulo de um core
  input clk, // clock
  input resetn, // reset que ativa em zero
  output reg [31:0] address, // endereço de saída - pc
  output reg [31:0] data_out, // dado de saída
  input [31:0] data_in, // dado de entrada
  output reg we // write enable
);

reg lw_rd_reg;
reg [31:0] data_in_reg = 31'b00000000;
// ===== Variáveis da alu =====
wire [31:0] alu_true_result;
reg [31:0] aluResult;
reg [3:0] aluControl;
reg [31:0] srcA, srcB;

// ===== Temporários para acesso a memória(LW) =====
reg [31:0] pc = 0;

// ===== Instância da ALU =====
ALU alu_instance (
  .aluControl(aluControl),
  .srcA(srcA),
  .srcB(srcB),
  .aluResult(alu_true_result)
);

// ===== wires =====
wire [6:0] opcode; // guarda a opção 
assign opcode = data_in_reg[6:0];
wire [4:0] rd;
assign rd  = data_in_reg[11:7];
wire [4:0] rs1;
assign rs1 = data_in_reg[19:15];
wire [4:0] rs2;
assign rs2 = data_in_reg[24:20];
wire [4:0] shamt;
assign shamt = data_in_reg[24:20];

wire [31:0] sra_return;
assign sra_return  = {{5{data_in_reg[31]}}, data_in_reg[31:5]};
wire [31:0] srai_return;
assign srai_return = {shamt[31:27], aluResult[26:0]};

// ===== Imm wires =====
wire [11:0] immL;
assign immL = data_in_reg[31:20];
wire [11:0] immADDI;
assign immADDI = data_in_reg[31:20];
wire [11:0] immS;
assign immS = {data_in_reg[31:25], data_in_reg[11:7]};
wire [31:0] immB;
assign immB = {{20{data_in_reg[31]}}, data_in_reg[7], data_in_reg[30:25], data_in_reg[11:8], 1'b0};
wire [31:0]  immJAL;
assign immJAL = {{12{data_in_reg[31]}}, data_in_reg[19:12], data_in_reg[20], data_in_reg[30:21], 1'b0};
wire [31:0] immLUI;
assign immLUI = {{data_in_reg[31:12]}, 12'b000000000000};

// ===== Register wires =====
wire [4:0] reg_read_1;
assign reg_read_1 = rs1;
wire [4:0] reg_read_2;
assign reg_read_2 = rs2;

// ===== Register inputs =====
reg [31:0] reg_in; 
reg [4:0]  reg_dest;
reg reg_we;

// ===== Register outputs =====
wire [31:0] reg_out_1;
wire [31:0] reg_out_2;

RegisterFile register_file_instance(
    .clk(clk),
    .r1(reg_read_1),
    .r2(reg_read_2),
    .w(reg_dest),
    .data_in(reg_in),
    .we(reg_we),
    .data_out1(reg_out_1),
    .data_out2(reg_out_2)
);



// ===== DEBUG VARIABLES =====
reg print_state  = 1'b1; // variável para saber se deveria-se printar o estado
reg print_decode = 1'b1;
reg print_pc     = 1'b1;

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
parameter AND_1           = 8'b00010101;
parameter XOR_1           = 8'b00010110;
parameter OR_1            = 8'b00010111;
parameter JAL_1           = 8'b00011000;
parameter JAL_2           = 8'b00011001;
parameter SLL_1           = 8'b00011010;
parameter SRL_1           = 8'b00011011;
parameter LUI_1           = 8'b00011101;
parameter AUIPC_1         = 8'b00011110;
parameter SLT_1           = 8'b00011111;
parameter SLTU_1          = 8'b00100000;
parameter SLLI_1          = 8'b00100001;
parameter XORI_1          = 8'b00100010;
parameter SLTI_1          = 8'b00100011;
parameter SLTUI_1         = 8'b00100100;
parameter SRLI_1          = 8'b00100101;
parameter ORI_1           = 8'b00100110;
parameter ANDI_1          = 8'b00100111;
parameter SRA_1           = 8'b00101000;
parameter SRAI_1          = 8'b00101001;


reg [7:0] state = FETCH; // estado

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
parameter LUI      = 7'b0110111;
// LUI rd, imm
// rd = imm << 12
parameter AUIPC    = 7'b0010111;
// AUIPC rd, imm
// rd = pc + imm[31:12] << 12;
parameter SLT      = 7'b0110011;
// SLT rd, rs1, rs2
// rd = rs1 <s rs2
// SLTU rd, rs1, rs2
// rd = rs1 <u rs2

// ===== Constantes de controle da alu =====

parameter ALU_ADD = 4'b0000;
parameter ALU_SUB = 4'b0001;
parameter ALU_AND = 4'b0010;
parameter ALU_RA  = 4'b0011;
parameter ALU_OR  = 4'b0100;
parameter ALU_XOR = 4'b0110;
parameter ALU_LS  = 4'b0111;
parameter ALU_RS  = 4'b0100;
parameter ALU_EQ  = 4'b0101;
parameter ALU_NEQ = 4'b1010;
parameter ALU_LT  = 4'b1011;
parameter ALU_LTS = 4'b1100;
parameter ALU_LTE = 4'b1101;
parameter ALU_GT  = 4'b1110;
parameter ALU_GTE = 4'b1111;

always @(posedge clk) begin
  if (resetn == 1'b0) begin
    pc = 32'h00000000;
    state = FETCH;

    data_in_reg = 32'b00000000;
    aluResult   = 32'b00000000;
  end else begin
    data_in_reg = data_in;
    aluResult   = alu_true_result;

    if (print_state) begin //printa o estado
      $display("State: %b", state);
    end

    // ===== Unidade de controle =====
    case(state) // máquina de estado
      FETCH: state = DECODE;
      DECODE: begin // ler decodifica a instrução
        if(print_pc)
          $display("PC: %b", pc);
        if(print_decode)
          $display("decoding instruction %b (%d) address: %d", opcode, opcode, address);
        case(opcode)
          NOP:  state = FETCH;
          ADDI:
            case (data_in[14:12])
              3'b000: state =  ADDI_1;
              3'b001: state =  SLLI_1;
              3'b100: state =  XORI_1;
              3'b010: state =  SLTI_1;
              3'b010: state = SLTUI_1;
              3'b101: begin
                if(data_in[30] == 0)
                  state =  SRLI_1;
                else
                  state =  SRAI_1;
              end
              3'b110: state =   ORI_1;
              3'b111: state =  ANDI_1;
            endcase 
          ADD_SUB: begin
            case(data_in[14:12])
              3'b000: if( data_in[30]) 
                  state = SUB_1;
                else 
                  state = ADD_1;
              3'b001: state =  SLL_1;
              3'b100: state =  XOR_1;
              3'b010: state =  SLT_1;
              3'b010: begin
                state = SLTU_1;
                $display("SLTU");
              end
              3'b101: begin
                if(data_in[30] == 0)
                  state =  SRL_1;
                else
                  state =  SRA_1;
              end
              3'b110: state =   OR_1;
              3'b111: state =  AND_1;
            endcase
          end
          SW: state = SW_1;
          LW: state = LW_1;
          BEQ_BNE: 
            if(data_in[12])
              state = BNE_1;
            else
              state = BEQ_1;
          JAL: state   = JAL_1;
          LUI: state   = LUI_1;
          AUIPC: state = AUIPC_1;
          default: begin
            $display("ERROR: NOT SUPPORTED INSTRUCTION");
            $finish;
          end
        endcase
      end

      // ===== Add/Sub =====
      ADDI_1: state = ALU_RESULT;
      ADD_1:  state = ALU_RESULT;
      SUB_1:  state = ALU_RESULT;
      AND_1:  state = ALU_RESULT;
      XOR_1:  state = ALU_RESULT;
      OR_1 :  state = ALU_RESULT;
      SLL_1:  state = ALU_RESULT;
      SRL_1:  state = ALU_RESULT;
      SLT_1:  state = ALU_RESULT;
      SLTU_1: state = ALU_RESULT;
      SRA_1:  state = ALU_RESULT;
      SRAI_1: state = ALU_RESULT;


      ALU_RESULT: begin
        state = FETCH;
        pc = pc + 4;
      end

      // ===== LW =====
      LW_1: state = LW_2;
      LW_2: begin
        lw_rd_reg = rd;
        state = LW_3;
      end
      LW_3: begin
        state = FETCH;
        pc = pc + 4;
      end

      // ===== SW =====
      SW_1: state = SW_2;
      SW_2: state = SW_3;
      SW_3: begin
        state = FETCH;
        pc = pc + 4;
      end

      LUI_1: begin
        state = FETCH;
      end

      // ===== BRANCHS =====
      BNE_1, BEQ_1, BLT_1, BLE_1, BGT_1, BGE_1: begin
        if(alu_true_result)begin
          state = BRANCH_RESULT_1;
        end else begin
          state = FETCH;
          pc    = pc + 4;
        end
      end
      BRANCH_RESULT_1: begin
        state = FETCH;
        pc = alu_true_result;
      end

      // ===== JAL =====
      JAL_1: begin
        state = JAL_2;
      end
      JAL_2: begin
        pc = alu_true_result;

        state = FETCH;
      end

      default: begin
        // Estado inválido (nunca deve acontecer)
        state = FETCH;
        $display("ERROR: DEFAULT CORE STATE REACHED");
        $finish;
      end
    endcase
  end
end

always @(*) begin
  // DEFAULT VALUES
  we         =  1'b0;
  reg_we     =  1'b0;

  address    =  pc;
  data_out   = 32'h00000000;

  srcA       = 32'h00000000;
  srcB       = 32'h00000000;
  aluControl =  4'b0000;
  
  reg_in     = 32'h00000000;
  reg_dest   =  5'b00000;

  // ===== Unidade de controle OUT =====
  case(state) // máquina de estado
    FETCH: begin // ler instrução

    end
    DECODE: begin // ler decodifica a instrução
      
    end

    // ===== Add/Sub =====
    ADDI_1: begin
      srcA = immADDI; //imm
      srcB = reg_out_1;
      aluControl = ALU_ADD;
    end
    SLLI_1: begin
      srcA = immADDI; //imm
      srcB = reg_out_1;
      aluControl = ALU_LS;
    end
    SRLI_1: begin
      srcA = immADDI; //imm
      srcB = reg_out_1;
      aluControl = ALU_RS;
    end
    XORI_1: begin
      srcA = immADDI; //imm
      srcB = reg_out_1;
      aluControl = ALU_XOR;
    end
    ORI_1: begin
      srcA = immADDI; //imm
      srcB = reg_out_1;
      aluControl = ALU_OR;
    end
    SLTI_1: begin
      srcA = immADDI; //imm
      srcB = reg_out_1;
      aluControl = ALU_LTS;
    end
    SLTU_1: begin
      srcA = immADDI; //imm
      srcB = reg_out_1;
      aluControl = ALU_LT;
    end
    SRAI_1: begin
      srcA = reg_out_1; //imm
      srcB = shamt;
      aluControl = ALU_RA;
    end

    ADD_1: begin
      srcA = reg_out_1;
      srcB = reg_out_2;
      aluControl = ALU_ADD;
    end
    SUB_1: begin
      srcA = reg_out_1;
      srcB = reg_out_2;
      aluControl = ALU_SUB;
    end
    AND_1: begin
      srcA = reg_out_1;
      srcB = reg_out_2;
      aluControl = ALU_AND;
    end
    XOR_1: begin
      srcA = reg_out_1;
      srcB = reg_out_2;
      aluControl = ALU_XOR;
    end
    OR_1: begin
      srcA = reg_out_1;
      srcB = reg_out_2;
      aluControl = ALU_OR;
    end
    SLL_1: begin
      srcA = reg_out_1;
      srcB = reg_out_2;
      aluControl = ALU_LS;
    end
    SRL_1: begin
      srcA = reg_out_1;
      srcB = reg_out_2;
      aluControl = ALU_RS;
    end
    SLT_1: begin
      srcA = reg_out_1;
      srcB = reg_out_2;
      aluControl = ALU_LTS;
    end
    SRA_1: begin
      srcA = reg_out_1;
      srcB = reg_out_2;
      aluControl = ALU_RA;
    end

    ALU_RESULT: begin
      reg_in   = aluResult;
      reg_dest = rd;
      reg_we   = 1;
    end

    // ===== LW =====
    LW_1: begin
      srcA = immL;
      srcB = rs1;
      aluControl = ALU_ADD;
    end
    LW_2: begin
      we = 0;
      address  = aluResult;
    end
    LW_3: begin
      reg_dest = lw_rd_reg;
      reg_in   = data_in_reg;
      reg_we   = 1;
      // executa 3x por algum motivo
    end

    LUI_1: begin
      reg_dest = rd;
      reg_in   = immLUI;
      reg_we   = 1;
    end

    // ===== SW =====
    SW_1: begin
      srcA = immS;
      srcB = reg_out_1;
      aluControl = ALU_ADD; // aluResult = immS + rs1
    end
    SW_2: begin
      data_out = reg_out_2;
      address = aluResult;
      we = 1;// mem[aluResult] = rs2
    end
    SW_3: begin
      
    end
    // ===== BNE =====
    BNE_1: begin
      srcA = reg_out_1;
      srcB = reg_out_2;
      aluControl = ALU_NEQ;
    end
    // ===== BEQ =====
    BEQ_1: begin
      srcA = reg_out_1;
      srcB = reg_out_2;
      aluControl = ALU_EQ;
    end
    // ===== BLT =====
    BLT_1: begin
      srcA = reg_out_1;
      srcB = reg_out_2;
      aluControl = ALU_LT;
    end
    // ===== BLE =====
    BLE_1: begin
      srcA = reg_out_1;
      srcB = reg_out_2;
      aluControl = ALU_LTE;
    end
    // ===== BRT =====
    BGT_1: begin
      srcA = reg_out_1;
      srcB = reg_out_2;
      aluControl = ALU_GT;
    end
    // ===== BRE =====
    BGE_1: begin
      srcA = reg_out_1;
      srcB = reg_out_2;
      aluControl = ALU_GTE;
    end
    BRANCH_RESULT_1: begin
      srcA = pc;
      srcB = immB;
      aluControl = ALU_ADD;
    end

    // ===== JAL =====
    JAL_1: begin
      srcA = immJAL;
      srcB = pc; 
      aluControl = ALU_ADD;
      reg_in = pc;
      reg_dest = rd;
      reg_we = 1;
      //registers[rd] = pc;
    end
    JAL_2: begin
      reg_we = 0;
    end
  endcase
end

endmodule;