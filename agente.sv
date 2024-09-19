class agent #(parameter bits = 1, parameter drvrs = 4, parameter pckg_sz = 16, parameter broadcast = {8{1'b1}});
    bus_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) agnt_drvr_mbx[drvrs]; //Mailbox del agente al driver
    instr_pckg_mbx test_agent_mbx; //Mailbox del test al agente
    instruccion instruccion;
    int cant_trans; //Cantidad de transacciones a realizar
    int max_retardo; //Retardo maximo entre transacciones
    bus_pckg #(.drvrs(drvrs), .pckg_sz(pckg_sz)) transaccion;

    function new;
        cant_trans = 10;
        max_retardo = 20;
        test_agent_mbx = new();
    endfunction

    task run_agent;
        $display("[%g]  El Agente fue inicializado",$time);
        forever begin
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
                        $finish; //Por si acaso
                    end

                    broadcast: begin
                        $finish;
                    end

                    retardos: begin
                        $finish;
                    end

                    especifico: begin
                        $finish;
                    end
                endcase
            end
        end
    endtask
endclass