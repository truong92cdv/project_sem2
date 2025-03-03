module SERVO_DRIVER(
    input       clk_1MHz,
    input       rst_n,
    input       servo_state,                // 0: close, 1: open
    output      pwm
);

    reg         pwm_r;
    reg [14:0]  cnt;
    reg [10:0]  T_on_max;

    always @(*) begin
        case (servo_state)
            1'b0: T_on_max = 1000;          //  0 degree
            1'b1: T_on_max = 2000;          // 90 degree
        endcase
    end

    always @(posedge clk_1MHz or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 0;
            pwm_r <= 0;
        end else begin
            if (cnt < 20000) begin
                cnt <= cnt + 1;
            end else begin
                cnt <= 0;
            end
            if (cnt < T_on_max) begin
                pwm_r <= 1;
            end else begin
                pwm_r <= 0;
            end
        end
    end

    assign pwm = pwm_r;

endmodule
