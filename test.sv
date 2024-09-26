class test #(parameter bits = 1, parameter drvrs = 4, parameter pckg_sz = 16, parameter broadcast = {8{1'b1}});
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

    trans_agente = broadcast;
    test_agent_mbx.put(trans_agente);
    $display("[%g] Test: Enviada la instrucción de transacción aleatoria", $time);

    //for (int i = 0; i < 10; i++) begin
        //automatic int l = i;
        //ambiente_inst.agent_inst.ret_spec = 4;
        //ambiente_inst.agent_inst.tpo_spec = escritura;
        //ambiente_inst.agent_inst.max_retardo = 9;
        //ambiente_inst.agent_inst.dsp_spec = 1;
        //ambiente_inst.agent_inst.dir_spec = 8'b00000010;
        //ambiente_inst.agent_inst.info_spec = l;
        //trans_agente = especifico;
        //test_agent_mbx.put(trans_agente);
        //$display("[%g] Test: Enviada la instrucción prueba de transacción especifica 1", $time);
    //end

    #1000000;
    $display("[%g] Test: Se alcanzó el tiempo límite de la prueba", $time);
    #20;
    $finish;
//TODO
//Envio de paquetes aleatorios, envio de paquetes broadcast, envio de reset, 
//paquetes aleatorios desde diferentes disp. al mismo tiempo,
//maxima alternancia, hacia dispositivo inexistente, desde y hacia el mismo disp.
endtask
endclass