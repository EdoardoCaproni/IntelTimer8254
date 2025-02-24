module counting_element (
    input clk,  //clock del counter
    input start_count,  //1=leggi da CR
    input [7:0] initial_count_high, //byte alto da CRm
    input [7:0] initial_count_low,  //byte basso da CRl
    output [7:0] output_count_high,//byte alto per OLm
    output [7:0] output_count_low, //byte basso per OLl
    output count_end   //1 quando count_register ha raggiunto 0
);

    reg [15:0] CEregister;

    always @(posedge start_count) begin
        CEregister [15:8] = initial_count_high;
        CEregister [7:0] = initial_count_low;
    end
    
    always @(negedge clk) begin
        if (CEregister!=16'b0 && !start_count)
            CEregister = CEregister - 1;
    end
    
    assign count_end = (CEregister==0) ? 1 : 0;
    
    assign output_count_high = CEregister [15:8];
    assign output_count_low = CEregister [7:0];
endmodule