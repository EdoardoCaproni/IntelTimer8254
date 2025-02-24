module count_register_testbench;
    reg [7:0] datain;
    reg write=0, reset=0;
    wire [7:0] out;
    
    initial begin
        datain=8'd47;
        #5;
        
        write = 1;
        #1 write = 0;
        #5;
        
        reset = 1;
        #1 reset = 0;
        #10;
    
    end
    
    count_register CR (
        .databus(datain),
        .write(write), .reset(reset),
        .initial_count(out)
    );
endmodule