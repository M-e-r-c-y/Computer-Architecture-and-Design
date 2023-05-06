module controlunit (
        input  wire [5:0]  opcode,
        input  wire [5:0]  funct,
        output wire        branch,
        output wire        jump,
        output wire        reg_dst,
        output wire        we_reg,
        output wire        alu_src,
        output wire        we_dm,
        output wire        dm2reg,
        output wire [2:0]  alu_ctrl,
        output wire         jal,
	    output wire        wehi,
        output wire        welo,
        output wire        jr,
        output wire        wb_cntrl,
	    output wire        shift,
	    output wire        enable
    );
    
    wire [1:0] alu_op;

    maindec md (
        .opcode         (opcode),
        .branch         (branch),
        .jump           (jump),
        .reg_dst        (reg_dst),
        .we_reg         (we_reg),
        .alu_src        (alu_src),
        .we_dm          (we_dm),
        .dm2reg         (dm2reg),
        .alu_op         (alu_op),
	    .jal            (jal)
    );

    auxdec ad (
        .alu_op         (alu_op),
        .funct          (funct),
        .alu_ctrl       (alu_ctrl),
        .wehi           (wehi),
	    .welo           (welo),
        .jr             (jr),
	    .wb_cntrl       (wb_cntrl),
	    .shift          (shift),
	    .enable         (enable)
        
    );

endmodule