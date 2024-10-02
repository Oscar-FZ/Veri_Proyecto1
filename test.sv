class test #(parameter bits = 1, parameter drvrs = 4, parameter pckg_sz = 16, parameter broadcast = {8{1'b1}});
    //randomizer #(.drvrs(drvrs), .pckg_sz(pckg_sz)) aleatorizacion;
    instr_pckg_mbx test_agent_mbx;

    //Mailbox para pasarle el tipo de prueba al scoreboard
    test_type test_sb_mbx;
    trans_data sb_test_flag_mbx;

    //Definición del ambiente de la prueba
    ambiente #(.bits(bits), .drvrs(drvrs), .pckg_sz(pckg_sz), .broadcast(broadcast)) ambiente_inst;

    //Definición de la interfaz para conectar el DUT
    virtual bus_if #(.bits(bits), .drvrs(drvrs), .pckg_sz(pckg_sz)) _if;

    instruccion trans_agente;
    string tipo_test;

    int flag;

    //Definición de las condiciones iniciales del test.
    function new();
        flag = 0;
        //Instanciación de los mailboxes
        test_agent_mbx = new();
        
        //Instancia del mailbox de test_sb para pasarle el tipo de test
        test_sb_mbx = new();
        sb_test_flag_mbx = new();

        //Definición y conexión del driver
        ambiente_inst = new();
        ambiente_inst._if = _if;
        ambiente_inst.test_agent_mbx = test_agent_mbx;
        ambiente_inst.agent_inst.test_agent_mbx = test_agent_mbx;

        //You already know
        //ambiente_inst.checker_inst.test_checker_mbx = test_checker_mbx;
        ambiente_inst.scoreboard_inst.test_sb_mbx = test_sb_mbx;
        ambiente_inst.scoreboard_inst.sb_test_flag_mbx = sb_test_flag_mbx;

        //Valores que usa el agente
        //ambiente_inst.agent_inst.ret_spec = //TODO
        //ambiente_inst.agent_inst.info_spec = //TODO
        //ambiente_inst.agent_inst.tpo_spec = //TODO
        //ambiente_inst.agent_inst.dsp_spec = //TODO
        //ambiente_inst.agent_inst.dir_spec = //TODO
        //Tal vez agregar max retardo
    endfunction

    task run;
        $display("[%g] Test inicializado", $time);
        fork
            ambiente_inst.run();
        join_none

        //Prueba de envío de paquetes aleatorios
        //aleatorizacion = new;
        //aleatorizacion.randomize();
        //ambiente_inst.agent_inst.cant_trans = aleatorizacion.num_trans;
        //-------------------------------------------------------------------------------------------
        trans_agente = aleatorio;
        tipo_test = "Aleatorio";
        test_agent_mbx.put(trans_agente);
        test_sb_mbx.put(tipo_test);
        $display("[%g] Test: Enviada la instrucción de transacción aleatoria", $time);
        //--------------------------------------------------------------------------------------------
        
        sb_test_flag_mbx.get(flag);
        //Prueba de envío de paquetes broadcast
        ambiente_inst.agent_inst.cant_trans = 2;
        trans_agente = broadcast;
        tipo_test = "Broadcast";
        test_agent_mbx.put(trans_agente);
        test_sb_mbx.put(tipo_test);
        $display("[%g] Test: Enviada la instrucción de transacción broadcast", $time);
        
        sb_test_flag_mbx.get(flag);
        $finish;

        //Reset
        //aleatorizacion = new;
        //aleatorizacion.randomize();
        //aleatorizacion.print("pvto");

        //Todos los dispositivos envian con retraso 0


        //Max alt


        //Prueba de envío de paquetes hacia dispositivos inexistentes
        //aleatorizacion = new;
        //aleatorizacion.randomize();
        //ambiente_inst.agent_inst.cant_trans = 5; //For the moment
        //ambiente_inst.agent_inst.dir_spec = aleatorizacion.wrong_addr;
        //trans_agente = dir_inex; //Might have to create a new trans type
        //test_agent_mbx.put(trans_agente);
        //$display("[%g] Test: Enviada la instrucción de envío hacia dispositivos inexistentes", $time);
        //Cuando la dirección no existe nunca se le hace un push a ninguna FIFO para recibir el dato. Al dato si se le hace pop y si aparece en D_pop y D_push


        //Prueba de envío de paquetes hacia el mismo dispositivo de salida
        //trans_agente = mismo_disp;
        //test_agent_mbx.put(trans_agente);
        //$display("[%g] Test: Enviada la instrucción de envío hacia el mismo dispositivo", $time);
        //Cuando se envía al mismo dispositivo nunca se le hace un push a ninguna FIFO para recibir el dato. Al dato si se le hace pop y si aparece en D_pop y D_push

        #100000;
        $display("[%g] Test: Se alcanzó el tiempo límite de la prueba", $time);
        #20;
        $finish;
    //TODO
    //Envio de paquetes aleatorios, envio de paquetes broadcast, envio de reset, 
    //paquetes aleatorios desde diferentes disp. al mismo tiempo,
    //maxima alternancia, hacia dispositivo inexistente, desde y hacia el mismo disp.
    endtask
endclass
