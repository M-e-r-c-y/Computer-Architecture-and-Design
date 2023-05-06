module signextend2(
        input  wire [5:0] a,
        output wire [31:0] y
    );
    assign y = {26'b00000000000000000000000000,a};
endmodule
