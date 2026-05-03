
// testing baud rate mismatch about 5% with Tx at 9120 bps and Rx at 9600 bps
// result at Waveforms/testbench_4bm

module test_bench ();
    reg clk=1;
	always #10 clk = ~clk;  // Create clock with period=20 => 50MHz

    reg reset, enable_Tx;
    reg [7:0] Data_In;
    wire [7:0] Data_Out;
    wire Rx, Tx_busy, Rx_busy, done, valid;
    integer i;

    reg [12:0] Tx_baud_rate = 13'h156A; // => 1 / (baud rate x clock period)
    reg [12:0] Rx_baud_rate = 13'h1458; // => 1 / (baud rate x clock period)

    initial begin

        reset = 1; enable_Tx = 0; Data_In = 8'hAA;

        #100 reset = 0;

        #1036700 enable_Tx = 1;

        #1092900 Data_In = 8'h00;
        #1092900 Data_In = 8'h55;
        #1092900 Data_In = 8'hFF;
        #1092900 Data_In = 8'h0F; enable_Tx = 0;

        #1092900 $finish;

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