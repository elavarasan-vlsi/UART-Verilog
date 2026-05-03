module UART_Rx(
    input clk,
    input reset,
    input Rx,
    input [12:0] baud_rate,
    output reg [7:0] Data_Out,
    output reg Rx_Busy,
    output Rx_Valid
);
    parameter IDLE=2'h0, START=2'h1, DATA=2'h2, STOP=2'h3;

    reg [1:0] Rx_State; 
    reg [3:0] Bit_Counter;
    reg [12:0] baud_tick = 13'h0;
    reg [8:0] count_tick = 9'h0;
    reg [3:0] sample_counter = 4'h0;
    reg baud_en, count_en;
    reg [1:0] sample_bit;
    reg [1:0] rx_sync;
    reg valid_start;

    reg test = 1'b0;

    initial begin
        Rx_State <= IDLE;
        Rx_Busy <= 1'b0;
        Data_Out <= 8'h0;
        Bit_Counter <= 4'h0;
        rx_sync <= 2'h0;
        sample_bit <= 2'h0;
        valid_start <= 1'b0;
        baud_en <= 1'b0;
        count_en <= 1'b0; 
    end

    wire Rx_Bit  = (sample_bit[0]+sample_bit[1]+rx_sync[1] >= 2);    // taking majority of 7th, 8th and 9th sample_bit
    assign Rx_Valid = Rx_Bit && (Rx_State==STOP) && (sample_counter==8) && count_en;
    wire framing_error = ~Rx_Bit && (Rx_State==STOP) && (sample_counter==8) && count_en;

    always@(posedge clk)begin
        if(reset)begin
            Rx_State <= IDLE;
            Rx_Busy <= 1'b0;
            Data_Out <= 8'h0;
            Bit_Counter <= 4'h0;
            rx_sync <= 2'h0;
            sample_bit <= 2'h0;
            valid_start <= 1'b0;
            baud_tick  <= 13'h0;
            count_tick <= 9'h0;
        end else begin
            rx_sync[0] <= Rx;
            rx_sync[1] <= rx_sync[0];

            if(~(Rx_State==IDLE))begin
                baud_tick <= (baud_tick==baud_rate) ? 13'h0 : baud_tick + 13'h1; 
                count_tick <= (count_tick==(baud_rate>>4)) ?  9'h0 : count_tick + 9'h1; 
            end
            
            baud_en  <= (baud_tick == baud_rate);
            count_en <= (count_tick == (baud_rate>>4));   

            if(~rx_sync[0] && rx_sync[1])begin  //detecting negedge of Rx
                if(Rx_State==IDLE)begin
                    Rx_State <= START;
                    baud_tick <= 13'h0;
                    count_tick <= 9'h0;
                    sample_counter <= 4'h0;
                end
            end

            if(baud_en)begin  //  baud_rate
                sample_counter <= 4'h0;
                count_tick <= 9'h0;
                case(Rx_State)
                    START : begin
                        if(valid_start)begin
                            Rx_State <= DATA; 
                            Bit_Counter <= 4'h0;
                        end else
                            Rx_State <= IDLE;
                    end
                    DATA  : begin
                        if(Bit_Counter==4'h7)
                            Rx_State <= STOP;
                        else
                            Bit_Counter <= Bit_Counter+1;
                    end
                    STOP  : Rx_State <= IDLE;
                endcase
            end

            if(count_en)begin  //  baud_rate x 16 bps
                if(~baud_en)  
                    sample_counter <= sample_counter + 4'h1;

                if(sample_counter >= 6 && sample_counter < 8) 
                    sample_bit[sample_counter-4'h6] <= rx_sync[1];  

                else if(sample_counter==8)begin 

                    if(Rx_State==START)begin
                        Rx_Busy <= ~Rx_Bit;
                        valid_start <= ~Rx_Bit;

                    end else if(Rx_State==STOP)begin
                        Rx_Busy <= 1'b0;
                        Rx_State <= IDLE;

                    end else if(Rx_State==DATA)begin
                        Data_Out[Bit_Counter] <= Rx_Bit;
                        valid_start <= 1'b0;
                    end
                end  

            end
        end
    end

endmodule