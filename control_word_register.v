module control_word_register (
    //connessioni ai bus
    input [7:0] databus,
    input [1:0] addrbus,
    input       RW_signal, //0 scrittura, 1 lettura
    //uscite di programmazione contatori
    output reg [5:0] C0_program,
    output reg [5:0] C1_program,
    output reg [5:0] C2_program,
    //comandi di readback per i contatori: X[1]=COUNT_; X[0]=STATUS_
    output reg [1:0] C0_readback,
    output reg [1:0] C1_readback,
    output reg [1:0] C2_readback
);

    reg [1:0] destination;  //ControlWord[7:6]
    reg [5:0] instruction;  //ControlWord[5:0]

    always @(databus or addrbus or RW_signal) begin
        //salvataggio della control word
        if (addrbus==2'b11 && RW_signal==0) begin
            //IMPORTANTE: queste due DEVONO essere assegnazioni bloccanti
            //perché devono avvenire PRIMA delle operazioni sotto
            destination = databus[7:6];
            instruction = databus[5:0];

            //indirizzamento dell'istruzione
            case (destination)
                2'b00: C0_program <= instruction;
                2'b01: C1_program <= instruction;
                2'b10: C2_program <= instruction;
                //gestione del comando di readback (destination==2'b11)
                default: if (instruction[0]==0) begin
                    if (instruction[1]==1) C0_readback <= instruction[5:4];
                    if (instruction[2]==1) C1_readback <= instruction[5:4];
                    if (instruction[3]==1) C2_readback <= instruction[5:4];
                end
            endcase
            
            //inibizione del readback command se non selezionato
            if (destination != 2'b11) begin
                C0_readback <= 2'b11;
                C1_readback <= 2'b11;
                C2_readback <= 2'b11;
            end
        end
    end
endmodule
