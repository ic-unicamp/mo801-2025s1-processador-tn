module core( // modulo de um core
  input clk, // clock
  input resetn, // reset que ativa em zero
  output reg [31:0] address, // endereço de saída - pc
  output reg [31:0] data_out, // dado de saída
  input [31:0] data_in, // dado de entrada
  output reg we // write enable
);

// ===== Variáveis da alu =====
wire [31:0] alu_true_result;
reg [31:0] aluResult;
reg [3:0] aluControl;
reg [31:0] srcA, srcB;

// ===== Instância da ALU =====
ALU alu_instance (
  .aluControl(aluControl),
  .srcA(srcA),
  .srcB(srcB),
  .aluResult(alu_true_result)
);

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

reg [7:0] state = FETCH; // estado
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
parameter SLTIU_1         = 8'b00100100;
parameter SRLI_1          = 8'b00100101;
parameter ORI_1           = 8'b00100110;
parameter ANDI_1          = 8'b00100111;
parameter SRA_1           = 8'b00101000;
parameter SRAI_1          = 8'b00101001;
parameter JALR_1          = 8'b00101010; 
parameter JALR_2          = 8'b00101011; 
parameter LB_1            = 8'b00101100; 
parameter LB_2            = 8'b00101101; 
parameter LB_3            = 8'b00101110; 
parameter LH_1            = 8'b00101111; 
parameter LH_2            = 8'b00110000; 
parameter LH_3            = 8'b00110001; 
parameter LHU_1           = 8'b00110010; 
parameter LHU_2           = 8'b00110011; 
parameter LHU_3           = 8'b00110100; 
parameter LBU_1           = 8'b00110101; 
parameter LBU_2           = 8'b00110110; 
parameter LBU_3           = 8'b00110111;
parameter SB_1            = 8'b00111000;
parameter SB_2            = 8'b00111001;
parameter SB_3            = 8'b00111010;
parameter SH_1            = 8'b00111011;
parameter SH_2            = 8'b00111100;
parameter SH_3            = 8'b00111101;
parameter BLTU_1          = 8'b00111110;
parameter BGEU_1          = 8'b00111111;


// ===== Constantes de opcode =====
parameter ADDI     = 7'b0010011;
parameter ADD_SUB  = 7'b0110011;
parameter SW       = 7'b0100011;
parameter LW       = 7'b0000011;
parameter BEQ_BNE  = 7'b1100011;
parameter NOP      = 7'b1111111;
parameter JAL      = 7'b1101111;
parameter SLL      = 7'b0110011;
parameter LUI      = 7'b0110111;
parameter AUIPC    = 7'b0010111;
parameter SLT      = 7'b0110011;
parameter JALR     = 7'b1100111;
parameter SYS_CALL = 7'b1110011;

// ===== Constantes de controle da alu =====

