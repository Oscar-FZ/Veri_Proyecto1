class test #(parameter bits = 1, parameter drvrs = 4, parameter pckg_sz = 16, parameter broadcast = {8{1'b1}});
instr_pckg_mbx test_agent_mbx;

//Definición del ambiente de la prueba
ambiente #(.bits(bits), .drvrs(drvrs), .pckg_sz(pckg_sz), .broadcast(broadcast)) ambiente_inst;

//Definición de la interfaz para conectar el DUT
virtual bus_if #(.bits(bits), .drvrs(drvrs), .pckg_sz(pckg_sz)) _if;

//Definición de las condiciones iniciales del test
function new();
    //Instanciación de los mailboxes
    test_agent_mbx = new();

    //Definición y conexión del driver
    ambiente_inst = new();
    ambiente_inst._if = _if;
    ambiente_inst.test_agent_mbx = test_agent_mbx;
endfunction
endclass