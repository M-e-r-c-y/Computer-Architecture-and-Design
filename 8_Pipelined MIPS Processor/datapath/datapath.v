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
        output wire [31:0] rd3
    );
    wire [31:0] instrr;
    wire [4:0]  rf_wa;
    wire        pc_src;
    wire [31:0] pc_plus4;
    wire [31:0] pc_pplus4;
    wire [31:0] pc_pre;
    wire [31:0] pc_next;
    wire [31:0] sext_imm;
    wire [31:0] sext_im;
    wire [31:0] alu_outt;
    wire [31:0] ba;
    wire [31:0] bta;
    wire [31:0] jta;
    wire [31:0] alu_pa;
    wire [31:0] alu_pb;
    wire [31:0] alu_p;
    wire [31:0] alu_pp;
    wire [31:0] wd_rf;
    wire [31:0] rf_wd;
    wire [31:0] r;
    wire        zero;
    wire [31:0] pc_final;
    wire [31:0] shiftamount;
    wire [31:0] shiftamount1;
    wire [31:0] hi;
    wire [31:0] lo;
    wire [31:0] hii;
    wire [31:0] loo;
    wire [31:0] wd_d;
    wire [31:0] rd;
    wire [31:0] alu_mul_out;
    wire [4:0] wa_rf;
    wire [4:0] wa;
    wire [4:0] wa_r;
    assign pc_src = branch & zero;
    assign ba = {sext_imm[29:0], 2'b00};
    assign jta = {pc_pplus4[31:28], instrr[25:0], 2'b00};
    // first reg //
    mainreg #(32) intruc_reg(
        .clk (clk),
        .d (instr),
        .q(instrr) 
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
        .q(pc_pplus4) 
    );
    adder pc_plus_br (
            .a              (pc_pplus4),
            .b              (ba),
            .y              (bta)
        );

    mux2 #(32) pc_src_mux (
            .sel            (pc_src),
            .a              (pc_pplus4),
            .b              (bta),
            .y              (pc_pre)
        );

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
            .a              (instrr[15:0]),
            .y              (sext_imm)
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
        .q(shiftamount1) 
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
            .sel            (alu_src),
            .a              (wd_d),
            .b              (sext_im),
            .y              (alu_pb)
        );
    mux2 #(32) alu_pa_mux (
            .sel            (shift),
            .a              (alu_p),
            .b              (shiftamount1),
            .y              (alu_pa)
        );
    alu alu (
            .op             (alu_ctrl),
            .a              (alu_pa),
            .b              (alu_pb),
            .zero           (zero),
            .y              (alu_out)
        );
     mainreg #(32) alu_reg(
        .clk (clk),
        .d (alu_out),
        .q(alu_outt) 
    );

    // --- MEM Logic --- //
    mux2 #(32) rf_wd_mux (
            .sel            (dm2reg),
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
        .q(hii) 
    );
mainreg #(32) lo_reg(
        .clk (clk),
        .d (lo),
        .q(loo) 
    );
hilo_reg   rf1(
                .clk(clk),
                .we_hi(wehi),
                .we_lo(welo),
                .en(enable),
                .hi(hii),
                .lo(loo),
                .rd(rd)
                ); 
mainreg #(32) mul_out_reg(
        .clk (clk),
        .d (rd),
        .q(r) 
    );
mux2 #(32) alu_mul_mux (
            .sel            (wb_cntrl),
            .a              (alu_out),
            .b              (r),
            .y              (alu_mul_out)
        );
// --- JAL Logic ---//
	mux2 #(32) jal_wd_mux (
            .sel            (jal),
            .a              (rf_wd),
            .b              (pc_pplus4),
            .y              (wd_rf)
        );
      mux2 #(5) Jal_wa_mux (
            .sel            (jal),
            .a              (wa_r),
            .b              (5'b11111),
            .y              (rf_wa)
        );
endmodule