module datapath (
        input  wire        clk,
        input  wire        rst,
        input  wire        branch,
        input  wire        jump,
        input  wire        reg_dst,
        input  wire        we_reg,
        input  wire        alu_src,
        input  wire        dm2reg,
        input wire         jal,
	    input wire         wehi,
        input wire         welo,
        input wire         jr,
        input wire         wb_cntrl,
	    input wire         shift,
        input wire         enable,
        input  wire [3:0]  alu_ctrl,
        input  wire [4:0]  ra3,
        input  wire [31:0] instr,
        input  wire [31:0] rd_dm,
        output wire [31:0] pc_current,
        output wire [31:0] alu_out,
        output wire [31:0] wd_dm,
        output wire [31:0] rd3,
        // -- Lab 8 Signals -- //
        output wire [31:0] instr_to_cu
    );
    wire [31:0] instrr;
    wire [4:0]  rf_wa;
    wire        pc_src;
    wire [31:0] pc_plus4;
    wire [31:0] pc_plus4_out;
    wire [31:0] pc_pre;
    wire [31:0] pc_next;
    wire [31:0] sext_imm;
    wire [31:0] sext_im;
    wire [31:0] alu_to_exmem_reg;
    wire [31:0] ba;
    wire [31:0] bta;
    wire [31:0] jta;
    wire [31:0] alu_pa;
    wire [31:0] alu_pb;
    wire [31:0] alu_p;
    wire [31:0] alu_pp;
    wire [31:0] wd_rf;
    wire [31:0] rf_wd;
    wire [31:0] hilo_reg_out;
    wire        zero;
    wire [31:0] pc_final;
    wire [31:0] shiftamount;
    wire [31:0] shiftamount1;
    wire [31:0] hi;
    wire [31:0] lo;
    wire [31:0] hi_out;
    wire [31:0] lo_out;
    wire [31:0] wd_d;
    wire [31:0] rd;
    wire [31:0] alu_mul_out;
    wire [4:0] wa_rf;
    wire [4:0] wa;
    wire [4:0] wa_r;
    
    // ID/EX Signal Wires //
    wire wb_cntrl1;
    wire jal1;
    wire dm2reg1;
    wire wehi1;
    wire welo1;
    wire wedm1;
    wire alu_ctrl1;
    wire alu_src1;
    wire shift1;
    wire branch1;
    
    // EM/MEM Signal Wires //
    wire wb_cntrl2;
    wire jal2;
    wire dm2reg2;
    wire wehi2;
    wire welo2;
    wire wedm2;
    
    // MEM/WB Signal Wires //
    wire wb_cntrl3;
    wire jal3;
    wire dm2reg3;
    
    assign pc_src = branch1 & zero;
    assign ba = {sext_imm[29:0], 2'b00};
    assign jta = {pc_plus4_out[31:28], instrr[25:0], 2'b00};
    
    // first reg //
    mainreg #(32) intruc_reg(
        .clk (clk),
        .d (instr),
        .q (instr_to_cu) 
    );
    
    // ID/EX Register Signals //
     mainreg #(1) idex_wb_cntrl(
        .clk (clk),
        .d (wb_cntrl),
        .q (wb_cntrl1) 
    );
    
    mainreg #(1) idex_jal(
        .clk (clk),
        .d (jal),
        .q (jal1) 
    );
    
    mainreg #(1) idex_dm2reg(
        .clk (clk),
        .d (dm2reg),
        .q (dm2reg1)
    );
    
     mainreg #(1) idex_we_hi(
        .clk (clk),
        .d (wehi),
        .q (wehi1) 
    );
    
    mainreg #(1) idex_we_lo(
        .clk (clk),
        .d (welo),
        .q (welo1) 
    );
    
    mainreg #(1) idex_alu_ctrl(
        .clk (clk),
        .d (alu_ctrl),
        .q (alu_ctrl1) 
    );
    
    mainreg #(1) idex_alu_src(
        .clk (clk),
        .d (alu_src),
        .q (alu_src1) 
    );
    
    mainreg #(1) idex_shift(
        .clk (clk),
        .d (shift),
        .q (shift1) 
    );
    
    mainreg #(1) idex_branch(
        .clk (clk),
        .d (branch),
        .q (branch1) 
    );
    
     // EX/MEM Register Signals //
     mainreg #(1) exmem_wb_cntrl(
        .clk (clk),
        .d (wb_cntrl1),
        .q (wb_cntrl2) 
    );
    
       mainreg #(1) exmem_jal(
        .clk (clk),
        .d (jal1),
        .q (jal2) 
    );
    
    mainreg #(1) exmem_dm2reg(
        .clk (clk),
        .d (dm2reg1),
        .q (dm2reg2) 
    );
    
    mainreg #(1) exmem_we_hi(
        .clk (clk),
        .d (wehi1),
        .q (wehi2) 
    );
    
    mainreg #(1) exmem_we_lo(
        .clk (clk),
        .d (welo1),
        .q (welo2) 
    );
    
     // MEM/WB Register Signals //
     mainreg #(1) memwb_wb_cntrl(
        .clk (clk),
        .d (wb_cntrl2),
        .q (wb_cntrl3) 
    );
    
     mainreg #(1) memwb_jal(
        .clk (clk),
        .d (jal2),
        .q (jal3) 
    );   
    
    mainreg #(1) memwb_dm2reg(
        .clk (clk),
        .d (dm2reg2),
        .q (dm2reg3) 
    );
    
    // --- PC Logic --- //
    dreg pc_reg (
            .clk            (clk),
            .rst            (rst),
            .d              (pc_final),
            .q              (pc_current)
        );

    adder pc_plus_4 (
            .a              (pc_current),
            .b              (32'd4),
            .y              (pc_plus4)
        );
    mainreg #(32) pc_4_reg(
        .clk (clk),
        .d (pc_plus4),
        .q(pc_plus4_out) 
    );
    
    // pc_plus_br takes 
    adder pc_plus_br (
            .a              (pc_plus4_out),
            .b              (ba),
            .y              (bta)
        );

    /*  pc_src_mux 
       DESCRPTION: Takes either branch target address or pc + 4 for the next instruction
       INPUTS: branch instruction, pc + 4 SIGNAL: pc source
       OUTPUT: pc_pre (next instruc.
    */
    mux2 #(32) pc_src_mux (
            .sel            (pc_src),
            .a              (pc_plus4_out),
            .b              (bta),
            .y              (pc_pre)
        );

    /*  pc_jmp_mux 
       DESCRPTION: Takes result of branch target address or pc + 4 and jump for the next instruction
       INPUTS: pc_pre, jump instruction SIGNAL: jump target addr
       OUTPUT: pc_next
    */
    mux2 #(32) pc_jmp_mux (
            .sel            (jump),
            .a              (pc_pre),
            .b              (jta),
            .y              (pc_next)
        );

    // --- RF Logic --- //
    mux2 #(5) rf_wa_mux (
            .sel            (reg_dst),
            .a              (instrr[20:16]),
            .b              (instrr[15:11]),
            .y              (wa_rf)
        );
        
    mainreg #(32) wa1_reg(
        .clk (clk),
        .d (wa_rf),
        .q(wa) 
    );
    
    mainreg #(32) wa2_reg(
        .clk (clk),
        .d (wa),
        .q(wa_r) 
    );

    regfile rf (
            .clk            (clk),
            .we             (we_reg),
            .ra1            (instrr[25:21]),
            .ra2            (instrr[20:16]),
            .ra3            (ra3),
            .wa             (rf_wa),
            .wd             (wd_rf),
            .rd1            (alu_p),
            .rd2            (wd_dm),
            .rd3            (rd3)
        );

    signext se (
            .a  (instrr[15:0]),
            .y  (sext_imm)
        );
    signextend2 s (
            .a(instrr[10:6]),
            .y(shiftamount)
    );
    mainreg #(32) se1_reg(
        .clk (clk),
        .d (sext_imm),
        .q(sext_im) 
    );
    mainreg #(32) se2_reg(
        .clk (clk),
        .d (shiftamount),
        .q (shiftamount1) 
    );
    
    // --- ALU Logic --- //
    mainreg #(32) alua_reg(
        .clk (clk),
        .d (alu_p),
        .q(alu_pp) 
    );
    mainreg #(32) alub_reg(
        .clk (clk),
        .d (wd_dm),
        .q(wd_d) 
    );
    mux2 #(32) alu_pb_mux (
            .sel            (alu_src1),
            .a              (wd_d),
            .b              (sext_im),
            .y              (alu_pb)
        );
    mux2 #(32) alu_pa_mux (
            .sel            (shift1),
            .a              (alu_p),
            .b              (shiftamount1),
            .y              (alu_pa)
        );
        
    alu alu (
            .op             (alu_ctrl1),
            .a              (alu_pa),
            .b              (alu_pb),
            .zero           (zero),
            .y              (alu_to_exmem_reg)
        );
        
     mainreg #(32) alu_reg(
        .clk (clk),
        .d (alu_to_exmem_reg),
        .q (alu_out) 
    );

    // --- MEM Logic --- //
    mux2 #(32) rf_wd_mux (
            .sel            (dm2reg3),
            .a              (alu_mul_out),
            .b              (rd_dm),
            .y              (rf_wd)
        );
        
   // --- JR logic ---//
	mux2 #(32) jr_mux (
            .sel            (jr),
            .a              (pc_next),
            .b              (alu_pa),
            .y              (pc_final)
	  );
	  
	// --- multiply logic ---//
