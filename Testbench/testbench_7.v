
// testing continuous byte stream from Tx FIFO to Rx FIFO through UART.
// result at Waveforms/UART_with_FIFO.png

module test_bench ();
    reg clk=1;
	always #10 clk = ~clk;  // Create clock with period=20 => 50MHz

    reg reset, write_en_Tx, enable_Tx, read_en_Rx;
    reg [7:0] Data_In_Tx;
    wire [7:0] Data_Out_Tx;
    wire [7:0] Data_In_Rx;
    wire [7:0] Data_Out_Rx;
    wire full_Tx, empty_Tx, Tx_busy, done;
    wire full_Rx, empty_Rx, Rx_busy, valid;
    integer i;

    reg [12:0] Tx_baud_rate = 13'h1B2;
    reg [12:0] Rx_baud_rate = 13'h1B2; // => 1 / (baud rate x clock period)

    wire read_en_Tx, write_en_Rx;

    initial begin    // 5% TOLERANCE AT 13'h1388

        write_en_Tx = 1'b0; reset = 1'b0; enable_Tx = 1'b0; read_en_Rx = 1'b0;

        #58 Data_In_Tx = 8'hAA; 
        #8e5 write_en_Tx = 1'b1;
        for(i=0; i<12; i=i+1)
            #20 Data_In_Tx = $random & 8'hFF;
        #20 write_en_Tx = 1'b0;

        #9e5 write_en_Tx = 1'b1;
        
        #5 Data_In_Tx =8'h45;
        #20 Data_In_Tx =8'h57;
        #20 Data_In_Tx =8'hF2;
        #20 write_en_Tx = 1'b0;

        #20e6 $finish;

    end 

    UART_Tx one(clk, reset, !empty_Tx, Tx_baud_rate, Data_Out_Tx, Tx, Tx_busy, done, read_en_Tx);
    UART_Rx two(clk, reset, Tx, Rx_baud_rate, Data_In_Rx, Rx_busy, write_en_Rx); 

    FIFO_sync Tx_FIFO(clk, reset, write_en_Tx, read_en_Tx, Data_In_Tx, Data_Out_Tx, full_Tx, empty_Tx);
    FIFO_sync Rx_FIFO(clk, reset, write_en_Rx, read_en_Rx, Data_In_Rx, Data_Out_Rx, full_Rx, empty_Rx);

endmodule
