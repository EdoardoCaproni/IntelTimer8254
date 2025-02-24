`timescale 1ns/1ps

module testbench;
    //variabili di porta
    reg [7:0] datareg; //contiene la sequenza di dati per la porta D
    wire [7:0] datawire; //conterrà datareg se (chipselect_==0 and (write_==0 xor read_==0))
    reg write_, read_, chipselect_;
    reg [1:0] address;
    reg clk0 = 0, gate0;
    wire out0;
    reg clk1 = 0, gate1;
    wire out1;
    reg clk2 = 0, gate2;
    wire out2;
    
    //velocizzazione digitazione parole di controllo: scegliere un parametro di ogni lista
    parameter [1:0] C0 = 2'b00, C1 = 2'b01, C2 = 2'b10;
    parameter [1:0] L = 2'b01, H = 2'b10, HL = 2'b11;
    parameter [2:0] M0 = 3'b000, M1 = 3'b001, M2 = 3'b010, M3 = 3'b011, M4 = 3'b100, M5 = 3'b101;
    parameter BCD = 1'b1, BIN = 1'b0;
    //esempio: datareg = {C0, L, M0, BIN}
    
    //velocizzazione digitazione counter latch command: scegliere contatore e poi aggiungere CL
    parameter [5:0] CL = 6'b00XXXX;
    //esempio: datareg = {C1, CL}
    
    //velocizzazione digitazione read back command: scegliere una voce per ogni campo
    parameter [1:0] RB = 2'b11;
    parameter COUNT_ = 1'b1, COUNT = 1'b0;
    parameter STATUS_ = 1'b1, STATUS = 1'b0;
    parameter CNT2 = 1'b1, CNT2_ = 1'b0;
    parameter CNT1 = 1'b1, CNT1_ = 1'b0;
    parameter CNT0 = 1'b1, CNT0_ = 1'b0;
    parameter END = 1'b0;
    //esempio: datareg = {RB, COUNT, STATUS, CNT2_, CNT1, CNT0, END}
    
    //velocizzazione digitazione di address: C0, C1, C2 già presenti
    parameter [1:0] CWR = 2'b11;
    
    
    //Programmazione clock
    always begin
        #5 clk0 <= !clk0;
    end

    always begin
        #7 clk1 <= !clk1;
    end

    always begin
        #13 clk2 <= !clk2;
    end



    //Segnali di test
    initial begin
        chipselect_ <= 1;
        write_ <= 1;
        read_ <= 1;
        datareg <= 8'b0;
    end

    initial #10 begin
        /* TEST 1: programmazione semplice su C0, con successiva scrittura e lettura */
        #1 chipselect_ = 0;
        #1 write_ = 0;
        #1 address = CWR;
        #1 datareg = {C0, L, M0, BIN};
        
        #1 address = C0;
        #1 datareg = 8'd10; //NB specifico di usare 8 bit, ma in notazione DECIMALE!
        #1 write_ = 1;
        
        //tento una lettura a mezza esecuzione, ci aspettiamo una cosa tipo 4, 5, o 6
        #50;
        read_ = 0;
        #2 read_ = 1;
        $stop;
        
        //attendo la terminazione del conteggio e poi faccio un'altra lettura (mi aspetto 0)
        #60;
        read_ = 0;
        #2 read_ = 1;
        
        $stop;
    end

    //semaforo per la porta D
    assign datawire = (read_==1 && write_==0 && chipselect_==0) ? datareg :
                      (read_==0 && write_==1 && chipselect_==0) ? 'bZ : 'bZ;

    timer8254 TIMER(
        .D(datawire), ._WR(write_), ._RD(read_), ._CS(chipselect_), .A(address),
        .CLK_0(clk0), .OUT_0(out0), .GATE_0(gate0),
        .CLK_1(clk1), .OUT_1(out1), .GATE_1(gate1),
        .CLK_2(clk2), .OUT_2(out2), .GATE_2(gate2)
    );

    wire [7:0] w_databus = TIMER.data_bus;
    wire [1:0] w_addrbus = TIMER.addr_bus;
    wire w_RWbus = TIMER.RW_bus;

    wire [5:0] w_C0_instruction = TIMER.C0_instruction;
    wire [5:0] w_C1_instruction = TIMER.C1_instruction;
    wire [5:0] w_C2_instruction = TIMER.C2_instruction;
    wire [1:0] w_C0_readback = TIMER.C0_readback;
    wire [1:0] w_C1_readback = TIMER.C1_readback;
    wire [1:0] w_C2_readback = TIMER.C2_readback;
    
    wire [1:0] w_destination = TIMER.CWR.destination;
    wire [5:0] w_instruction = TIMER.CWR.instruction;
endmodule
