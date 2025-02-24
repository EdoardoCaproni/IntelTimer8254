`timescale 1ns/1ps

module counter_testbench;
    reg clk=0;
    always #5 clk = !clk;
    reg gate = 0;
    wire out;
    
    reg [7:0] datareg;
    wire [7:0] databus;
    reg [1:0] addr;
    reg RW; //0 scrittura, 1 lettura
    reg [5:0] instruction;
    reg [1:0] RB;
    
    initial begin
        RW = 0;
        addr = 2'b00;
        RB = 2'b11;
        instruction = 6'b010000; //Low byte, mode 0, no BCD
        datareg = 8'd10;
        #500;
    end
    
    //semaforo
    assign databus = (RW) ? 8'bZ : datareg;
    
    
    
    counter COUNTER (
        .databus(databus), .addrbus(addr), .RWbus(RW),
        .clk(clk), .gate(gate), .out(out),
        .CWRmode(instruction), .read_back(RB)
    );
    defparam COUNTER.COUNTER_ID = 2'b00;
    
    //fili d'osservazione dei collegamenti interni
    wire write_high = COUNTER.write_high;
    wire write_low = COUNTER.write_low;
    wire CR_reset = COUNTER.CR_reset;
    wire start_count = COUNTER.start_count; 
    wire count_finished = COUNTER.count_finished;
    wire read_high = COUNTER.read_high;
    wire read_low = COUNTER.read_low;
    wire latch_high = COUNTER.latch_high;
    wire latch_low = COUNTER.latch_low;
    wire OL_reset = COUNTER.OL_reset; 
    wire null_count = COUNTER.null_count; 
    wire [7:0] ic_high = COUNTER.ic_high;
    wire [7:0] ic_low = COUNTER.ic_low;
    wire [7:0] oc_high = COUNTER.oc_high;
    wire [7:0] oc_low = COUNTER.oc_low;
    
    //fili d'osservazione di CL
    wire RW_high = COUNTER.CL.RW_high;
    wire RW_low = COUNTER.CL.RW_low;
    wire [2:0] mode = COUNTER.CL.mode;
    wire BCD = COUNTER.CL.BCD;
    wire COUNT_ = COUNTER.CL.COUNT_;
    wire STATUS_ = COUNTER.CL.STATUS_;
    wire half_write = COUNTER.CL.half_write; //1=write_low eseguito, 0=write_high eseguito;
    wire write_completed = COUNTER.CL.write_completed;
endmodule