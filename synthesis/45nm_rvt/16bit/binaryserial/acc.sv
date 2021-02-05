module acc #(
    parameter WIDTH=32
) (
    input logic clk,
    input logic rst_n,
    input logic en,
    input logic clr,
    input logic acc,
    input logic signed [WIDTH-1 : 0] prod,
    input logic signed [WIDTH-1 : 0] sum_i,
    output logic signed [WIDTH-1 : 0] sum_o
);

    // this module is the horizontal buffer for control and data signals
    always_ff @(posedge clk or negedge rst_n) begin : acc_proc
        if (~rst_n) begin
            sum_o <= 0;
        end else begin
            if (clr) begin
                sum_o <= 0;
            end else begin
                if (en) begin
                    sum_o <= (acc ? prod : sum_o) + sum_i;
                end else begin
                    sum_o <= sum_o;
                end
            end
        end
    end

endmodule