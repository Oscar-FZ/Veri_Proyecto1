    class ambiente #(parameter bits = 1, parameter drvrs = 4, parameter pckg_sz = 16, parameter broadcast = {8{1'b1}});
    //Declaración de los componentes del ambiente
    //Declaración del driver/monitor
    strt_drvr_mntr #(.bits(bits), .drvrs(drvrs), .pckg_sz(pckg_sz)) driver_monitor_inst;
    //Declaración del agente
    agent #(.bits(bits), .drvrs(drvrs), .pckg_sz(pckg_sz), .broadcast(broadcast)) agent_inst;
    //checker
    //scoreboard
    //etc

    //Declaración de la interfaz que conecta al DUT
    virtual bus_if #(.bits(bits), .drvrs(drvrs), .pckg_sz(pckg_sz)) _if; //TODO

    //Declaración de los mailboxes
    bus_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) agnt_drvr_mbx[drvrs]; //Mailbox del agente a los drivers
    bus_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) drvr_chkr_mbx;        //Mailbox de los drivers a los checkers
    bus_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) mntr_chkr_mbx;        //Mailbox de los checkers al monitor
    instr_pckg_mbx test_agent_mbx;                                         //Mailbox del test al agente

    function new();
        //Instanciación de los mailboxes
        drvr_chkr_mbx = new();
        mntr_chkr_mbx = new();
        test_agent_mbx = new();

        for (int i = 0; i < drvrs; i++) begin
            agnt_drvr_mbx[i] = new();
        end

        //Instanciación de los componentes del ambiente
        $display("Instanciando componentes del ambiente");
        driver_monitor_inst = new();
        agent_inst = new();

        //Conexión de las interfaces y mailboxes en el ambiente
        agent_inst.test_agent_mbx = test_agent_mbx;

        for (int i = 0; i<drvrs; i++) begin
            $display("[%d]",i);
            driver_monitor_inst.strt_dm[i].dm_hijo.vif = _if;
            driver_monitor_inst.strt_dm[i].agnt_drvr_mbx[i] = agnt_drvr_mbx[i];
            driver_monitor_inst.strt_dm[i].drvr_chkr_mbx = drvr_chkr_mbx;
            driver_monitor_inst.strt_dm[i].mntr_chkr_mbx = mntr_chkr_mbx;
            agent_inst.agnt_drvr_mbx[i] = agnt_drvr_mbx[i];
        end    
    endfunction

    virtual task run();
        $display("[%g] El ambiente fue inicializado", $time);
        fork
            driver_monitor_inst.start_driver();
            driver_monitor_inst.start_monitor();
            agent_inst.run_agent();
        join_none
    endtask
endclass
