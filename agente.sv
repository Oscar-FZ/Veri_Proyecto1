class agent #(parameter bits = 1, parameter drvrs = 4, parameter pckg_sz = 16, parameter broadcast = {8{1'b1}});
    bus_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) agnt_drvr_mbx[drvrs];
    instr_pckg_mbx test_agent_mailbox; //Mailbox del test al agente

    task run_agent;
        $display("[%g]  El Agente fue inicializado",$time);
        forever begin
            //mailbox del test al agente
        end
    endtask
endclass