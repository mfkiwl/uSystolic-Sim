`ifndef _array_4_
`define _array_4_

`include "pe_border.sv"
`include "pe_inner.sv"

module array_4 #(
    parameter HEIGHT=4,
    parameter WIDTH=4,
    parameter IWIDTH=16,
    parameter OWIDTH=24
) (
    input logic clk,
    input logic rst_n,
    input logic [HEIGHT-1 : 0] en_i,
    input logic [HEIGHT-1 : 0] clr_i,
    input logic [HEIGHT-1 : 0] mac_done,
    input logic [WIDTH-1 : 0] en_w,
    input logic [WIDTH-1 : 0] clr_w,
    input logic [WIDTH-1 : 0] en_o,
    input logic [WIDTH-1 : 0] clr_o,
    input logic signed [IWIDTH-1 : 0] ifm [HEIGHT-1 : 0],
    input logic signed wght_sign [WIDTH-1 : 0],
    input logic signed [IWIDTH-2 : 0] wght_abs [WIDTH-1 : 0],
    output logic signed [OWIDTH-1 : 0] ofm [WIDTH-1 : 0]
);

    logic [WIDTH : 0] en_i_x [HEIGHT-1 : 0];
    logic [WIDTH : 0] clr_i_x [HEIGHT-1 : 0];
    logic [WIDTH : 0] mac_done_x [HEIGHT-1 : 0];
    logic [HEIGHT : 0] en_w_x [WIDTH-1 : 0];
    logic [HEIGHT : 0] clr_w_x [WIDTH-1 : 0];
    logic [HEIGHT : 0] en_o_x [WIDTH-1 : 0];
    logic [HEIGHT : 0] clr_o_x [WIDTH-1 : 0];

    logic signed ifm_sign_x [HEIGHT-1 : 0][WIDTH : 0];
    logic signed ifm_dff_x [HEIGHT-1 : 0][WIDTH : 0];
    logic signed wght_sign_x [WIDTH-1 : 0][HEIGHT : 0];
    logic signed [IWIDTH-2 : 0] wght_abs_x [WIDTH-1 : 0][HEIGHT : 0];
    logic signed [IWIDTH-2 : 0] randW_x [WIDTH-1 : 0][HEIGHT : 0];
    logic signed [OWIDTH-1 : 0] ofm_x [WIDTH-1 : 0][HEIGHT : 0];

    genvar h;
    generate
        for (h = 0; h < HEIGHT; h++) begin
            assign en_i_x[h][0] = en_i[h];
            assign clr_i_x[h][0] = clr_i[h];
            assign mac_done_x[h][0] = mac_done[h];
        end
    endgenerate

    genvar w;
    generate
        for (w = 0; w < WIDTH; w++) begin
            assign en_w_x[w][0] = en_w[w];
            assign clr_w_x[w][0] = clr_w[w];
            assign wght_sign_x[w][0] = wght_sign[w];
            assign wght_abs_x[w][0] = wght_abs[w];

            assign en_o_x[w][HEIGHT] = en_o[w];
            assign clr_o_x[w][HEIGHT] = clr_o[w];
            assign ofm[w] = ofm_x[w][0];
            assign ofm_x[w][HEIGHT] = 0;
        end
    endgenerate

    genvar h, w;
    generate
        for (h = 0; h < HEIGHT; h++) begin
            pe_border #(
                .IWIDTH(IWIDTH),
                .OWIDTH(OWIDTH)
            ) U_pe_border (
                .clk(clk),
                .rst_n(rst_n),
                
                .mac_done(mac_done_x[h][0]),
                .en_i(en_i_x[h][0]),
                .clr_i(clr_i_x[h][0]),
                .ifm(ifm[h]),
                .mac_done_d(mac_done_x[h][1]),
                .en_i_d(en_i_x[h][1]),
                .clr_i_d(clr_i_x[h][1]),
                .ifm_sign_d(ifm_sign_x[h][1]),
                .ifm_dff_d(ifm_dff_x[h][1]),
                
                .en_w(en_w_x[0][h]),
                .clr_w(clr_w_x[0][h]),
                .wght_sign(wght_sign_x[0][h]),
                .wght_abs(wght_abs_x[0][h]),
                .en_w_d(en_w_x[0][h+1]),
                .clr_w_d(clr_w_x[0][h+1]),
                .wght_sign_d(wght_sign_x[0][h+1]),
                .wght_abs_d(wght_abs_x[0][h+1]),

                .en_o(en_o_x[0][h+1]),
                .clr_o(clr_o_x[0][h+1]),
                .ofm(ofm_x[0][h+1]),
                .en_o_d(en_o_x[0][h]),
                .clr_o_d(clr_o_x[0][h]),
                .ofm_d(ofm_x[0][h]),

                .randW_d(randW_x[h][1])
            );
            for (w = 1; w < WIDTH; w++) begin
                pe_inner #(
                    .IWIDTH(IWIDTH),
                    .OWIDTH(OWIDTH)
                ) U_pe_inner (
                    .clk(clk),
                    .rst_n(rst_n),

                    .mac_done(mac_done_x[h][w]),
                    .en_i(en_i_x[h][w]),
                    .clr_i(clr_i_x[h][w]),
                    .ifm_sign(ifm_sign_x[h][w]),
                    .ifm_dff(ifm_dff_x[h][w]),
                    .mac_done_d(mac_done_x[h][w+1]),
                    .en_i_d(en_i_x[h][w+1]),
                    .clr_i_d(clr_i_x[h][w+1]),
                    .ifm_sign_d(ifm_sign_x[h][w+1]),
                    .ifm_dff_d(ifm_dff_x[h][w+1]),

                    .en_w(en_w_x[w][h]),
                    .clr_w(clr_w_x[w][h]),
                    .wght_sign(wght_sign_x[w][h]),
                    .wght_abs(wght_abs_x[w][h]),
                    .en_w_d(en_w_x[w][h+1]),
                    .clr_w_d(clr_w_x[w][h+1]),
                    .wght_sign_d(wght_sign_x[w][h+1]),
                    .wght_abs_d(wght_abs_x[w][h+1]),
                    
                    .en_o(en_o_x[w][h+1]),
                    .clr_o(clr_o_x[w][h+1]),
                    .ofm(ofm_x[w][h+1]),
                    .en_o_d(en_o_x[w][h]),
                    .clr_o_d(clr_o_x[w][h]),
                    .ofm_d(ofm_x[w][h]),

                    .randW(randW_x[h][w]),
                    .randW_d(randW_x[h][w+1])
                );
            end
        end
    endgenerate

endmodule

`endif