class test #(parameter bits = 1, parameter drvrs = 4, parameter pckg_sz = 16, parameter broadcast = {8{1'b1}});
    randomizer #(.drvrs(drvrs), .pckg_sz(pckg_sz)) aleatorizacion;
    instr_pckg_mbx test_agent_mbx;

    //Definición del ambiente de la prueba
    ambiente #(.bits(bits), .drvrs(drvrs), .pckg_sz(pckg_sz), .broadcast(broadcast)) ambiente_inst;

    //Definición de la interfaz para conectar el DUT
    virtual bus_if #(.bits(bits), .drvrs(drvrs), .pckg_sz(pckg_sz)) _if;

    instruccion trans_agente;

    //Definición de las condiciones iniciales del test
    function new();
        //Instanciación de los mailboxes
        test_agent_mbx = new();

        //Definición y conexión del driver
        ambiente_inst = new();
        ambiente_inst._if = _if;
        ambiente_inst.test_agent_mbx = test_agent_mbx;
        ambiente_inst.agent_inst.test_agent_mbx = test_agent_mbx;

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
        aleatorizacion = new;
        aleatorizacion.randomize();
        ambiente_inst.agent_inst.cant_trans = aleatorizacion.num_trans;
        trans_agente = aleatorio;
        //test_agent_mbx.put(trans_agente);
        $display("[%g] Test: Enviada la instrucción de transacción aleatoria", $time);

        //Prueba de envío de paquetes broadcast
        ambiente_inst.agent_inst.cant_trans = 2;
        trans_agente = broadcast;
        //test_agent_mbx.put(trans_agente);
        $display("[%g] Test: Enviada la instrucción de transacción broadcast", $time);

        //Reset
        //aleatorizacion = new;
        //aleatorizacion.randomize();
        //aleatorizacion.print("pvto");

        //Diff disp


        //Max alt


        //Prueba de envío de paquetes hacia dispositivos inexistentes
        aleatorizacion = new;
        aleatorizacion.randomize();
        ambiente_inst.agent_inst.cant_trans = 5; //For the moment
        ambiente_inst.agent_inst.dir_spec = aleatorizacion.wrong_addr;
        trans_agente = dir_inex; //Might have to create a new trans type
        //test_agent_mbx.put(trans_agente);
        $display("[%g] Test: Enviada la instrucción de envío hacia dispositivos inexistentes", $time);
        //Cuando la dirección no existe nunca se le hace un push a ninguna FIFO para recibir el dato. Al dato si se le hace pop y si aparece en D_pop y D_push


        //Prueba de envío de paquetes hacia el mismo dispositivo de salida
        trans_agente = mismo_disp;
        test_agent_mbx.put(trans_agente);
        $display("[%g] Test: Enviada la instrucción de envío hacia el mismo dispositivo", $time);
        //Cuando se envía al mismo dispositivo nunca se le hace un push a ninguna FIFO para recibir el dato. Al dato si se le hace pop y si aparece en D_pop y D_push

        #10000;
        $display("[%g] Test: Se alcanzó el tiempo límite de la prueba", $time);
        #20;
        $finish;
    //TODO
    //Envio de paquetes aleatorios, envio de paquetes broadcast, envio de reset, 
    //paquetes aleatorios desde diferentes disp. al mismo tiempo,
    //maxima alternancia, hacia dispositivo inexistente, desde y hacia el mismo disp.
    endtask
endclass