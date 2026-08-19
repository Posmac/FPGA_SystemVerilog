`timescale 1ns / 1ps

import constants::*;

// reg_file_src = 2'b00; //what value to save into regfile: 0: ALU, 1: Mem, 2: Pc + 4, 3: Imm

module control_unit_tb;
    //unit in
    logic[ARCHITECTURE_WIDTH - 1: 0] instruction;

    //unit out 
    logic mem_read;
    logic mem_write;

    logic[1:0] reg_file_src;
    logic reg_file_write_en;

    logic[3:0] alu_op;
    logic alu_first_src;
    logic alu_second_src;

    //expected out
    logic expected_mem_read;
    logic expected_mem_write;

    logic[1:0] expected_reg_file_src;
    logic expected_reg_file_write_en;

    logic[3:0] expected_alu_op;
    logic expected_alu_first_src;
    logic expected_alu_second_src;

    Control_Unit unit(
        .instruction(instruction),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .reg_file_src(reg_file_src),
        .reg_file_write_en(reg_file_write_en),
        .alu_op(alu_op),
        .alu_first_src(alu_first_src),
        .alu_second_src(alu_second_src)
    );

    int random_op = 0;
    int error_count = 0;
    int test_count = 0;
    int r_coverage[10];
    int ri_coverage[9];
    int iload_coverage[5];
    int store_coverage[3];
    int branch_coverage[6];

    task check_result(string test_name);
            begin
                test_count++;
                if (mem_read !== expected_mem_read) begin
                    error_count++;
                    $error("INSTR = %b, mem_read: %b, expected: %b", instruction, mem_read, expected_mem_read);
                end
                if (mem_write !== expected_mem_write) begin
                    error_count++;
                    $error("INSTR = %b, mem_write: %b, expected: %b", instruction, mem_write, expected_mem_write);
                end
                if (reg_file_src !== expected_reg_file_src) begin
                    error_count++;
                    $error("INSTR = %b, reg_file_src: %b, expected: %b", instruction, reg_file_src, expected_reg_file_src);
                end
                if (reg_file_write_en !== expected_reg_file_write_en) begin
                    error_count++;
                    $error("INSTR = %b, reg_file_write_en: %b, expected: %b", instruction, reg_file_write_en, expected_reg_file_write_en);
                end
                if (alu_op !== expected_alu_op) begin
                    error_count++;
                    $error("INSTR = %b, alu_op: %b, expected: %b", instruction, alu_op, expected_alu_op);
                end
                if (alu_first_src !== expected_alu_first_src) begin
                    error_count++;
                    $error("INSTR = %b, alu_first_src: %b, expected: %b", instruction, alu_first_src, expected_alu_first_src);
                end
                if (alu_second_src !== expected_alu_second_src) begin
                    error_count++;
                    $error("INSTR = %b, alu_second_src: %b, expected: %b", instruction, alu_second_src, expected_alu_second_src);
                end
            end        
    endtask

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, unit);

    $display("---------------------------------------");
    $display("SYSTEM TEST FOR 32 bit Control Unit");
	$display("---------------------------------------");

    #10;
    $display("---------------------------------------");
    $display("R-type Start");
	$display("---------------------------------------");
    //R type
    // rd = rs1 XX rs2
    // 7'b0110011: begin
    repeat (1000000) begin
        instruction = '0;
        instruction[6:0] = 7'b0110011;

        random_op = $urandom() % 10;
        r_coverage[random_op]++;

        unique case (random_op) 
            0: begin //add
                instruction[14:12] = 3'd0;
                instruction[31:25] = 7'h00;
                expected_alu_op = 4'b0000;
            end
            1: begin //sub
                instruction[14:12] = 3'd0;
                instruction[31:25] = 7'h20;
                expected_alu_op = 4'b1000;
            end
            2: begin //xor
                instruction[14:12] = 3'd4;
                instruction[31:25] = 7'h00;
                expected_alu_op = 4'b0100;
            end
            3: begin //or
                instruction[14:12] = 3'd6;
                instruction[31:25] = 7'h00;
                expected_alu_op = 4'b0110;
            end
            4: begin //and
                instruction[14:12] = 3'd7;
                instruction[31:25] = 7'h00;
                expected_alu_op = 4'b0111;
            end
            5: begin //sll
                instruction[14:12] = 3'd1;
                instruction[31:25] = 7'h00;
                expected_alu_op = 4'b0001;
            end
            6: begin //srl
                instruction[14:12] = 3'd5;
                instruction[31:25] = 7'h00;
                expected_alu_op = 4'b0101;
            end
            7: begin //sra
                instruction[14:12] = 3'd5;
                instruction[31:25] = 7'h20;
                expected_alu_op = 4'b1101;
            end
            8: begin //slt
                instruction[14:12] = 3'd2;
                instruction[31:25] = 7'h00;
                expected_alu_op = 4'b010;
            end
            9: begin //sltu
                instruction[14:12] = 3'd3;
                instruction[31:25] = 7'h00;
                expected_alu_op = 4'b011;
            end
        endcase
       
        expected_mem_read = 1'b0;
        expected_mem_write = 1'b0;

        expected_reg_file_src = 2'b00; //rd = ALU result
        expected_reg_file_write_en = 1'b1;

        expected_alu_first_src = 1'b0; //0: rs1, 1: pc
        expected_alu_second_src = 1'b0; //0: rs2, 2: imm

        #10;
        check_result("R-type TEST");
    end

    foreach(r_coverage[i])
        $display("Op %0d: %0d", i, r_coverage[i]);

    $display("---------------------------------------");
    $display("R-type Success");
	$display("---------------------------------------");


    #10;
    $display("---------------------------------------");
    $display("I-type Start");
	$display("---------------------------------------");
    //I type (addi)
    // rd = rs1 XX imm
    // 7'b0010011: begin
    repeat (1000000) begin
        instruction = '0;
        instruction[6:0] = 7'b0010011;

        random_op = $urandom() % 9;
        ri_coverage[random_op]++;

        unique case (random_op) 
            0: begin //add
                instruction[14:12] = 3'd0;
                instruction[31:25] = 7'h00;
                expected_alu_op = 4'b0000;
            end
            1: begin //xor
                instruction[14:12] = 3'd4;
                instruction[31:25] = 7'h00;
                expected_alu_op = 4'b0100;
            end
            2: begin //or
                instruction[14:12] = 3'd6;
                instruction[31:25] = 7'h00;
                expected_alu_op = 4'b0110;
            end
            3: begin //and
                instruction[14:12] = 3'd7;
                instruction[31:25] = 7'h00;
                expected_alu_op = 4'b0111;
            end
            4: begin //sll
                instruction[14:12] = 3'd1;
                instruction[31:25] = 7'h00;
                expected_alu_op = 4'b0001;
            end
            5: begin //srl
                instruction[14:12] = 3'd5;
                instruction[31:25] = 7'h00;
                expected_alu_op = 4'b0101;
            end
            6: begin //sra
                instruction[14:12] = 3'd5;
                instruction[31:25] = 7'h20;
                expected_alu_op = 4'b1101;
            end
            7: begin //slt
                instruction[14:12] = 3'd2;
                instruction[31:25] = 7'h00;
                expected_alu_op = 4'b010;
            end
            8: begin //sltu
                instruction[14:12] = 3'd3;
                instruction[31:25] = 7'h00;
                expected_alu_op = 4'b011;
            end
        endcase
       
        expected_mem_read = 1'b0;
        expected_mem_write = 1'b0;

        expected_reg_file_src = 2'b00; //rd = ALU result
        expected_reg_file_write_en = 1'b1;

        expected_alu_first_src = 1'b0; //0: rs1, 1: pc
        expected_alu_second_src = 1'b1; //0: rs2, 2: imm

        #10;
        check_result("I-type TEST");
    end

    foreach(ri_coverage[i])
        $display("Op %0d: %0d", i, ri_coverage[i]);

    $display("---------------------------------------");
    $display("I-type Success");
	$display("---------------------------------------");
    
    #10;
    $display("---------------------------------------");
    $display("I(load)-type Start");
	$display("---------------------------------------");
    //I type (load from memory to regfile) 
    //rd = M[rs1+imm][0:7]
    // 7'b0000011: begin
    repeat (1000000) begin
        instruction = '0;
        instruction[6:0] = 7'b0000011;

        random_op = $urandom() % 5;
        iload_coverage[random_op]++;
        expected_alu_op = 4'b0000; //add

        unique case (random_op) 
            0: begin //lb
                instruction[14:12] = 3'd0;
                instruction[31:25] = 7'h00;
            end
            1: begin //lh
                instruction[14:12] = 3'd1;
                instruction[31:25] = 7'h00;
            end
            2: begin //lw
                instruction[14:12] = 3'd2;
                instruction[31:25] = 7'h00;
            end
            3: begin //lbu
                instruction[14:12] = 3'd4;
                instruction[31:25] = 7'h00;
            end
            4: begin //lhu
                instruction[14:12] = 3'd5;
                instruction[31:25] = 7'h00;
            end
        endcase

        expected_mem_read = 1'b1;
        expected_mem_write = 1'b0;

        expected_reg_file_src = 2'b01; //rd = MEM read
        expected_reg_file_write_en = 1'b1;

        expected_alu_first_src = 1'b0; //0: rs1, 1: pc
        expected_alu_second_src = 1'b1; //0: rs2, 2: imm

        #10;
        check_result("I(load)-type TEST");
    end

    foreach(iload_coverage[i])
        $display("Op %0d: %0d", i, iload_coverage[i]);

    $display("---------------------------------------");
    $display("I(load)-type Success");
	$display("---------------------------------------");

    #10;
    $display("---------------------------------------");
    $display("S-type Start");
	$display("---------------------------------------");
    //S type (store into memory from alu)
    //M[rs1+imm][0:7] = rs2[0:7]
    // 7'b0100011: begin
    repeat (1000000) begin
        instruction = '0;
        instruction[6:0] = 7'b0100011;

        random_op = $urandom() % 3;
        store_coverage[random_op]++;
        expected_alu_op = 4'b0000; //add

        unique case (random_op) 
            0: begin //sb
                instruction[14:12] = 3'd0;
                instruction[31:25] = 7'h00;
            end
            1: begin //sh
                instruction[14:12] = 3'd1;
                instruction[31:25] = 7'h00;
            end
            2: begin //sw
                instruction[14:12] = 3'd2;
                instruction[31:25] = 7'h00;
            end
        endcase

        expected_mem_read = 1'b0;
        expected_mem_write = 1'b1;

        expected_reg_file_src = 2'b00; //dont care
        expected_reg_file_write_en = 1'b0;

        expected_alu_first_src = 1'b0; //0: rs1, 1: pc
        expected_alu_second_src = 1'b1; //0: rs2, 2: imm

        #10;
        check_result("S-type TEST");
    end

    foreach(store_coverage[i])
        $display("Op %0d: %0d", i, store_coverage[i]);

    $display("---------------------------------------");
    $display("S-type Success");
	$display("---------------------------------------");


    #10;
    $display("---------------------------------------");
    $display("B-type Start");
	$display("---------------------------------------");
    // B type (branch)
    // if(rs1 == rs2) PC += imm
    // 7'b1100011: begin
    repeat (1000000) begin
        instruction = '0;
        instruction[6:0] = 7'b1100011;

        random_op = $urandom() % 6;
        branch_coverage[random_op]++;
        expected_alu_op = 4'b0000; //add

        unique case (random_op) 
            0: begin //beq
                instruction[14:12] = 3'd0;
                instruction[31:25] = 7'h00;
            end
            1: begin //bne
                instruction[14:12] = 3'd1;
                instruction[31:25] = 7'h00;
            end
            2: begin //blt
                instruction[14:12] = 3'd4;
                instruction[31:25] = 7'h00;
            end
            3: begin //bge
                instruction[14:12] = 3'd5;
                instruction[31:25] = 7'h00;
            end
            4: begin //bltu
                instruction[14:12] = 3'd6;
                instruction[31:25] = 7'h00;
            end
            5: begin //bgeu
                instruction[14:12] = 3'd7;
                instruction[31:25] = 7'h00;
            end
        endcase

        expected_mem_read = 1'b0;
        expected_mem_write = 1'b0;

        expected_reg_file_src = 2'b00; //ALU out
        expected_reg_file_write_en = 1'b0; //dont save

        expected_alu_first_src = 1'b0; //0: rs1, 1: pc
        expected_alu_second_src = 1'b0; //0: rs2, 2: imm

        #10;
        check_result("B-type TEST");
    end

    foreach(branch_coverage[i])
        $display("Op %0d: %0d", i, branch_coverage[i]);

    $display("---------------------------------------");
    $display("B-type Success");
	$display("---------------------------------------");

    #10;
    $display("---------------------------------------");
    $display("J_and_L-type Start");
	$display("---------------------------------------");
    //J and Link 
    //rd = PC+4; PC += imm
    // 7'b1101111: begin
    instruction = '0;
    instruction[6:0] = 7'b1101111;
    expected_alu_op = 4'b0000; //dont care

    expected_mem_read = 1'b0; //no
    expected_mem_write = 1'b0; //no

    expected_reg_file_src = 2'b10; //PC+4 out from PC
    expected_reg_file_write_en = 1'b1; //save

    expected_alu_first_src = 1'b0; //0: rs1, 1: pc
    expected_alu_second_src = 1'b0; //0: rs2, 2: imm

    #10;
    check_result("J_and_L-type TEST");

    $display("---------------------------------------");
    $display("J_and_L-type Success");
	$display("---------------------------------------");

    #10;
    $display("---------------------------------------");
    $display("J_and_L_reg-type Start");
	$display("---------------------------------------");
    
    // J and Link reg
    // rd = PC+4; PC = rs1 + imm
    // 7'b1100111: begin 
    instruction = '0;
    instruction[6:0] = 7'b1100111;
    expected_alu_op = 4'b0000; //dont care

    expected_mem_read = 1'b0; //no
    expected_mem_write = 1'b0; //no

    expected_reg_file_src = 2'b10; //PC+4 out from PC
    expected_reg_file_write_en = 1'b1; //save

    expected_alu_first_src = 1'b0; //0: rs1, 1: pc
    expected_alu_second_src = 1'b0; //0: rs2, 2: imm

    #10;
    check_result("J_and_L_reg-type TEST");

    $display("---------------------------------------");
    $display("J_and_L_reg-type Success");
	$display("---------------------------------------");

    #10;
    $display("---------------------------------------");
    $display("U-type Start");
	$display("---------------------------------------");
    
    // U load upper imm
    // rd = imm << 12
    // 7'b0110111: begin
    instruction = '0;
    instruction[6:0] = 7'b0110111;
    expected_alu_op = 4'b0000; //dont care

    expected_mem_read = 1'b0; //no
    expected_mem_write = 1'b0; //no

    expected_reg_file_src = 2'b11; //imm
    expected_reg_file_write_en = 1'b1; //save

    expected_alu_first_src = 1'b0; //0: rs1, 1: pc
    expected_alu_second_src = 1'b0; //0: rs2, 2: imm

    #10;
    check_result("U-type TEST");

    $display("---------------------------------------");
    $display("U-type Success");
	$display("---------------------------------------");

    
        #10;
    $display("---------------------------------------");
    $display("U_IMM_-type Start");
	$display("---------------------------------------");
    
    //U add upper imm to reg
    //rd = PC + (imm << 12)
    // 7'b0010111: begin
    instruction = '0;
    instruction[6:0] = 7'b0010111;
    expected_alu_op = 4'b0000; //ADD

    expected_mem_read = 1'b0; //no
    expected_mem_write = 1'b0; //no

    expected_reg_file_src = 2'b00; //alu out
    expected_reg_file_write_en = 1'b1; //save

    expected_alu_first_src = 1'b1; //0: rs1, 1: pc
    expected_alu_second_src = 1'b1; //0: rs2, 2: imm

    #10;
    check_result("U_IMM_-type TEST");

    $display("---------------------------------------");
    $display("U_IMM_-type Success");
	$display("---------------------------------------");

    $display("----------------------------------------------------------------");
    $display(" TESTING COMPLETE!");
    $display(" Total tests run: %0d", test_count);
    if (error_count == 0) begin
        $display(" 🎉 SUCCESS: All tests passed successfully!");
    end else begin
        $display(" ❌ ERROR: Found %0d mismatches!", error_count);
    end
    $display("----------------------------------------------------------------");
    
    $finish;
   end
endmodule
