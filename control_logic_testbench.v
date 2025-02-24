`timescale 1ns/1ps

module control_logic_testbench;
    //indirizzo del contatore di appartenenza
    reg [1:0] COUNTER_ID = 2'b00;
    //porte con l'esterno
    reg clk = 0;
    always #5 clk = !clk;
    reg gate = 0;
    wire out;
    //porte per le istruzioni provenienti dal Control Word Register
    reg [5:0] CWR; //CWR[5:4]=high/low byte; CWR[3:1]=mode; CWR[0]=BCD
    reg [1:0] readback = 2'b11; //readback[1]=COUNT_; readback[0]=STATUS_
    //porte per osservare i bus
    reg [7:0] databus;
    reg [1:0] addrbus = 2'b00;
    reg       RWbus = 0; //0=scrittura; 1=lettura
    //fili di controllo CR
    wire write_high;
    wire write_low;
    wire CR_reset;
    //fili di controllo CE
    wire start_count;
    reg count_finished = 0; //=1 se CE raggiunge zero
    //fili di controllo OL
    wire read_high;
    wire read_low;
    wire latch_high;
    wire latch_low;
    wire OL_reset;
    //per registro STATUS
    wire null_count; //0=CR loaded in CE; 1=new control word / new content in CR
    
    initial begin
        #1;
        CWR = 6'b010000;
        #1;
        databus = 8'd12;
        #17;
        CWR = 6'b110010;
        databus = 8'd119;
        #5 databus = 8'd9;
        #10;
        RWbus = 1;
    end
    
    control_logic CL(
        .COUNTER_ID(COUNTER_ID),
        .clk(clk), .gate(gate), .out(out),
        .CWR(CWR), .readback(readback),
        .databus(databus), .addrbus(addrbus), .RWbus(RWbus),
        .write_high(write_high), .write_low(write_low), .CR_reset(CR_reset),
        .start_count(start_count), .count_finished(count_finished),
        .read_high(read_high), .read_low(read_low),
        .latch_high(latch_high), .latch_low(latch_low),
        .OL_reset(OL_reset),
        .null_count(null_count)
    );
    
    wire write_completed = CL.write_completed;
    wire half_write = CL.half_write;
	
endmodule
