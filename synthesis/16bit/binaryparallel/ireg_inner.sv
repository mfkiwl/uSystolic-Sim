module ireg_inner #(
    parameter WIDTH=16
) (
    input logic clk,
    input logic rst_n,
    input logic en,
    input logic signed [WIDTH-1 : 0] i_data,
    output logic signed [WIDTH-1 : 0] o_data
);

    // this module is the horizontal buffer for control and data signals
    always_ff @(posedge clk or negedge rst_n) begin : ireg_inner
        if (~rst_n) begin
            o_data <= 0;
        end else begin
            if (en) begin
                o_data <= i_data;
            end else begin
                o_data <= o_data;
            end
        end
    end

endmodule