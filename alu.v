module pipelined_processor (
    input clk,
    input reset
);
    // Instruction encoding
    // [15:12] opcode, [11:8] rd, [7:4] rs1, [3:0] rs2/imm
    parameter ADD = 4'b0001, SUB = 4'b0010, AND = 4'b0011, LOAD = 4'b0100;

    // Program counter
    reg [7:0] pc;

    // Register file: 16 registers, 8 bits each
    reg [7:0] regfile [0:15];

    // Simple data memory: 256 bytes
    reg [7:0] mem [0:255];

    // Program memory: 256 16-bit instructions
    reg [15:0] imem [0:255];

    // Pipeline registers
    // IF/ID
    reg [15:0] if_id_instr;
    reg [7:0]  if_id_pc;

    // ID/EX
    reg [3:0]  id_ex_opcode;
    reg [3:0]  id_ex_rd, id_ex_rs1, id_ex_rs2;
    reg [7:0]  id_ex_rdata1, id_ex_rdata2;
    reg [7:0]  id_ex_pc;

    // EX/WB
    reg [3:0]  ex_wb_opcode;
    reg [3:0]  ex_wb_rd;
    reg [7:0]  ex_wb_result;
    reg [7:0]  ex_wb_pc;

    // Initialize program and data
    initial begin
        // Example program:
        // ADD R1, R2, R3   (R1 = R2 + R3)
        // SUB R4, R1, R2   (R4 = R1 - R2)
        // AND R5, R4, R3   (R5 = R4 & R3)
        // LOAD R6, [10]    (R6 = mem[10])
        imem[0] = {ADD, 4'd1, 4'd2, 4'd3};
        imem[1] = {SUB, 4'd4, 4'd1, 4'd2};
        imem[2] = {AND, 4'd5, 4'd4, 4'd3};
        imem[3] = {LOAD, 4'd6, 4'd0, 4'd10}; // [rd][dummy][imm(addr)]
        // Register values for testing
        regfile[2] = 8'd7;
        regfile[3] = 8'd4;
        regfile[1] = 0; regfile[4] = 0; regfile[5] = 0; regfile[6] = 0;
        // Memory for LOAD
        mem[10] = 8'hAA;
    end

    // STAGE 1: IF
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc <= 0;
            if_id_instr <= 0;
            if_id_pc <= 0;
        end else begin
            if_id_instr <= imem[pc];
            if_id_pc <= pc;
            pc <= pc + 1;
        end
    end

    // STAGE 2: ID
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            id_ex_opcode <= 0;
            id_ex_rd <= 0;
            id_ex_rs1 <= 0;
            id_ex_rs2 <= 0;
            id_ex_rdata1 <= 0;
            id_ex_rdata2 <= 0;
            id_ex_pc <= 0;
        end else begin
            id_ex_opcode <= if_id_instr[15:12];
            id_ex_rd     <= if_id_instr[11:8];
            id_ex_rs1    <= if_id_instr[7:4];
            id_ex_rs2    <= if_id_instr[3:0];
            id_ex_rdata1 <= regfile[if_id_instr[7:4]];
            id_ex_rdata2 <= regfile[if_id_instr[3:0]];
            id_ex_pc     <= if_id_pc;
        end
    end

    // STAGE 3: EX
    reg [7:0] alu_out;
    always @(*) begin
        case (id_ex_opcode)
            ADD: alu_out = id_ex_rdata1 + id_ex_rdata2;
            SUB: alu_out = id_ex_rdata1 - id_ex_rdata2;
            AND: alu_out = id_ex_rdata1 & id_ex_rdata2;
            LOAD: alu_out = mem[id_ex_rs2]; // [rs2] used as address
            default: alu_out = 0;
        endcase
    end
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ex_wb_opcode <= 0;
            ex_wb_rd <= 0;
            ex_wb_result <= 0;
            ex_wb_pc <= 0;
        end else begin
            ex_wb_opcode <= id_ex_opcode;
            ex_wb_rd     <= id_ex_rd;
            ex_wb_result <= alu_out;
            ex_wb_pc     <= id_ex_pc;
        end
    end

    // STAGE 4: WB
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // nothing
        end else begin
            case (ex_wb_opcode)
                ADD, SUB, AND, LOAD: regfile[ex_wb_rd] <= ex_wb_result;
            endcase
        end
    end

    // Simulation output for each stage
    always @(posedge clk) begin
        $display("IF : PC=%d INSTR=%h", if_id_pc, if_id_instr);
        $display("ID : OPCODE=%b RD=%d RS1=%d RS2=%d RDATA1=%d RDATA2=%d",
            id_ex_opcode, id_ex_rd, id_ex_rs1, id_ex_rs2, id_ex_rdata1, id_ex_rdata2);
        $display("EX : OPCODE=%b RD=%d ALU_OUT=%d", ex_wb_opcode, ex_wb_rd, alu_out);
        $display("WB : RD=%d RESULT=%d", ex_wb_rd, ex_wb_result);
        $display("REGS: R1=%d R2=%d R3=%d R4=%d R5=%d R6=%d", regfile[1], regfile[2], regfile[3], regfile[4], regfile[5], regfile[6]);
        $display("---------------------------------------------------");
    end

endmodule
