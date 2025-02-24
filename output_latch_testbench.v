module output_latch_testbench;
    reg [7:0] datain = 8'd34;
    wire [7:0] dataout;
    reg latch, read, reset;
    
    always begin
        #1 datain = datain - 1;
    end
    
    initial begin
        #5;
        
        read = 1;
        #1 read = 0;
        #10;
        
        latch = 1;
        #1 datain = 8'd0;
        latch = 0;
        #5 read = 1;
        #1 read = 0;
        #10;
        
        datain = 8'd55;
        #1 latch = 1;
        #1 latch = 0;
        #2 datain = 8'd89;
        #2 datain = 8'd100;
        #1 reset=1;
        #1 reset=0;
    end
    
    output_latch OL(
        .databus(dataout), .current_count(datain),
        .latch_command(latch), .read(read), .reset(reset)
    );
    
    wire [7:0] OLregister = OL.OL;
    wire latched = OL.latched;
endmodule