multiplier muli(
            .a(alu_pa), 
            .b(wd_d), 
            .hi(hi),
            .lo(lo)
            );
            
mainreg #(32) hi_reg(
        .clk (clk),
        .d (hi),
        .q(hi_out) 
    );
    
mainreg #(32) lo_reg(
        .clk (clk),
        .d (lo),
        .q(lo_out) 
    );
hilo_reg rf1(
                .clk(clk),
                .we_hi(wehi2),
                .we_lo(welo2),
                .en(enable),
                .hi(hi_out),
                .lo(lo_out),
                .rd(rd)
                ); 
                
mainreg #(32) mul_out_reg(
        .clk (clk),
        .d (rd),
        .q(hilo_reg_out) 
    );
    
mux2 #(32) alu_mul_mux (
            .sel            (wb_cntrl3),
            .a              (alu_out),
            .b              (hilo_reg_out),
            .y              (alu_mul_out)
        );
        
// --- JAL Logic ---//
	mux2 #(32) jal_wd_mux (
            .sel            (jal3),
            .a              (rf_wd),
            .b              (pc_plus4_out),
            .y              (wd_rf)
        );
      mux2 #(5) Jal_wa_mux (
            .sel            (jal3),
            .a              (wa_r),
            .b              (5'b11111),
            .y              (rf_wa)
        );
endmodule