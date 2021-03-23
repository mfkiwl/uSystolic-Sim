`ifndef _mul_border_
`define _mul_border_

`include "sobol8.sv"

module mul_border #(
    parameter WIDTH=8
) (
    input logic clk,
    input logic rst_n,
    input logic [WIDTH-2 : 0] i_data_i,
    input logic [WIDTH-2 : 0] i_data_w,
    output logic [WIDTH-2 : 0] randW,
    output logic o_bit
);

    logic [WIDTH-1 : 0] randI;
    logic [WIDTH-1 : 0] randW_all;
    logic bitI;
    logic bitW;
    
    sobol8 U_sobol_I(
        .clk(clk),
        .rst_n(rst_n),
        .enable(1'b1),
        .sobolSeq(randI)
    );

    assign bitI = i_data_i > randI[WIDTH-1 : 1];

    sobol8 U_sobol_W(
        .clk(clk),
        .rst_n(rst_n),
        .enable(bitI),
        .sobolSeq(randW_all)
    );

    assign randW = randW_all[WIDTH-1 : 1];
    
    assign bitW = i_data_w > randW;

    assign o_bit = bitI & bitW;

endmodule

`endif