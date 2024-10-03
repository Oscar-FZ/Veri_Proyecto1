`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Inclusión de los archivos del proyecto (evita la compilación individual)
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
`include "Library.sv"
`include "transactions.sv"
`include "driver_monitor.sv"
`include "checker.sv"
`include "scoreboard.sv"
`include "agente.sv"
`include "ambiente.sv"
`include "test.sv"


module DUT_TB();
    `include "parametros_test.sv" // Inclusión de los parámetros aleatorizados
    bit CLK_100MHZ;
	parameter WIDTH = 16;
	parameter PERIOD = 2;

    test #(.bits(bits), .drvrs(drvrs), .pckg_sz(pckg_sz), .broadcast(broadcast)) t0; // Declaración de la prueba
	
    bus_if #(.bits(bits), .drvrs(drvrs), .pckg_sz(pckg_sz)) _if (.clk(CLK_100MHZ)); // Declaración de la interfaz con el reloj externo
    always #(PERIOD/2) CLK_100MHZ = ~CLK_100MHZ; // Periodo de reloj

    bs_gnrtr_n_rbtr #(.bits(bits), .drvrs(drvrs), .pckg_sz(pckg_sz), .broadcast(broadcast)) bus_DUT
    (
    	.clk    (_if.clk),	    //Input
    	.reset  (_if.reset),    //Input
    	.pndng  (_if.pndng),    //Input
    	.push   (_if.push),	    //Output
    	.pop    (_if.pop),	    //Output
    	.D_pop  (_if.D_pop),    //Input
    	.D_push (_if.D_push)    //Output
    );

    initial begin
        CLK_100MHZ = 0;
        t0 = new(); // Constructor del test
        t0._if = _if;

        for (int i = 0; i < drvrs; i++) begin
            t0.ambiente_inst.driver_monitor_inst.strt_dm[i].dm_hijo.vif = _if; // Conexión de la interfaz de cada dispositivo en conectado al bus
        end
         #1;
        _if.reset = 1; // Reiinicio del bus
        #1;
        _if.reset = 0;

        fork
            t0.run(); // Inicio del test  
        join_none
    end

    always @(posedge CLK_100MHZ) begin
        if ($time > 100000000) begin
            $display("Tiempo limite del testbench alcanzado");
            $finish;
        end
    end

endmodule