parameter ALU_ADD = 4'b0000;
parameter ALU_SUB = 4'b0001;
parameter ALU_AND = 4'b0010;
parameter ALU_RA  = 4'b0011;
parameter ALU_OR  = 4'b0100;
parameter ALU_XOR = 4'b0101;
parameter ALU_LS  = 4'b0110;
parameter ALU_RS  = 4'b0111;
parameter ALU_EQ  = 4'b1000;
parameter ALU_NEQ = 4'b1001;
parameter ALU_LT  = 4'b1010;
parameter ALU_LTS = 4'b1011;
parameter ALU_GE  = 4'b1100;
parameter ALU_GES = 4'b1101;

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
wire [31:0] immAUIPC;
assign immAUIPC = {{data_in_reg[31:12]}, 12'b000000000000};
wire [11:0] offset;
assign offset = data_in_reg[31:20];

// ===== Temporários =====
reg [31:0] pc = 0;
reg [31:0] next_pc = 4;
reg [4:0]  lw_rd_reg;
reg [31:0] data_in_reg = 31'b00000000;
reg [1:0]  lb_memory_address = 2'b00;
reg [16:0] aux_sb;
reg [31:0] sb_address;
// ===== DEBUG VARIABLES =====
reg print_state  = 1'b0; // variável para saber se deveria-se printar o estado
reg print_decode = 1'b0;
reg print_pc     = 1'b0;
reg print_ebreak = 1'b0;

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
      $display("=== State: %b", state);
    end

    // ===== Unidade de controle =====
    case(state) // máquina de estado
      FETCH: state = DECODE;
      DECODE: begin // ler decodifica a instrução
        if(print_pc)
          $display("=== PC: %b %d %d", pc, pc, pc/4);
        if(print_decode) begin
          $display("=== decoding instruction %b (%d) address: %d", opcode, opcode, address);
        end
        case(opcode)
          NOP:  state = FETCH;
          ADDI:
            case (data_in[14:12])
              3'b000: state =  ADDI_1;
              3'b001: state =  SLLI_1;
              3'b010: state =  SLTI_1;
              3'b011: state = SLTIU_1;
              3'b100: state =  XORI_1;
              3'b101: 
                if(data_in[30] == 0) state =  SRLI_1;
                else state =  SRAI_1;
              3'b110: state =   ORI_1;
              3'b111: state =  ANDI_1;
            endcase 
          ADD_SUB: begin
            case(data_in[14:12])
              3'b000: 
                if(data_in[30]) state = SUB_1;
                else state = ADD_1;
              3'b001: state =  SLL_1;
              3'b100: state =  XOR_1;
              3'b010: state =  SLT_1;
              3'b011: state = SLTU_1;
              3'b101: 
                if(data_in[30] == 0) state =  SRL_1;
                else state =  SRA_1;
              3'b110: state =   OR_1;
              3'b111: state =  AND_1;
            endcase
          end
          LW: case (data_in[14:12])
              3'b000: state = LB_1;
              3'b001: state = LH_1;
              3'b010: state = LW_1;
              3'b100: state = LBU_1;
              3'b101: state = LHU_1;
            endcase
          SW: case (data_in[14:12])
              3'b000: state = SB_1;
              3'b001: state = SH_1;
              3'b010: state = SW_1;
            endcase
          LUI: state   = LUI_1;
          BEQ_BNE: 
          case(data_in[14:12])
            3'b000: state = BEQ_1;
            3'b001: state = BNE_1;
            3'b100: state = BLT_1;
            3'b101: state = BGE_1;
            3'b110: state = BLTU_1;
            3'b111: state = BGEU_1;

          endcase
          JAL: state   = JAL_1;
          JALR:state   = JALR_1;

          AUIPC: state = AUIPC_1;

          SYS_CALL: begin
            if(print_ebreak)
              $display("=== EBREAK REACHED");
            $finish(); // ONLY IMPLEMENTED EBREAK
          end
          default: begin
            $display("=== ERROR: NOT SUPPORTED INSTRUCTION");
            $finish;
          end
        endcase
      end

      // ===== Add/Sub =====
      ADDI_1 : state = ALU_RESULT;
      SRAI_1 : state = ALU_RESULT;
      SLTI_1 : state = ALU_RESULT;
      SLTIU_1: state = ALU_RESULT;
      SLLI_1 : state = ALU_RESULT;
      SRLI_1 : state = ALU_RESULT;
      ORI_1  : state = ALU_RESULT;
      XORI_1 : state = ALU_RESULT;
      ANDI_1 : state = ALU_RESULT;
      AUIPC_1: state = ALU_RESULT;

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

      ALU_RESULT: begin
        state = FETCH;
        pc = next_pc;
      end

      // ===== LW =====
      LW_1: state = LW_2;
      LW_2: begin
        lw_rd_reg = rd;
        state = LW_3;
      end
      LW_3: begin
        state = FETCH;
        pc = next_pc;
      end

      LB_1: begin
        state = LB_2;
        lw_rd_reg = rd;
      end
      LB_2: state = LB_3;
      LB_3: begin
        state = FETCH;
        pc = next_pc;
      end
      LH_1: begin
        state = LH_2;
        lw_rd_reg = rd;
      end
      LH_2: state = LH_3;
      LH_3: begin
        state = FETCH;
        pc = next_pc;
      end
      LBU_1: begin
        state = LBU_2;
        lw_rd_reg = rd;
      end
      LBU_2: state = LBU_3;
      LBU_3: begin
        state = FETCH;
        pc = next_pc;
      end
      LHU_1: begin
        state = LHU_2;
        lw_rd_reg = rd;
      end
      LHU_2: state = LHU_3;
      LHU_3: begin
        state = FETCH;
        pc = next_pc;
      end


      // ===== SW =====
      SW_1: state = SW_2;
      SW_2: state = SW_3;
      SW_3: begin
        state = FETCH;
        pc = next_pc;
      end

      SB_1: begin
        state = SB_2;
        lb_memory_address = aluResult;
      end
      SB_2: state = SB_3;
      SB_3: begin
        state = FETCH;
        pc = next_pc;
      end
      SH_1: begin
        state = SH_2;
        lb_memory_address = aluResult;
      end
      SH_2: state = SH_3;
      SH_3: begin
        state = FETCH;
        pc = next_pc;
      end

      LUI_1: begin
        state = FETCH;
        pc = next_pc;
      end

      // ===== BRANCHS =====
      BNE_1, BEQ_1, BLT_1, BGE_1, BLTU_1, BGEU_1: begin
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
        pc = alu_true_result;
        state = FETCH;
      end

      JALR_1: begin
        state = JALR_2;
      end
      JALR_2: begin
        state = FETCH;
        pc = alu_true_result;
      end

      default: begin
        // Estado inválido (nunca deve acontecer)
        state = FETCH;
        $display("=== ERROR: DEFAULT CORE STATE REACHED");
        $finish;
      end
    endcase
  end
end

always @(*) begin
  // DEFAULT VALUES
  we         =  1'b0;
  reg_we     =  1'b0;

  address    = pc;
  next_pc    = pc + 4;
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
      srcA = reg_out_1; //imm
      srcB = immADDI;
      aluControl = ALU_LS;
    end
    SRLI_1: begin
      srcA = reg_out_1; //imm
      srcB = immADDI;
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
    SLTIU_1: begin
      srcA = immADDI; //imm
      srcB = reg_out_1;
      aluControl = ALU_LT;
    end
    SRAI_1: begin
      srcA = reg_out_1; //imm
      srcB = shamt;
      aluControl = ALU_RA;
    end
    ANDI_1: begin
      srcA = immADDI; //imm
      srcB = reg_out_1;
      aluControl = ALU_AND;
    end
    AUIPC_1: begin
      srcA = immAUIPC; 
      srcB = pc;
      aluControl = ALU_ADD;
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
    SLTU_1: begin
      srcA = reg_out_1; //imm
      srcB = reg_out_2;
      aluControl = ALU_LT;
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

    LH_1, LB_1, LHU_1: begin
      srcA = offset;
      srcB = reg_out_1;
      aluControl = ALU_ADD;
    end
    LH_2, LB_2, LHU_2: begin
      address = aluResult;
      lb_memory_address = aluResult[1:0];
    end
    LB_3: begin
      reg_dest = lw_rd_reg;
      reg_we = 1;
      case (lb_memory_address)
        2'b00: reg_in = {{24{data_in_reg[7]}}, data_in_reg[7:0]};
        2'b01: reg_in = {{24{data_in_reg[15]}}, data_in_reg[15:7]};
        2'b10: reg_in = {{24{data_in_reg[23]}}, data_in_reg[23:16]};
        2'b11: reg_in = {{24{data_in_reg[31]}}, data_in_reg[31:24]};
      endcase
    end
    LBU_3: begin
      reg_dest = lw_rd_reg;
      reg_we = 1;
      case (lb_memory_address)
        2'b00: reg_in = data_in_reg[7:0];
        2'b01: reg_in = data_in_reg[15:8];
        2'b10: reg_in = data_in_reg[23:16];
        2'b11: reg_in = data_in_reg[31:24];
      endcase
    end
    LH_3: begin
      reg_dest = lw_rd_reg;
      reg_we = 1;
      if(lb_memory_address[1] == 1'b0)
        reg_in = {{16{data_in_reg[15]}}, data_in_reg[15:0]};
      else
        reg_in = {{16{data_in_reg[31]}}, data_in_reg[31:16]};
    end
    LHU_3: begin
      reg_dest = lw_rd_reg;
      reg_we = 1;
      if(lb_memory_address[1] == 1'b0)
        reg_in = {16'b0000000000000000, data_in_reg[15:0]};
      else
        reg_in = {16'b0000000000000000, data_in_reg[31:16]};
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
    SB_1: begin
      aux_sb = reg_out_2[7:0];
      srcA = immS;
      srcB = reg_out_1;
      aluControl = ALU_ADD; // aluResult = immS + rs1
    end
    SB_2: begin
      address = aluResult;
      sb_address = aluResult;
    end
    SB_3: begin
      address = sb_address;
      case(lb_memory_address)
        2'b00: data_out = {data_in_reg[31:8],aux_sb[7:0]};
        2'b01: data_out = {data_in_reg[31:16], aux_sb[7:0], data_in_reg[7:0]};
        2'b10: data_out = {data_in_reg[31:24],aux_sb[7:0], data_in_reg[16:0] };
        2'b11: data_out = {aux_sb[7:0], data_in_reg[23:0]};
      endcase
      we = 1;
    end

    SH_1: begin
      aux_sb = reg_out_2[15:0];
      srcA = immS;
      srcB = reg_out_1;
      aluControl = ALU_ADD;
    end
    SH_2: begin
      address = aluResult;
      sb_address = aluResult;
    end
    SH_3: begin
      address = sb_address;
      if(lb_memory_address[1] == 1'b0)
        data_out = {data_in_reg[31:15], aux_sb};
      else
        data_out = {aux_sb, data_in_reg[15:0]};
      we = 1;
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
      aluControl = ALU_LTS;
    end
    // ===== BRE =====
    BGE_1: begin
      srcA = reg_out_1;
      srcB = reg_out_2;
      aluControl = ALU_GES;
    end
    BLTU_1: begin
      srcA = reg_out_1;
      srcB = reg_out_2;
      aluControl = ALU_LT;
    end
    BGEU_1: begin
      srcA = reg_out_1;
      srcB = reg_out_2;
      aluControl = ALU_GE;
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
    end

    JALR_1: begin
      srcA = pc;
      srcB = 4;
      aluControl = ALU_ADD;
    end

    JALR_2: begin
      reg_in = aluResult;
      reg_dest = rd;
      reg_we = 1;
      srcA = offset;
      srcB = reg_out_1;
      aluControl = ALU_ADD;
    end
  endcase
end

endmodule;