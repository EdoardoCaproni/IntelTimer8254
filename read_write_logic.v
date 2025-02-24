module read_write_logic (
   input _CS,      //_CS = chip select. Se _CS=0 allora _RD e _WR sono abilitati
   input _RD,      //_RD  = read. Quando _RD=0, (se CS lo consente), abilita la lettura dai contatori nel buffer (non dal Control Word Register)
   input _WR,      //_WR = write. Esclusivo con _RD. Quando _WR=0 (se CS lo consente), abilita la scrittura dal buffer data nel bus dati
   input [1:0] A,  //A = address. Indica quale componente è la destinazione di lettura/scrittura (00 = C0, 01=C1, 10=C2, 11=CWR)
   output [1:0] Add_bus, //Add_bus = address bus. Conterrà l'indirizzo selezionato; va al bus di indirizzi.
   output RW_bus   //RW_bus = read/write bus. Conterrà 1 se _RD è attivo, 0 se _WR è attivo; va al bus di controllo
   );
   
   assign Add_bus = (_CS==0) ? A : 'bZ;
   
   assign RW_bus = (_CS==0 && _RD==1 && _WR==0) ? 0 : //Scrittura = 0
                   (_CS==0 && _RD==0 && _WR==1) ? 1 : //Lettura   = 1
                   1'bZ;                              //Altro     = Z
endmodule

