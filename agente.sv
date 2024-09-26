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

    function new();
        cant_trans = 10;
        max_retardo = 20;
        //for (int i = 0; i < drvrs; i++) begin
          //  agnt_drvr_mbx[i] = new();
        //end //Me parece que esto se puede quitar
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
                        for(int i = 0; i <= cant_trans; i++) begin
                            transaccion = new; //Construye una nueva transaccion
                            transaccion.max_retardo = max_retardo;
                            transaccion.randomize();
                            transaccion.dato = {transaccion.direccion, transaccion.info};
                            transaccion.print("[PRUEBA]");
                            agnt_drvr_mbx[transaccion.dispositivo].put(transaccion);
                        end
                    end

                    broadcast: begin
                        $display("[%g]  Agente: se recibe instruccion broadcast del test",$time);
                        transaccion = new;
                        transaccion.const_direccion.constraint_mode(0);
                        transaccion.max_retardo = max_retardo;
                        //transaccion.direccion = broadcast; //testing
                        transaccion.randomize() with { direccion == broadcast ;};
                        transaccion.dato = {transaccion.direccion, transaccion.info};
                        transaccion.print("[PRUEBA]");
                        agnt_drvr_mbx[transaccion.dispositivo].put(transaccion);
                        //$finish; //Quitar el finish antes de probar las cosas
                        //Ver como aleatorizar todo menos transaccion.direccion :)
                    end

                    retardos: begin
                        $finish;
                    end

                    especifico: begin
                        $display("[%g]  Agente: se recibe instruccion especifica del test",$time);
                        transaccion = new;
                        transaccion.retardo = ret_spec;
                        //transaccion.dato = dto_spec;
                        transaccion.tipo = tpo_spec;
                        transaccion.max_retardo = max_retardo;
                        transaccion.dispositivo = dsp_spec;
                        transaccion.direccion = dir_spec;
                        transaccion.info = info_spec;
                        transaccion.dato = {dir_spec, info_spec};
                        transaccion.print("[PRUEBA]");
                        agnt_drvr_mbx[transaccion.dispositivo].put(transaccion);
                        //$finish;
                    end
                endcase
            end
            
            else begin
                //$display("[%g]  No hay instrucciones",$time);
            end
        end
    endtask
endclass
