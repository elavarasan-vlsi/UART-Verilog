module UART_Tx(
    input clk,
    input reset,
    input enable,
    input [12:0] baud_rate,
    input [7:0] Data_In,
    output reg Tx,
    output reg Tx_Busy,
    output reg Tx_Done
);
    reg [12:0] tick = 13'h0;
    reg baud_en = 1'b1;

    parameter IDLE=1'h0, DATA=1'h1;

    reg Tx_State; 
    reg [7:0] Tx_data;
    reg [3:0] Bit_Counter;

    initial begin
        Tx <= 1'b1;
        Tx_State <= IDLE;
        Tx_Done <= 1'b0;
        Tx_Busy <= 1'b0;
        Bit_Counter <= 4'h0;
    end

    always@(posedge clk)begin
        if(reset)begin
            Tx <= 1'b1;
            Tx_State <= IDLE;
            Tx_Done <= 1'b0;
            Tx_Busy <= 1'b0;
            Bit_Counter <= 4'h0;
        end else begin
            tick <= (tick==baud_rate) ? 13'h0 : tick + 13'h1;  
            baud_en <= (tick==baud_rate);            // baud rate - 9600 bps
            if(baud_en)begin
                case(Tx_State)
                    IDLE  : begin
                        if(enable)begin
                            Tx_State <= DATA;
                            Tx <= 1'b0;
                            Tx_Busy <= 1'b1;
                            Tx_data <= Data_In;
                            Bit_Counter <= 4'h8;
                        end else begin
                            Tx_Busy <= 1'b0;
                        end
                        Tx_Done <= 1'b0;
                    end
                    DATA : begin
                        if(Bit_Counter==4'h0)begin
                            Tx <= 1'b1;
                            Tx_Done <= 1'b1;
                            Tx_State <= IDLE;
                        end else begin
                            Tx <= Tx_data[0];
                            Tx_data <= Tx_data>>1; 
                            Bit_Counter <= Bit_Counter-1;
                        end  
                    end
                endcase
            end
        end
    end

endmodule