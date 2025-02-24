`timescale 1ns/1ps

module control_logic (
    //indirizzo del contatore di appartenenza
    input [1:0] COUNTER_ID,
    //porte con l'esterno
    input clk,
    input gate,
    output reg out,
    //porte per le istruzioni provenienti dal Control Word Register
    input [5:0] CWR, //CWR[5:4]=high/low byte; CWR[3:1]=mode; CWR[0]=BCD
    input [1:0] readback, //readback[1]=COUNT_; readback[0]=STATUS_
    //porte per osservare i bus
    input [7:0] databus,
    input [1:0] addrbus,
    input       RWbus, //0=scrittura; 1=lettura
    //fili di controllo CR
    output reg write_high,
    output reg write_low,
    output reg CR_reset,
    //fili di controllo CE
    output reg start_count,
    input count_finished, //=1 se CE raggiunge zero
    //fili di controllo OL
    output reg read_high,
    output reg read_low,
    output reg latch_high,
    output reg latch_low,
    output reg OL_reset,
    //per registro STATUS
    output reg null_count //0=CR loaded in CE; 1=new control word / new content in CR
);

    //registri interni
    reg RW_high;
    reg RW_low;
    reg [2:0] mode;
    reg BCD;
    reg COUNT_, STATUS_;

    //flag booleani
    reg half_write; //1=write_low eseguito, 0=write_high eseguito;
    reg write_completed; //1=scrittura su CR terminata; 0=scrittura in corso


    /*gestione nuova istruzione*/
    always @(CWR) begin
        //caricamento istruzione
        RW_high = CWR[5];
        RW_low = CWR[4];
        mode = CWR[3:1];
        BCD = CWR[0];
        
        //reset dei flag booleani
        half_write = 0;
        write_completed = 0;

        //reset delle uscite
        out = 0;
        write_high = 0;
        write_low = 0;
        start_count = 0;
        read_high = 0;
        read_low = 0;
        latch_high = 0;
        latch_low = 0;
        null_count = 1;
        OL_reset = 1;
        CR_reset = 1;
        #1 OL_reset = 0;
        CR_reset = 0;
    end

    always @(readback) begin
        COUNT_ <= readback[1];
        STATUS_ <= readback[0];
    end
    /* * * * * * * * * * * * * * * * */


    /* gestione operazioni di scrittura e lettura */
    always @(databus or addrbus or RWbus) begin
        //operazioni di scrittura su CR
        if (addrbus == COUNTER_ID && RWbus==0 && (RW_low || RW_high)) begin
            write_completed = 0;
            null_count = 1;
            case ({RW_low, RW_high})
                2'b10: begin //write_low
                    write_low = 1;
                    #1 write_low = 0;
                    write_completed = 1;
                end
                2'b10: begin //write_high
                    write_high = 1;
                    #1 write_high = 0;
                    write_completed = 1;
                end
                2'b11: begin //write_low then write_high
                    if (half_write==0) begin
                        write_low = 1;
                        #1 write_low = 0;
                        half_write = 1;
                    end else begin //if (half_write==1)
                        write_high = 1;
                        #1 write_high = 0;
                        half_write = 0;
                        write_completed = 1;
                    end
                end
                default:; //counter_latch command
            endcase
        end

        //operazioni di lettura da OL
        if (addrbus == COUNTER_ID && RWbus == 1) begin
            case ({RW_low, RW_high})
                2'b10: begin //read_low
                    read_low = 1;
                    #1 read_low = 0;
                end
                2'b01: begin //read_high
                    read_high = 1;
                    #1 read_high = 0;
                end
                2'b11: begin //read_low then read_high
                    read_low = 1;
                    #1 read_low = 0;
                    read_high = 1;
                    #1 read_high = 0;
                end
                default:; //nessuna lettura
            endcase
        end
    end
    /* * * * * * * * * * * * * * * * */


    /* generazione segnale di inizio conteggio */
    //(quando la scrittura in CR è completata)
    always @(negedge clk) begin
        if (write_completed) begin
            start_count = 1;
            null_count = 0;
            #1 start_count = 0;
            write_completed = 0;
        end
    end

    //DEBUG
    always @(posedge count_finished) begin
        out = 1;
        #10 out = 0;
    end

endmodule