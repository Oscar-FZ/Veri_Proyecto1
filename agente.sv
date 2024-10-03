class agent #(parameter bits = 1, parameter drvrs = 4, parameter pckg_sz = 16, parameter broadcast = {8{1'b1}});
    bus_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) agnt_drvr_mbx[drvrs]; //Mailbox del agente al driver
    instr_pckg_mbx test_agent_mbx; //Mailbox del test al agente
    instruccion instruccion;
    int cant_trans; //Cantidad de transacciones a realizar
    int max_retardo; //Retardo maximo entre transacciones
    bus_pckg #(.drvrs(drvrs), .pckg_sz(pckg_sz)) transaccion;
    int ret_spec; //Retardo específico para las transacciones
    int info_spec; //Tal vez el dato no entre en 32 bits
    transaction tpo_spec;
    int dsp_spec;
    bit [7:0] dir_spec;
    randomizer #(.drvrs(drvrs), .pckg_sz(pckg_sz)) aleatorizacion;

    trans_data agnt_chkr_mbx;

    function new();
        max_retardo = 20;
        agnt_chkr_mbx = new();
    endfunction

    task run_agent;
        $display("[%g]  El Agente fue inicializado",$time);
        forever begin
            #1
            if (test_agent_mbx.num() > 0) begin //Si hay un mensaje en el mailbox
                $display("[%g]  Agente: se recibe instruccion del test",$time);
                test_agent_mbx.get(instruccion); //Se saca la instruccion del mailbox
                case(instruccion)
                    aleatorio: begin
                        for(int i = 0; i < drvrs; i++) begin
                            aleatorizacion = new;
                            aleatorizacion.randomize();
                            cant_trans = aleatorizacion.num_trans;
                            aleatorizacion.print("PRUEBA XD");
                            agnt_chkr_mbx.put(cant_trans);
                            for (int j = 0; j < cant_trans; j++) begin
                                transaccion = new;
                                transaccion.max_retardo = max_retardo;
                                transaccion.randomize() with { dispositivo == i; };
                                transaccion.dato = {transaccion.direccion, transaccion.info};
                                //transaccion.print("BOMBOCLAT");
                                agnt_drvr_mbx[transaccion.dispositivo].put(transaccion);
                                //Si dispositivo no sirve usar variable dinamica :)
                            end
                        end
                    end

                    broadcast: begin
                        $display("[%g]  Agente: se recibe instruccion broadcast del test",$time);
                        for(int i = 0; i < drvrs; i++) begin
                            aleatorizacion = new;
                            aleatorizacion.randomize();
                            cant_trans = aleatorizacion.num_trans;
                            agnt_chkr_mbx.put(cant_trans*drvrs-1);
                            for (int j = 0; j < cant_trans; j++) begin
                                transaccion = new;
                                transaccion.const_direccion.constraint_mode(0);
                                transaccion.max_retardo = max_retardo;
                                transaccion.randomize() with { direccion == broadcast; dispositivo == i; };
                                transaccion.dato = {transaccion.direccion, transaccion.info};
                                //transaccion.print("[PRUEBA]");
                                agnt_drvr_mbx[transaccion.dispositivo].put(transaccion);
                            end
                        end
                    end

                    retardos: begin
                        for (int i = 0; i < drvrs; i++) begin
                            aleatorizacion = new;
                            aleatorizacion.randomize();
                            cant_trans = aleatorizacion.num_trans;
                            agnt_chkr_mbx.put(cant_trans);
                            for (int j = 0; j < cant_trans; j++) begin
                                transaccion = new;
                                transaccion.const_retardo.constraint_mode(0);
                                transaccion.max_retardo = 0;
                                transaccion.randomize() with { retardo == 0; };
                                transaccion.dato = {transaccion.direccion, transaccion.info};
                                agnt_drvr_mbx[transaccion.dispositivo].put(transaccion);
                            end
                        end
                    end

                    especifico: begin
                        $display("[%g]  Agente: se recibe instruccion especifica del test",$time);
                        transaccion = new;
                        transaccion.retardo = ret_spec;
                        transaccion.tipo = tpo_spec;
                        transaccion.max_retardo = max_retardo;
                        transaccion.dispositivo = dsp_spec;
                        transaccion.direccion = dir_spec;
                        transaccion.info = info_spec;
                        transaccion.dato = {transaccion.direccion, transaccion.info};
                        transaccion.print("[PRUEBA]");
                        agnt_drvr_mbx[transaccion.dispositivo].put(transaccion);
                        //$finish;
                    end

                    dir_inex: begin
                        for (int i = 0; i < drvrs; i++) begin
                            aleatorizacion = new;
                            aleatorizacion.randomize();
                            cant_trans = aleatorizacion.num_trans;
                            agnt_chkr_mbx.put(cant_trans);
                            for (int j = 0; j < cant_trans; j++) begin
                                aleatorizacion = new;
                                aleatorizacion.randomize();
                                transaccion = new;
                                transaccion.const_direccion.constraint_mode(0);
                                transaccion.max_retardo = max_retardo;
                                transaccion.randomize() with { direccion == aleatorizacion.wrong_addr; };
                                transaccion.dato = {transaccion.direccion, transaccion.info};
                                //transaccion.print("Direccion inexistente");
                                agnt_drvr_mbx[transaccion.dispositivo].put(transaccion);
                            end
                        end
                    end

                    mismo_disp: begin
                        for (int i = 0; i < drvrs; i++) begin
                            aleatorizacion = new;
                            aleatorizacion.randomize();
                            cant_trans = aleatorizacion.num_trans;
                            agnt_chkr_mbx.put(cant_trans);
                            for (int j = 0; j < cant_trans; j++) begin
                                transaccion = new;
                                transaccion.const_direccion.constraint_mode(0);
                                transaccion.max_retardo = max_retardo;
                                transaccion.randomize() with { dispositivo == i; direccion == i; };
                                transaccion.dato = {transaccion.direccion, transaccion.info};
                                transaccion.print("Enviando el dato al mismo dispositivo");
                                agnt_drvr_mbx[transaccion.dispositivo].put(transaccion);
                            end
                        end
                    end
                
                    max_alternancia: begin
                        for (int i = 0; i < drvrs; i++) begin
                            aleatorizacion = new;
                            aleatorizacion.randomize();
                            cant_trans = aleatorizacion.num_trans;
                            agnt_chkr_mbx.put((cant_trans*2));

                            for (int j = 0; j < cant_trans; j++) begin
                                transaccion = new;
                                transaccion.max_retardo = max_retardo;
                                transaccion.randomize() with { info == {((pckg_sz-8)/2){2'b10}}; };
                                transaccion.dato = {transaccion.direccion, transaccion.info};
                                agnt_drvr_mbx[transaccion.dispositivo].put(transaccion);
                            end

                            for (int k = 0; k < cant_trans; k++) begin
                                transaccion = new;
                                transaccion.max_retardo = max_retardo;
                                transaccion.randomize() with { info == {((pckg_sz-8)/2){2'b01}}; };
                                transaccion.dato = {transaccion.direccion, transaccion.info};
                                agnt_drvr_mbx[transaccion.dispositivo].put(transaccion);
                            end
                        end
                    end
                endcase
            end
            
            else begin
                //$display("[%g]  No hay instrucciones",$time);
            end
        end
    endtask
endclass
