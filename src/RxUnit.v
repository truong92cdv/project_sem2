module RxUnit(
    input wire         rst_n,           //  Active low reset.
    input wire         data_tx,         //  Serial data recieved from the transmitter.
    input wire         clk,             //  The System's main clock.
    input wire  [1:0]  parity_type,     //  Parity type agreed upon by the Tx and Rx units.
    input wire  [1:0]  baud_rate,       //  Baud Rate agreed upon by the Tx and Rx units.

    output             active_flag,
    //  outputs logic 1 when data is in progress.
    output             done_flag,
    //  Outputs logic 1 when data is recieved
    output      [2:0]  error_flag,
    //  Consits of three bits, each bit is a flag for an error
    //  error_flag[0] ParityError flag, error_flag[1] StartError flag,
    //  error_flag[2] StopError flag.
    output      [7:0]  data_out
    //  The 8-bits data separated from the frame.
);

    //  Intermediate wires
    wire        baud_clk_w;          //  The clocking signal from the baud generator.
    wire [10:0] data_parll_w;        //  data_out parallel comes from the SIPO unit.
    wire        recieved_flag_w;     //  works as an enable for deframe unit.
    wire        def_par_bit_w;       //  The Parity bit from the Deframe unit to the ErrorCheck unit.
    wire        def_strt_bit_w;      //  The Start bit from the Deframe unit to the ErrorCheck unit.
    wire        def_stp_bit_w;       //  The Stop bit from the Deframe unit to the ErrorCheck unit.

    //  clocking Unit Instance
    BaudGenR BaudGenR_module(
        //  Inputs
        .rst_n          (rst_n),
        .clk            (clk),
        .baud_rate      (baud_rate),

        //  Output
        .baud_clk       (baud_clk_w)
    );

    //  Shift Register Unit Instance
    SIPO SIPO_module(
        //  Inputs
        .rst_n          (rst_n),
        .data_tx        (data_tx),
        .baud_clk       (baud_clk_w),

        //  Outputs
        .active_flag    (active_flag),
        .recieved_flag  (recieved_flag_w),
        .data_parll     (data_parll_w)
    );

    //  DeFramer Unit Instance
    DeFrame DeFrame_module(
        //  Inputs
        .data_parll     (data_parll_w),
        .recieved_flag  (recieved_flag_w),
        
        //  Outputs
        .parity_bit     (def_par_bit_w),
        .start_bit      (def_strt_bit_w),
        .stop_bit       (def_stp_bit_w),
        .done_flag      (done_flag),
        .raw_data       (data_out)
    );

    //  Error Checking Unit Instance
    ErrorCheck ErrorCheck_module(
        //  Inputs
        .rst_n          (rst_n),
        .recieved_flag  (done_flag),
        .parity_bit     (def_par_bit_w),
        .start_bit      (def_strt_bit_w),
        .stop_bit       (def_stp_bit_w),
        .parity_type    (parity_type),
        .raw_data       (data_out),

        //  Output
        .error_flag     (error_flag)
    );

endmodule