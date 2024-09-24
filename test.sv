class test #(parameter bits = 1, parameter drvrs = 4, parameter pckg_sz = 16, parameter broadcast = {8{1'b1}});
instr_pckg_mbx test_agent_mbx;

//Definición del ambiente de la prueba
ambiente #(.bits(bits), .drvrs(drvrs), .pckg_sz(pckg_sz), .broadcast(broadcast)) ambiente_inst;

endclass