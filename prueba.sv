`timescale 1ns / 1ps
`include "Library.sv"
`include "transactions.sv"
`include "driver_monitor.sv"
`include "checker.sv"
`include "scoreboard.sv"
`include "agente.sv"
`include "ambiente.sv"
`include "test.sv"


module DUT_TB();
    `include "parametros_test.sv"
    bit CLK_100MHZ;
	parameter WIDTH = 16;
	parameter PERIOD = 2;
	//parameter bits = 1;
	//parameter drvrs = 4;
	//parameter pckg_sz = 16;
	//parameter broadcast = {8{1'b1}};


    test #(.bits(bits), .drvrs(drvrs), .pckg_sz(pckg_sz), .broadcast(broadcast)) t0;
	
    bus_if #(.bits(bits), .drvrs(drvrs), .pckg_sz(pckg_sz)) _if (.clk(CLK_100MHZ));
    always #(PERIOD/2) CLK_100MHZ = ~CLK_100MHZ;

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
        t0 = new();
        t0._if = _if;

        for (int i = 0; i < drvrs; i++) begin
            t0.ambiente_inst.driver_monitor_inst.strt_dm[i].dm_hijo.vif = _if;
        end
         #1;
        _if.reset = 1;
        #1;
        _if.reset = 0;

        fork
            t0.run();   
        join_none
    end

    //    driver_monitor_inst.strt_dm[i].dm_hijo.vif = _if;

    always @(posedge CLK_100MHZ) begin
        if ($time > 100000000) begin
            $display("Tiempo limite del testbench alcanzado");
            $finish;
        end
    end

    initial begin
        $dumpvars;
        $dumpfile("dump.vcd");
    end
endmodule
