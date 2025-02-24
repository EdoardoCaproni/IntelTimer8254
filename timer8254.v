module timer8254 (
    inout [7:0] D, //parola di controllo oppure numero di partenza del conteggio

    input _WR, //se _WR = 0 allora scrivi (in D) il dato da spedire all'indirizzo A
    input _RD, //se _RD = 0 allora leggi (da D) il dato all'indirizzo A (tranne A=11)
    input _CS, //se _CS = 0 allora abilita operazioni di lettura/scrittura
    input [1:0] A, //indirizzo: 00=C0, 01=C1, 10=C2, 11=CWR

    input CLK_0, //clock del contatore 0
    input GATE_0, //controllo del contatore 0
    output OUT_0, //uscita del contatore 0

    input CLK_1, //clock del contatore 1
    input GATE_1, //controllo del contatore 1
    output OUT_1, //uscita del contatore 1

    input CLK_2, //clock del contatore 2
    input GATE_2, //controllo del contatore 2
    output OUT_2 //uscita del contatore 2
);

    //fili per il bus interno
    wire [7:0] data_bus;
    wire [1:0] addr_bus;
    wire RW_bus; //0=scrittura; 1=lettura
    
    //connessione CWR->contatore
    wire [5:0] C0_instruction, C1_instruction, C2_instruction;
    wire [1:0] C0_readback, C1_readback, C2_readback;
    

    /* data_bus_buffer: */
    reg [7:0] datareg, Dreg; //servono come buffer che raddoppiano data_bus e D
    initial begin
        datareg = 8'bZ;
        Dreg = 8'bZ;
    end
    
    always @(D or data_bus or RW_bus) begin
        if (RW_bus==0) begin //scrittura
            Dreg = 8'bZ;
            datareg = D;
        end else begin //lettura
            datareg = 8'bZ;
            Dreg = data_bus;
        end
        if (RW_bus===1'bZ || RW_bus===1'bX) begin //situazione anomala
            datareg = 8'bZ;
            Dreg = 8'bZ;
        end
    end
    
    assign data_bus = datareg;

    assign D = Dreg;
    
    
    /* * * * * * * * * */


    /* read_write_logic */
    read_write_logic RWL(
        ._CS(_CS), ._RD(_RD), ._WR(_WR), .A(A),
        .Add_bus(addr_bus), .RW_bus(RW_bus)
    );
    /* * * * * * * * * */
    
    /* control_word_register */
    control_word_register CWR(
      .databus(data_bus), .addrbus(addr_bus), .RW_signal(RW_bus),
      .C0_program(C0_instruction), .C0_readback(C0_readback),
      .C1_program(C1_instruction), .C1_readback(C1_readback),
      .C2_program(C2_instruction), .C2_readback(C2_readback)
    );
    /* * * * * * * * * * * * */



    
    counter C0 (
        .clk(CLK_0), .gate(GATE_0), .out(OUT_0),
        .databus(data_bus), .addrbus(addr_bus), .RWbus(RW_bus),
        .CWRmode(C0_instruction), .read_back(C0_readback)
    );
    defparam C0.COUNTER_ID = 2'b00;
    
    counter C1(
        .clk(CLK_1), .gate(GATE_1), .out(OUT_1),
        .databus(data_bus), .addrbus(addr_bus), .RWbus(RW_bus),
        .CWRmode(C1_instruction), .read_back(C1_readback)
    );
    defparam C1.COUNTER_ID = 2'b01;
    
    counter C2(
        .clk(CLK_2), .gate(GATE_2), .out(OUT_2),
        .databus(data_bus), .addrbus(addr_bus), .RWbus(RW_bus),
        .CWRmode(C2_instruction), .read_back(C2_readback)
    );
    defparam C2.COUNTER_ID = 2'b10;

endmodule