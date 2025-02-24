module counting_element_testbench;
    reg clk = 0;
    always #5 clk = !clk;
    
    reg  [7:0] ich = 8'b0, icl = 8'b0;
    wire [7:0] och, ocl;
    reg start_count=0;
    wire count_end;
    
    always begin
        #13;
        
        start_count=1;
        #5;
        start_count=0;
        #5;
        
        icl=8'd10;
        #1 start_count=1;
        #1 start_count=0;
        #50;
        
        ich =8'd1;
        #3 start_count = 1;
        #1 start_count = 0;
        #10000000;
        $stop;
    end
    
    counting_element CE (
        .clk(clk),
        .start_count(start_count),
        .initial_count_high(ich), .initial_count_low(icl),
        .output_count_high(och), .output_count_low(ocl),
        .count_end(count_end)
    );
    
    
endmodule