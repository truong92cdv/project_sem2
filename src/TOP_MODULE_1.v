module TOP_MODULE_1 (
    input           clk,            // 100MHz
    input           rst_n,      
    inout           sda,            // I2C for LCD
    output          scl,            
    output          tx,             // UART for ESP32
    input           rx,
    output          mosi,           // SPI for RC522
    input           miso,           
    output          sclk,
    output          cs_n,
    output          rst,
    output          buzz,           // for Buzzer
    output          pwm,            // PWM for servo
    output          RGB1_B,         // RGB LEDs
    output          RGB1_G,
    output          RGB1_R,
    output          RGB2_B,
    output          RGB2_G,
    output          RGB2_R 
);
    wire            lcd_ena;
    wire            clk_1MHz;
    wire            servo_state;
    wire            uart_send;
    wire [7:0]      uart_data_send;
    wire [7:0]      uart_data_received;
    wire            rx_done_flag;
    wire [127:0]    row1;
    wire [127:0]    row2;
    wire            busy;
    wire            card_OK;
    wire [31:0]     UID;
    wire            buzz_state;

    clk_gen clk_gen_inst(
        .clk                (clk),
        .clk_1MHz           (clk_1MHz)
    );

    CONTROL_CENTER CONTROL_CENTER_inst(
        .clk                (clk),
        .rst_n              (rst_n),
        .uart_data_received (uart_data_received),
        .uart_rx_done_flag  (rx_done_flag),
        .card_OK            (card_OK),
        .UID                (UID),
        .lcd_ena            (lcd_ena),
        .row1               (row1),
        .row2               (row2),
        .servo_state        (servo_state),
        .uart_send          (uart_send),
        .uart_data_send     (uart_data_send)
    );

    RC522_DRIVER RC522_DRIVER_inst(
        .clk                (clk),
        .rst_n              (rst_n),
        .miso               (miso),
        .mosi               (mosi),
        .sclk               (sclk),
        .cs_n               (cs_n),
        .rst                (rst),
        .UID                (UID),
        .card_OK            (card_OK),
        .RGB1_B             (RGB1_B),
        .RGB1_G             (RGB1_G),
        .RGB1_R             (RGB1_R),
        .RGB2_B             (RGB2_B),
        .RGB2_G             (RGB2_G),
        .RGB2_R             (RGB2_R)
    );

    LCD_DRIVER LCD_DRIVER_inst(
        .clk                (clk),
        .clk_1MHz           (clk_1MHz),
        .rst_n              (rst_n),
        .lcd_ena            (lcd_ena),
        .row1               (row1),
        .row2               (row2),
        .busy               (busy),
        .scl                (scl),
        .sda                (sda)
    );

    SERVO_DRIVER SERVO_DRIVER_inst(
        .clk_1MHz           (clk_1MHz),
        .rst_n              (rst_n),
        .servo_state        (servo_state),
        .pwm                (pwm)
    );

    BUZZER_DRIVER BUZZER_DRIVER_inst(
        .clk                (clk),
        .rst_n              (rst_n),
        .buzz               (buzz)
    );

    UART_DRIVER UART_DRIVER_inst(
        .clk                (clk),
        .rst_n              (rst_n),
        .send               (uart_send),
        .data_transmit      (uart_data_send),
        .rx                 (rx),
        .tx                 (tx),
        .tx_active_flag     (),
        .tx_done_flag       (),
        .rx_active_flag     (),
        .rx_done_flag       (rx_done_flag),
        .data_received      (uart_data_received),
        .error_flag         ()
    );

endmodule
