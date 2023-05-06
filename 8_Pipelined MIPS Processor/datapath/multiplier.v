module multiplier(
    input wire [31:0] a,
    input wire [31:0] b,
    output wire [31:0] hi,
    output wire [31:0] lo
);

wire [63:0] y;
     assign y = a * b;
     assign hi = y[63:32];
     assign lo = y[31:0];
endmodule