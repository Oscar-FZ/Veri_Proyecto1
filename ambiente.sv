    class ambiente #(parameter bits = 1, parameter drvrs = 4, parameter pckg_sz = 16, parameter broadcast = {8{1'b1}});
    //Declaración de los componentes del ambiente
    //Declaración del driver/monitor
    strt_drvr_mntr #(.bits(bits), .drvrs(drvrs), .pckg_sz(pckg_sz), .broadcast(broadcast)) driver_monitor_inst;
    //Declaración del agente
    agent #(.bits(bits), .drvrs(drvrs), .pckg_sz(pckg_sz), .broadcast(broadcast)) agent_inst;
    //checker
    my_checker #(.bits(bits), .drvrs(drvrs), .pckg_sz(pckg_sz), .broadcast(broadcast)) checker_inst;
    //scoreboard
    scoreboard #(.bits(bits), .drvrs(drvrs), .pckg_sz(pckg_sz), .broadcast(broadcast)) scoreboard_inst; 
    //etc

    //Declaración de la interfaz que conecta al DUT
    virtual bus_if #(.bits(bits), .drvrs(drvrs), .pckg_sz(pckg_sz)) _if; 

    //Declaración de los mailboxes
    bus_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) agnt_drvr_mbx[drvrs]; //Mailbox del agente a los drivers
    bus_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) drvr_chkr_mbx;        //Mailbox de los drivers al checker
    bus_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) mntr_chkr_mbx;        //Mailbox de los monitores al checker
    instr_pckg_mbx test_agent_mbx;                                         //Mailbox del test al agente
    sb_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) chkr_sb_mbx;           //Mailbox del checker al scoreboard
    //U know >:)
    test_type test_sb_mbx;
    trans_data agnt_chkr_mbx;

    function new();
        //Instanciación de los mailboxes
        drvr_chkr_mbx = new();
        mntr_chkr_mbx = new();
        test_agent_mbx = new();
        chkr_sb_mbx = new();
        //U know >:)
        agnt_chkr_mbx = new();
        test_sb_mbx = new();
        

        for (int i = 0; i < drvrs; i++) begin
            agnt_drvr_mbx[i] = new();
        end

        //Instanciación de los componentes del ambiente
        $display("Instanciando componentes del ambiente");
        driver_monitor_inst = new();
        agent_inst = new();
        checker_inst = new();
        scoreboard_inst = new();

        //Conexión de las interfaces y mailboxes en el ambiente
        agent_inst.test_agent_mbx = test_agent_mbx;
        agent_inst.agnt_chkr_mbx = agnt_chkr_mbx;

        checker_inst.drvr_chkr_mbx = drvr_chkr_mbx;
        checker_inst.mntr_chkr_mbx = mntr_chkr_mbx;
        checker_inst.chkr_sb_mbx = chkr_sb_mbx;

        //And again here
        checker_inst.agnt_chkr_mbx = agnt_chkr_mbx;
        scoreboard_inst.test_sb_mbx = test_sb_mbx;
        scoreboard_inst.chkr_sb_mbx = chkr_sb_mbx;

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
            checker_inst.update();
            checker_inst.check();
            checker_inst.update_cant_trans();
            scoreboard_inst.run();
        join_none
    endtask
endclass
