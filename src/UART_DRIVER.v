module UART_DRIVER (
    input   wire         clk,               //  The main system's clock.
    input   wire         rst_n,             //  Active low reset.
    input   wire         send,              //  An enable to start sending data.
    input   wire  [7:0]  data_transmit,     //  The data input.
    input   wire         rx,                //  rx pin out

    output  wire         tx,                //  tx pin out
    output  wire         tx_active_flag,    //  outputs logic 1 when data is in progress.
    output  wire         tx_done_flag,      //  Outputs logic 1 when data is transmitted
    output  wire         rx_active_flag,    //  outputs logic 1 when data is in progress.
    output  wire         rx_done_flag,      //  Outputs logic 1 when data is recieved
    output  wire  [7:0]  data_received,     //  The 8-bits data separated from the frame.
    output  wire  [2:0]  error_flag       
    //  error_flag consits of three bits, each bit is a flag for an error
    //  error_flag[0] ParityError flag, error_flag[1] StartError flag,
    //  error_flag[2] StopError flag.
);

    localparam  parity_type     = 2'b01;    // Odd parity
    localparam  baud_rate       = 2'b10;    // 9600 baud rate

    //  Transmitter unit instance
    TxUnit Transmitter(
        //  Inputs
        .rst_n          (rst_n),
        .send           (send),
        .clk            (clk),
        .parity_type    (parity_type),
        .baud_rate      (baud_rate),
        .data_in        (data_transmit),

        //  Outputs
        .data_tx        (tx),
        .active_flag    (tx_active_flag),
        .done_flag      (tx_done_flag)
    );

    //  Reciever unit instance
    RxUnit Reciever(
        //  Inputs
        .rst_n          (rst_n),
        .clk            (clk),
        .parity_type    (parity_type),
        .baud_rate      (baud_rate),
        .data_tx        (rx),

        //  Outputs
        .data_out       (data_received),
        .error_flag     (error_flag),
        .active_flag    (rx_active_flag),
        .done_flag      (rx_done_flag)
    );

endmodule