module hilo_reg(
        input  wire        clk,
        input  wire        we_hi,
        input  wire        we_lo,
        input  wire        en,
        input  wire [31:0] hi,
        input  wire [31:0] lo,
        output reg [31:0] rd
    );

    reg [31:0] inter_hi;
    reg [31:0] inter_lo;
            
    always@ (posedge clk) begin
        if(en)
        inter_hi <= hi;
        inter_lo <= lo;
    end
    
    always @ (*) begin
        if (we_hi) begin 
            rd = inter_hi;
        end else if (we_lo) begin
            rd = inter_lo;
        end          
    end
endmodule