module output_latch (
    input [7:0] current_count,
    input latch_command,
    input read,     //read==1 => manda OL dentro databus
    input reset,    //serve a slacciare manualmente OL (in caso di nuova programmazione del contatore)
    output reg [7:0] databus
);
    reg [7:0] OL;
    reg latched; //flag per indicare se OL è stato allacciato
    initial begin
        latched = 0;
        databus = 8'bZ;
    end
    
    always @(current_count or latch_command) begin
        //se OL viene allacciato, non leggere nuovi valori
        if (latch_command==1)
            latched = 1;
        //se OL non è allacciato, effettua una lettura costante
        else if (latched==0)
            OL = current_count;
        
    end
    
    //gestione del deallacciamento
    always @(read or reset) begin
        if (read || reset)
            latched = 0;
    end
    
    //NB: separare l'assegnazione su latched in due blocchi procedurali separati
    //potrebbe portare a situazioni in cui latched diventa X (esempio: read==1 && latch_command==1).
    //Però latch_command è un comando che non può avvenire nello stesso istante
    //di read oppure reset, quindi CL non creerà mai una situazione di collisione.
    
    //uscita su databus
    always @(read) begin
        if (read==1)
            databus = OL;
        else
            databus = 8'bZ;
    end

endmodule