module CONTROL_CENTER(
    input               clk,
    input               rst_n,
    input    [7:0]      uart_data_received,
    input               uart_rx_done_flag,
    input               card_OK,
    input   [31:0]      UID,
    output              lcd_ena,
    output [127:0]      row1,                           // LCD row 1
    output [127:0]      row2,                           // LCD row 2
    output              servo_state,
    output              uart_send,
    output   [7:0]      uart_data_send
);

    localparam  IDLE            = 0,
                INVALID         = 1,
                DELAY_INVALID   = 2,
                OPEN            = 3,
                DELAY_OPEN      = 4,
                CLOSE           = 5,
                LOCK            = 6,
                DELAY_LOCK      = 7,
                DELAY_UNLOCK    = 8;

    localparam  CMD_OPEN        = 8'h4F,
                CMD_CLOSE       = 8'h43,
                CMD_INVALID     = 8'h49,
                CMD_LOCK        = 8'h4C,
                CMD_UNLOCK      = 8'h55;
    
    localparam  uid_1 = 32'h2359A629;       // valid card UID
    localparam  uid_2 = 32'hF3F3A414;       // invalid card UID

    reg   [3:0] state;
    reg         lcd_ena_r;
    reg [127:0] row1_r;
    reg [127:0] row2_r;
    reg         servo_state_r;
    reg         uart_send_r;
    reg   [7:0] uart_data_send_r;
    reg  [31:0] wait_counter;

    reg   [2:0] invalid_cnt;
    reg  [31:0] cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            wait_counter <= 32'd0;
            servo_state_r <= 1'b0;
            row1_r = " Please insert  ";
            row2_r = " your card ...  ";
            lcd_ena_r <= 1'b0;
            uart_send_r <= 1'b0;
            uart_data_send_r <= 8'hAA;
            invalid_cnt <= 0;
            cnt <= 0;
        end else begin
            if (&cnt[14:0] && uart_send_r) begin            // pull down uart_send_r after 2^15 * 10ns = 327.68us
                uart_send_r <= 1'b0;
            end

            case (state)
                IDLE: begin
                    wait_counter <= 32'd0;
                    servo_state_r <= 1'b0;
                    row1_r = " Please insert  ";
                    row2_r = " your card ...  ";
                    lcd_ena_r <= 1'b0;
                    
                    // check if carrd is valid or there is a signal from uart
                    if (card_OK && (UID == uid_1)) begin
                        state <= OPEN;
                    end else if (card_OK && (UID == uid_2)) begin
                        invalid_cnt <= invalid_cnt + 1;
                        if (invalid_cnt >= 2) begin
                            state <= LOCK;
                            invalid_cnt <= 0;
                        end else begin
                            state <= INVALID;
                        end 
                    end else if (uart_rx_done_flag && (uart_data_received == CMD_LOCK)) begin
                        invalid_cnt <= 0;
                        state <= LOCK;
                    end else begin
                        state <= IDLE;
                    end                
                end
                INVALID: begin
                    servo_state_r <= 1'b0;
                    row1_r = " Invalid card!  ";
                    row2_r = "Please try again";
                    lcd_ena_r <= 1'b1;
                    uart_send_r <= 1'b1;
                    uart_data_send_r <= CMD_INVALID;
                    if (wait_counter >= 100) begin
                        state <= DELAY_INVALID;
                        wait_counter <= 32'd0;
                    end else begin
                        wait_counter <= wait_counter + 1;
                        state <= INVALID;
                    end
                end
                DELAY_INVALID: begin
                    lcd_ena_r <= 1'b0;
                    if (wait_counter >= 100_000_000) begin // 1s
                        wait_counter <= 32'd0;
                        state <= CLOSE;
                    end else begin
                        wait_counter <= wait_counter + 1;
                        state <= DELAY_INVALID;
                    end
                end
                OPEN: begin
                    servo_state_r <= 1'b1;
                    row1_r = " Valid card!    ";
                    row2_r = " WELCOME HOME   ";
                    lcd_ena_r <= 1'b1;
                    uart_send_r <= 1'b1;
                    uart_data_send_r <= CMD_OPEN;
                    if (wait_counter >= 100) begin
                        state <= DELAY_OPEN;
                        wait_counter <= 32'd0;
                    end else begin
                        wait_counter <= wait_counter + 1;
                        state <= OPEN;
                    end
                end
                DELAY_OPEN: begin
                    lcd_ena_r <= 1'b0;
                    if (wait_counter >= 300_000_000) begin // 3s
                        wait_counter <= 32'd0;
                        state <= CLOSE;
                    end else begin
                        wait_counter <= wait_counter + 1;
                        state <= DELAY_OPEN;
                    end
                end
                CLOSE: begin
                    servo_state_r <= 1'b0;
                    row1_r = " Please insert  ";
                    row2_r = " your card ...  ";
                    lcd_ena_r <= 1'b1;
                    uart_send_r <= 1'b1;
                    uart_data_send_r <= CMD_CLOSE;
                    if (wait_counter >= 100) begin
                        state <= IDLE;
                        wait_counter <= 32'd0;
                    end else begin
                        wait_counter <= wait_counter + 1;
                        state <= CLOSE;
                    end
                end
                LOCK: begin
                    servo_state_r <= 1'b0;
                    row1_r = " System Locked!  ";
                    row2_r = " Access denied!  ";
                    lcd_ena_r <= 1'b1;
                    uart_send_r <= 1'b1;
                    uart_data_send_r <= CMD_LOCK;
                    if (wait_counter >= 100) begin
                        state <= DELAY_LOCK;
                        wait_counter <= 32'd0;
                    end else begin
                        wait_counter <= wait_counter + 1;
                        state <= LOCK;
                    end
                end
                DELAY_LOCK: begin
                    lcd_ena_r <= 1'b0;
                    if (uart_rx_done_flag && (uart_data_received == CMD_UNLOCK)) begin 
                        uart_send_r <= 1'b1;
                        uart_data_send_r <= CMD_UNLOCK;                      
                        state <= DELAY_UNLOCK;
                    end else begin                       
                        state <= DELAY_LOCK;
                    end
                end
                DELAY_UNLOCK: begin
                    if (wait_counter >= 100_000) begin  // 1ms
                        state <= CLOSE;
                        wait_counter <= 32'd0;
                    end else begin
                        wait_counter <= wait_counter + 1;
                        state <= DELAY_UNLOCK;
                    end
                end
                default: begin
                    state <= IDLE;
                end
            endcase
            cnt <= cnt + 1;
        end
    end

    assign lcd_ena = lcd_ena_r;
    assign row1 = row1_r;
    assign row2 = row2_r;
    assign servo_state = servo_state_r;
    assign uart_send = uart_send_r;
    assign uart_data_send = uart_data_send_r;

endmodule
