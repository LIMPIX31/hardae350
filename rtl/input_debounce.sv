module input_debounce
( input  logic clk
, input  logic rst
, input  logic i
, output logic o
);

    logic r0, r1, r2;
    logic [19:0] cnt;

    always_ff @(posedge clk) begin
        if (rst) begin
            r0 <= 1'b0;
            r1 <= 1'b0;
        end else begin
            r0 <= i;
            r1 <= r0;
            r2 <= r1;
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            cnt <= 0;
        end else if (r1 == r2) begin
            cnt <= cnt + 20'd1;
        end else begin
            cnt <= 0;
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            o <= 0;
        end else if (&cnt) begin
            o <= r2;
        end
    end

endmodule : input_debounce
