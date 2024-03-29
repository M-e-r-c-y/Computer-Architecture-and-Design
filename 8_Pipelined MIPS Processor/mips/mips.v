module mips (
        input  wire        clk,
        input  wire        rst,
        input  wire [4:0]  ra3,
        input  wire [31:0] instr,
        input  wire [31:0] rd_dm,
        output wire        we_dm,
        output wire [31:0] pc_current,
        output wire [31:0] alu_out,
        output wire [31:0] wd_dm,
        output wire [31:0] rd3
    );
    
    wire       branch;
    wire       jump;
    wire       reg_dst;
    wire       we_reg;
    wire       alu_src;
    wire       dm2reg;
    wire [3:0] alu_ctrl;
    wire       wehi;
    wire       welo;
    wire       jr;
    wire       wb_cntrl;
    wire       shift;
    wire  	   jal;
    wire       enable;
    wire [31:0] instr_to_cu;

    datapath dp (
            .clk            (clk),
            .rst            (rst),
            .branch         (branch),
            .jump           (jump),
            .reg_dst        (reg_dst),
            .we_reg         (we_reg),
            .alu_src        (alu_src),
            .dm2reg         (dm2reg),
            .alu_ctrl       (alu_ctrl),
            .ra3            (ra3),
            .instr          (instr),
            .rd_dm          (rd_dm),
            .pc_current     (pc_current),
            .alu_out        (alu_out),
            .wd_dm          (wd_dm),
            .rd3            (rd3),
            .wehi           (wehi),
	        .welo           (welo),
         	.jr             (jr),
	   	    .wb_cntrl       (wb_cntrl),
	   	    .shift          (shift),
		    .jal 		    (jal),
            .enable         (enable),
	        // -- Lab 8 Changes -- //
	        .instr_to_cu  (instr_to_cu)
        );

    controlunit cu (
            .opcode         (instr_to_cu[31:26]),
            .funct          (instr_to_cu[5:0]),
            //.opcode         (instr[31:26]),
            //.funct          (instr[5:0]),
            .branch         (branch),
            .jump           (jump),
            .reg_dst        (reg_dst),
            .we_reg         (we_reg),
            .alu_src        (alu_src),
            .we_dm          (we_dm),
            .dm2reg         (dm2reg),
            .alu_ctrl       (alu_ctrl),
            .wehi           (wehi),
	  	    .welo           (welo),
        	.jr             (jr),
	  	    .wb_cntrl       (wb_cntrl),
	  	    .shift          (shift),
		    .jal            (jal),
            .enable           (enable)
        );

endmodule
