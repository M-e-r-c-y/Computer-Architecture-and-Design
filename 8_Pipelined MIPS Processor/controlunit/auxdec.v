module auxdec (
        input  wire [1:0] alu_op,
        input  wire [5:0] funct,
        output wire [3:0] alu_ctrl,
        output reg        wehi,
        output reg        welo,
        output reg        jr,
        output reg        wb_cntrl,
	    output reg        shift,
        output reg        enable
    );

    reg [3:0] ctrl;

    assign {alu_ctrl} = ctrl;

    always @ (alu_op, funct) begin
        case (alu_op)
            2'b00:begin ctrl = 4'b0010;wehi=0;welo=0;jr=0;wb_cntrl=0;shift=0;enable=0;  end        // ADD
            2'b01:begin ctrl = 4'b0110; wehi=0;welo=0;jr=0;wb_cntrl=0;shift=0;enable=0; end        // SUB
            default: case (funct)
                6'b10_0100:begin ctrl = 4'b0000;wehi=0;welo=0;jr=0;wb_cntrl=0;shift=0;enable=0; end//And
                6'b10_0101:begin ctrl = 4'b0001;wehi=0;welo=0;jr=0;wb_cntrl=0;shift=0;enable=0;end // OR
                6'b10_0000:begin ctrl = 4'b0010;wehi=0;welo=0;jr=0;wb_cntrl=0;shift=0;enable=0;end // ADD
                6'b10_0010:begin ctrl = 4'b0110;wehi=0;welo=0;jr=0;wb_cntrl=0;shift=0;enable=0;end // SUB
                6'b10_1010:begin ctrl = 4'b0111;wehi=0;welo=0;jr=0;wb_cntrl=0;shift=0;enable=0; end// SLT
                6'b00_0000:begin ctrl = 4'b0011;wehi=0;welo=0;jr=0;wb_cntrl=0;shift=1;enable=0;end// SLL
		        6'b00_0010:begin ctrl = 4'b0100;wehi=0;welo=0;jr=0;wb_cntrl=0;shift=1;enable=0;end// SRL
                6'b01_0000:begin ctrl = 4'b1000;wehi=1;welo=0;jr=0;wb_cntrl=1;shift=0;enable=0; end// MFHI
                6'b01_0010:begin ctrl = 4'b1000;wehi=0;welo=1;jr=0;wb_cntrl=1;shift=0;enable=0; end// MFLO
			    6'b01_1001:begin ctrl = 4'b1000;wehi=1;welo=0;jr=0;wb_cntrl=0;shift=0;enable=1; end// MULU
		        6'b00_1000:begin ctrl = 4'b1000;wehi=0;welo=0;jr=1;wb_cntrl=0;shift=0;enable=0; end// JR
                default:    begin ctrl = 4'bxxxx;wehi=0;welo=0;jr=0;wb_cntrl=0;shift=0;enable=0; end
            endcase
        endcase
    end
   endmodule
