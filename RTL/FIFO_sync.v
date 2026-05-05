module FIFO_Sync(
    input clk,
    input reset,
    input write_en,
    input read_en,
    input [7:0] input_data,
    output reg [7:0] output_data,
    output full,
    output empty  );

    reg [7:0] memory [7:0];

    reg [2:0] write_ptr;
    reg [2:0] read_ptr;
    reg [3:0] queue;
    integer i;

    initial begin
        write_ptr = 3'h0;
        read_ptr  = 3'h0;
        queue    = 4'h0;
        for (i=0; i<8; i=i+1)
            memory[i] <= 8'hFF;
    end

    assign full  =  (queue == 8);
    assign empty =  (queue == 0);

    wire write_data = write_en && !full;
    wire read_data  = read_en  && !empty;

    always@(posedge clk)begin
        if(reset)begin
            write_ptr = 3'h0;
            read_ptr  = 3'h0;
            queue    = 4'h0;
            for (i=0; i<8; i=i+1)
                memory[i] <= 8'hFF;
        end else begin

            if(write_data)begin
                    memory[write_ptr] <= input_data;
                    write_ptr <= write_ptr + 3'h1;
                    if(!read_data) 
                        queue <= queue + 3'h1;
            end

            if(read_data)begin
                    output_data <= memory[read_ptr];
                    read_ptr <= read_ptr + 3'h1;
                    if(!write_data)
                        queue <= queue - 3'h1;
            end

        end

    end
endmodule