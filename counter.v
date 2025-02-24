module counter #(
    parameter [1:0] COUNTER_ID=2'bXX //COUNTER_ID è da riempire (in chiamata) con l'indirizzo dell'istanza
) (
    //connessioni all'esterno
    input clk,
    input gate,
    output out,

    //connessioni con il bus interno
    inout [7:0] databus,
    input [1:0] addrbus,
    input RWbus, //0=scrittura; 1=lettura

    //connessioni dirette verso il CWR
    input [5:0] CWRmode, //modalità di utilizzo
    input [1:0] read_back //segnale di read_back
);

    //registri: Status Register TODO
    
    //semaforo per databus 
    wire [7:0] datain, dataout;
    assign datain = (RWbus==0) ? databus : 8'bZ;
    assign databus = (RWbus==1) ? dataout : 8'bZ;
   

    /* connessioni tra i moduli interni */
    wire write_high, write_low; //CWR->CR
    wire CR_reset;              //CWR->CR
    wire start_count;           //CWR->CE
    wire count_finished;        //CWR<-CE
    wire read_high, read_low;   //CWR->OL
    wire latch_high, latch_low; //CWR->OL
    wire OL_reset;              //CWR->OL
    wire null_count;            //CWR->STATUS
    wire [7:0] ic_high, ic_low; //CR->CE
    wire [7:0] oc_high, oc_low; //CE->OL
    /* * * * * * * * * * * * * * * * * */


    //control logic
    control_logic CL(
        .COUNTER_ID(COUNTER_ID),
        .clk(clk), .gate(gate), .out(out),
        .databus(datain), .addrbus(addrbus), .RWbus(RWbus),
        .CWR(CWRmode), .readback(read_back),
        .write_high(write_high), .write_low(write_low),
        .start_count(start_count), .count_finished(count_finished),
        .read_high(read_high), .read_low(read_low),
        .latch_high(latch_high), .latch_low(latch_low),
        .OL_reset(OL_reset), .CR_reset(CR_reset),
        .null_count(null_count)
    );

    count_register CRm(
        .databus(datain),
        .write(write_high),
        .reset(CR_reset),
        .initial_count(ic_high)
    ), CRl(
        .databus(datain),
        .write(write_low),
        .reset(CR_reset),
        .initial_count(ic_low)
    );

    counting_element CE (
        .clk(clk),
        .start_count(start_count),
        .initial_count_high(ic_high), .initial_count_low(ic_low),
        .output_count_high(oc_high), .output_count_low(oc_low),
        .count_end(count_finished)
    );
    
    output_latch OLm(
        .current_count(oc_high),
        .read(read_high), .reset(OL_reset),
        .latch_command(latch_high),
        .databus(dataout)
    ), OLl(
        .current_count(oc_low),
        .read(read_low), .reset(OL_reset),
        .latch_command(latch_low),
        .databus(dataout)
    );
endmodule