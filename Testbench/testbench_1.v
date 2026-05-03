
// testing continuous byte stream without idle state with both Tx and Rx at 9600 bps
// result at Waveforms/testbench_1cb

module test_bench ();
    reg clk=1;
	always #10 clk = ~clk;  // Create clock with period=20 => 50MHz

    reg reset, enable_Tx;
    reg [7:0] Data_In;
    wire [7:0] Data_Out;
    wire Rx, Tx_busy, Rx_busy, done, valid;
    integer i;

    reg [12:0] Tx_baud_rate = 13'h1458; // => 1 / (baud rate x clock period)
    reg [12:0] Rx_baud_rate = 13'h1458; // => 1 / (baud rate x clock period)

    initial begin    // continous byte stream.

        reset = 1; enable_Tx = 0; Data_In = 8'h55;

        #100 reset = 0;

        #1036700 enable_Tx = 1;

        #1041800 Data_In = 8'h00;
        #1041800 Data_In = 8'hFF;
        #1041800 Data_In = 8'hAA;
        #1041800 Data_In = 8'hAF; enable_Tx = 0;

        #1000000 $finish;

    end 

    always @(posedge done) begin
        check();
    end

    task check;
    begin

        if(Data_In!=Data_Out)
            $display("ERROR at time %0t: Data_In=%b Data_Out=%b | expected=%b",
                    $time, Data_In, Data_Out, Data_In);
        else
            $display("PASS at time %0t: Data_In=%b Data_Out=%b | expected=%b",
                    $time, Data_In, Data_Out, Data_In);
            
    end
    endtask

	UART_Tx one(clk, reset, enable_Tx, Tx_baud_rate, Data_In, Tx, Tx_busy, done);
    UART_Rx two(clk, reset, Tx, Rx_baud_rate, Data_Out, Rx_busy, valid);       // connecting Tx to Rx

endmodule