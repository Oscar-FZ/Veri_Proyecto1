`timescale 1ns / 1ps
`include "Library.sv"
`include "transactions.sv"
`include "driver_monitor.sv"
`include "agente.sv"
`include "ambiente.sv"
`include "test.sv"

module DUT_TB();
    bit CLK_100MHZ;
	parameter WIDTH = 16;
	parameter PERIOD = 2;
	parameter bits = 1;
	parameter drvrs = 4;
	parameter pckg_sz =16;
	parameter broadcast = {8{1'b1}};

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
        t0.ambiente_inst.driver_monitor_inst.vif = _if;
        fork
            t0.run();   
        join_none
        #1;
        _if.reset = 1;
        #1;
        _if.reset = 0;
    end

    always @(posedge CLK_100MHZ) begin
        if ($time > 100000) begin
            $display("Tiempo limite del testbench alcanzado");
            $finish;
        end
    end
    //strt_drvr_mntr #(.bits(bits), .drvrs(drvrs), .pckg_sz(pckg_sz)) driver_monitor_inst;

    //
    //agent #(.bits(bits), .drvrs(drvrs), .pckg_sz(pckg_sz), .broadcast(broadcast)) agent_inst; //Primero va el nombre de la clase
    //
    
    //bus_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) agnt_drvr_mbx[drvrs];
    //bus_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) drvr_chkr_mbx;
    //bus_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) mntr_chkr_mbx;
    //
    //instr_pckg_mbx test_agent_mbx;
    //

    //instruccion tipo;

    //bus_pckg #(.drvrs(drvrs), .pckg_sz(pckg_sz)) trans[8]; //WHAT THE FUCK IS THIS???
    //bus_pckg #(.drvrs(drvrs), .pckg_sz(pckg_sz)) transaccion;

    //int max_retardo = 20;

    //bus_if #(.bits(bits), .drvrs(drvrs), .pckg_sz(pckg_sz)) _if (.clk(CLK_100MHZ));
	


	

	//initial begin 
		//CLK_100MHZ = 0;
        
        
        //for (int i = 0; i<drvrs; i++) begin
            //agnt_drvr_mbx[i] = new();
        //end

        //drvr_chkr_mbx = new();
        //mntr_chkr_mbx = new();
        //test_agent_mbx = new();

        //$display("INICIO");
        //driver_monitor_inst = new();
        //
        //agent_inst = new();
        //agent_inst.test_agent_mbx = test_agent_mbx; 
        //


        //for (int i = 0; i<drvrs; i++) begin
        //    $display("[%d]",i);
        //    driver_monitor_inst.strt_dm[i].dm_hijo.vif = _if;
        //    driver_monitor_inst.strt_dm[i].agnt_drvr_mbx[i] = agnt_drvr_mbx[i];
        //    driver_monitor_inst.strt_dm[i].drvr_chkr_mbx = drvr_chkr_mbx;
        //    driver_monitor_inst.strt_dm[i].mntr_chkr_mbx = mntr_chkr_mbx;
            //
        //    agent_inst.agnt_drvr_mbx[i] = agnt_drvr_mbx[i];
            //
        //    #1;
        //end

       // _if.reset = 1;
        //#1;
       // _if.reset = 0;

        //fork
            //
        //    agent_inst.run_agent();
            //
        //    driver_monitor_inst.start_driver();
        //    driver_monitor_inst.start_monitor();  
        //join_none

        //#10;
        //$display("[%g]  Enviando instruccion al agente",$time);
        //tipo = broadcast;
       // test_agent_mbx.put(tipo); 

        //#10000;
		//$finish;
	//end

    //initial begin
        //$dumpfile("prueba.vcd");
        //$dumpvars(0, DUT_TB);
    //end
    
endmodule
