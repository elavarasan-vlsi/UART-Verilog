
// testing behaviour of Rx when Start-bit noise injection and Stop-bit error
// result at Waveforms/testbench_3ss

module test_bench ();
    reg clk=1;
	always #10 clk = ~clk;  // Create clock with period=20 => 50MHz

    reg reset, test_Tx;
    wire [7:0] Data_Out;
    wire Rx_busy, valid;
    integer i;

    reg [12:0] Rx_baud_rate = 13'h1458; // => 1 / (baud rate x clock period)

    initial begin // Start and Stop bit error detection

        reset = 1; test_Tx = 1'b1; 

        #100 reset = 0; 

        #675690 test_Tx = 1'b0;
        #45678 test_Tx = 1'b1;

        #372870 test_Tx = 1'b0;
        #14e5 test_Tx = 1'b1;
        #454680 test_Tx = 1'b0;

        for(i=0; i<8; i=i+1)
            #104180 test_Tx = i & 1'b1;

        #104180 test_Tx = 1'b1;

        #1041800 $finish;

    end 

    UART_Rx two(clk, reset, test_Tx, Rx_baud_rate, Data_Out, Rx_busy, valid);

endmodule