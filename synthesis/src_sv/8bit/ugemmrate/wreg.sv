`ifndef _wreg_
`define _wreg_

module wreg #(
    parameter WIDTH=8
) (
    input logic clk,
    input logic rst_n,
    input logic en,
    input logic clr,
    input logic [WIDTH-1 : 0] i_data,
    output logic [WIDTH-1 : 0] o_data
);
    
    // this module is the horizontal buffer for control and data signals
    always_ff @(posedge clk or negedge rst_n) begin : wreg
        if (~rst_n) begin
            o_data <= 0;
        end else begin
            if (clr) begin
                o_data <= 0;
            end else begin
                if (en) begin
                    o_data <= i_data;
                end else begin
                    o_data <= o_data;
                end
            end
        end
    end

endmodule

`endif