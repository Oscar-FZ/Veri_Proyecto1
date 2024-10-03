class test #(parameter bits = 1, parameter drvrs = 4, parameter pckg_sz = 16, parameter broadcast = {8{1'b1}});
    // Definición de los mailboxes
    instr_pckg_mbx test_agent_mbx; // Mailbox para indicarle al agente la instrucción a ejecutar
    test_type test_sb_mbx;         // Mailbox para pasarle el tipo de prueba al scoreboard
    trans_data sb_test_flag_mbx;   // Mailbox para que el scoreboard inidque que terminó de escribir el csv

    //Definición del ambiente de la prueba
    ambiente #(.bits(bits), .drvrs(drvrs), .pckg_sz(pckg_sz), .broadcast(broadcast)) ambiente_inst;

    //Definición de la interfaz para conectar el DUT
    virtual bus_if #(.bits(bits), .drvrs(drvrs), .pckg_sz(pckg_sz)) _if;

    instruccion trans_agente; // Variable para almacenar el tipo de transacción que el agente va a ejecutar
    string tipo_test;         // Variable para decirle al scoreboard el tipo de prueba que se está ejecutando
    int flag;                 // Variable para indicar que se puede avanzar a la prueba siguiente

    //Definición de las condiciones iniciales del test.
    function new();
        flag = 0;
        //Instanciación de los mailboxes
        test_agent_mbx   = new();
        test_sb_mbx      = new();
        sb_test_flag_mbx = new();

        //Definición y conexión de los mailboxes
        ambiente_inst = new();
        ambiente_inst._if = _if;
        ambiente_inst.test_agent_mbx = test_agent_mbx;
        ambiente_inst.agent_inst.test_agent_mbx = test_agent_mbx;
        ambiente_inst.scoreboard_inst.test_sb_mbx = test_sb_mbx;
        ambiente_inst.scoreboard_inst.sb_test_flag_mbx = sb_test_flag_mbx;
    endfunction

    task run;
        $display("[%g] Test inicializado", $time);
        fork
            ambiente_inst.run();
        join_none

        //-------------------------------------------------------------------------------------------
        //Prueba de envío de paquetes aleatorios
        trans_agente = aleatorio;
        tipo_test = "Aleatorio";
        test_agent_mbx.put(trans_agente);
        test_sb_mbx.put(tipo_test);
        $display("[%g] Test: Enviada la instrucción de transacción aleatoria", $time);
        sb_test_flag_mbx.get(flag);
        //-------------------------------------------------------------------------------------------

        //-------------------------------------------------------------------------------------------
        //Todos los dispositivos envian con retraso 0
        trans_agente = retardos;
        tipo_test = "Retardo 0";
        test_agent_mbx.put(trans_agente);
        test_sb_mbx.put(tipo_test);
        $display("[%g] Test: Enviada la instrucción de envío con retardo 0", $time);
        sb_test_flag_mbx.get(flag);
        //-------------------------------------------------------------------------------------------

        //-------------------------------------------------------------------------------------------
        //Prueba de envío de paquetes hacia dispositivos inexistentes
        trans_agente = dir_inex; //Might have to create a new trans type
        tipo_test = "Direccion Inexistente";
        test_agent_mbx.put(trans_agente);
        test_sb_mbx.put(tipo_test);
        $display("[%g] Test: Enviada la instrucción de envío hacia dispositivos inexistentes", $time);
        sb_test_flag_mbx.get(flag);
        //Cuando la dirección no existe nunca se le hace un push a ninguna FIFO para recibir el dato. Al dato si se le hace pop y si aparece en D_pop y D_push
        //-------------------------------------------------------------------------------------------

        //-------------------------------------------------------------------------------------------
        //Prueba de envío de paquetes hacia el mismo dispositivo de salida
        trans_agente = mismo_disp;
        tipo_test = "Mismo Dispositivo";
        test_agent_mbx.put(trans_agente);
        test_sb_mbx.put(tipo_test);
        $display("[%g] Test: Enviada la instrucción de envío hacia el mismo dispositivo", $time);
        sb_test_flag_mbx.get(flag);
        //Cuando se envía al mismo dispositivo nunca se le hace un push a ninguna FIFO para recibir el dato. Al dato si se le hace pop y si aparece en D_pop y D_push
        //-------------------------------------------------------------------------------------------

        //-------------------------------------------------------------------------------------------
        //Max de envío de paquetes de máxima alternancia
        trans_agente = max_alternancia;
        tipo_test = "Maxima Alternancia";
        test_agent_mbx.put(trans_agente);
        test_sb_mbx.put(tipo_test);
        $display("[%g] Test: Enviada la instrucción de envío de paquetes de máxima alternancia", $time);
        sb_test_flag_mbx.get(flag);
        //-------------------------------------------------------------------------------------------

        //-------------------------------------------------------------------------------------------
        //Prueba de envío de paquetes broadcast
        trans_agente = broadcast;
        tipo_test = "Broadcast";
        test_agent_mbx.put(trans_agente);
        test_sb_mbx.put(tipo_test);
        $display("[%g] Test: Enviada la instrucción de transacción broadcast", $time);
        sb_test_flag_mbx.get(flag);
        //-------------------------------------------------------------------------------------------

        #100000;
        $display("[%g] Test: Se alcanzó el tiempo límite de la prueba", $time);
        #20;
        $finish;
    endtask
endclass
