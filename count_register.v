module count_register(
    input [7:0] databus, //connessioni ai bus
    input write, //istruzione di avvio scrittura da Control Logic
    input reset, //porta CR a 0 in caso di nuova programmazione
    output [7:0] initial_count //output verso CE
);

    reg [7:0] CR;
    initial CR <= 8'b0;
    
    always @(posedge write) CR <= databus;
        
    always @(posedge reset) CR <= 8'b0;

    assign initial_count = CR;
endmodule