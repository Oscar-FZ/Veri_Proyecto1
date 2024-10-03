class agent #(parameter bits = 1, parameter drvrs = 4, parameter pckg_sz = 16, parameter broadcast = {8{1'b1}});
    bus_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) agnt_drvr_mbx[drvrs]; // Mailbox del agente al driver
    instr_pckg_mbx test_agent_mbx;                                         // Mailbox del test al agente
    trans_data agnt_chkr_mbx;                                              // Mailbox del agente al checker
    instruccion instruccion;                                               // Variable para almacenar la instrucción recibida desde el test
    int cant_trans;                                                        // Cantidad de transacciones a realizar
    int max_retardo;                                                       // Retardo maximo entre transacciones
    bus_pckg #(.drvrs(drvrs), .pckg_sz(pckg_sz)) transaccion;              // Variable para generar transacciones que se enviarán al driver
    int ret_spec;                                                          // Retardo específico para las transacciones
    int info_spec;                                                         // Información específica para las transacciones
    transaction tpo_spec;                                                  // Tipo específico de transaccion
    int dsp_spec;                                                          // Dispositivo específico para enviar la transaccion
    bit [7:0] dir_spec;                                                    // Dirección específica hacia la cual enviar la transacción
    randomizer #(.drvrs(drvrs), .pckg_sz(pckg_sz)) aleatorizacion;         // Variable para aleatorizar número de transacciones y direcciones erróneas


    function new();
        max_retardo = 20;
        agnt_chkr_mbx = new();
    endfunction

    task run_agent;
        $display("[%g]  El Agente fue inicializado",$time);
        forever begin
            #1
            if (test_agent_mbx.num() > 0) begin // Si hay un mensaje en el mailbox
                $display("[%g]  Agente: se recibe instruccion del test",$time);
                test_agent_mbx.get(instruccion); //Se saca la instruccion del mailbox
                case(instruccion) // Se utiliza un case para ejecutar cada instrucción recibida
                    aleatorio: begin
                        for(int i = 0; i < drvrs; i++) begin //Para cada uno de los drivers
                            aleatorizacion = new;
                            aleatorizacion.randomize();
                            cant_trans = aleatorizacion.num_trans; // Se genera una cantidad aleatoria de transacciones
                            agnt_chkr_mbx.put(cant_trans); // Se envía el número de transacciones por realizar al checker
                            for (int j = 0; j < cant_trans; j++) begin // En cada una de las transacciones
                                transaccion = new; // Se crea una nueva transaccion
                                transaccion.max_retardo = max_retardo;
                                transaccion.randomize() with { dispositivo == i; }; // Se aleatoriza el contenido, manteniendo el dispositivo con el que se está trabajando
                                transaccion.dato = {transaccion.direccion, transaccion.info}; // Se empaqueta el dato
                                agnt_drvr_mbx[transaccion.dispositivo].put(transaccion); // Se envía la transacción por el mailbox
                            end
                        end
                    end

                    broadcast: begin
                        $display("[%g]  Agente: se recibe instruccion broadcast del test",$time);
                        for(int i = 0; i < drvrs; i++) begin //Para cada uno de los drivers
                            aleatorizacion = new;
                            aleatorizacion.randomize();
                            cant_trans = aleatorizacion.num_trans; // Se genera una cantidad aleatoria de transacciones
                            agnt_chkr_mbx.put(cant_trans); // Se envía el número de transacciones por realizar al checker
                            for (int j = 0; j < cant_trans; j++) begin // En cada una de las transacciones
                                transaccion = new; // Se crea una nueva transaccion
                                transaccion.const_direccion.constraint_mode(0); // Se desactivan constraints que limitan la dirección del paquete
                                transaccion.const_envio.constraint_mode(0); // Se desactivan constraints que limitan la dirección del paquete
                                transaccion.max_retardo = max_retardo;
                                transaccion.randomize(); // Se aleatoriza el contenido
                                transaccion.direccion = broadcast; // Se asigna el indicador de broadcast a la transaccion
                                transaccion.dispositivo = i; // Se asigna el dispositivo de la transacción
                                transaccion.dato = {transaccion.direccion, transaccion.info}; // Se empaqueta el dato
                                agnt_drvr_mbx[transaccion.dispositivo].put(transaccion); // Se envía la transacción por el mailbox
                            end
                        end
                    end

                    retardos: begin
                        for (int i = 0; i < drvrs; i++) begin //Para cada uno de los drivers
                            aleatorizacion = new; 
                            aleatorizacion.randomize();
                            cant_trans = aleatorizacion.num_trans; // Se genera una cantidad aleatoria de transacciones
                            agnt_chkr_mbx.put(cant_trans); // Se envía el número de transacciones por realizar al checker
                            for (int j = 0; j < cant_trans; j++) begin // En cada una de las transacciones
                                transaccion = new; // Se crea una nueva transaccion
                                transaccion.const_retardo.constraint_mode(0); // Se desactiva el constraint que limita el retardo para poder enviar transacciones con retardo 0
                                transaccion.max_retardo = 0;
                                transaccion.randomize() with { retardo == 0; }; // Se aleatorizan los datos con el retardo específico
                                transaccion.dato = {transaccion.direccion, transaccion.info}; // Se empaqueta el dato
                                agnt_drvr_mbx[transaccion.dispositivo].put(transaccion); // Se envía la transacción por el mailbox
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
                    end

                    dir_inex: begin
                        for (int i = 0; i < drvrs; i++) begin //Para cada uno de los drivers
                            aleatorizacion = new;
                            aleatorizacion.randomize();
                            cant_trans = aleatorizacion.num_trans; // Se genera una cantidad aleatoria de transacciones
                            agnt_chkr_mbx.put(cant_trans); // Se envía el número de transacciones por realizar al checker
                            for (int j = 0; j < cant_trans; j++) begin // En cada una de las transacciones
                                aleatorizacion = new;
                                aleatorizacion.randomize(); // Se aleatoriza una nueva dirección inexistente
                                transaccion = new; // Se crea una nueva transaccion
                                transaccion.const_direccion.constraint_mode(0); // Se desactiva el constraint que limita las direcciones
                                transaccion.max_retardo = max_retardo;
                                transaccion.randomize() with { direccion == aleatorizacion.wrong_addr; }; // Se aleatoriza la transacción conservando la dirección erronea
                                transaccion.dato = {transaccion.direccion, transaccion.info}; // Se empaqueta el dato
                                agnt_drvr_mbx[transaccion.dispositivo].put(transaccion); // Se envía la transacción por el mailbox
                            end
                        end
                    end

                    mismo_disp: begin
                        for (int i = 0; i < drvrs; i++) begin //Para cada uno de los drivers
                            aleatorizacion = new;
                            aleatorizacion.randomize();
                            cant_trans = aleatorizacion.num_trans; // Se genera una cantidad aleatoria de transacciones
                            agnt_chkr_mbx.put(cant_trans); // Se envía el número de transacciones por realizar al checker
                            for (int j = 0; j < cant_trans; j++) begin // En cada una de las transacciones
                                transaccion = new; // Se crea una nueva transaccion
                                transaccion.const_envio.constraint_mode(0); // Se desactiva el contraint que limita el envío al mismo dispositivo
                                transaccion.max_retardo = max_retardo;
                                transaccion.randomize() with { dispositivo == i; direccion == i; }; // Se aleatoriza la transacción con la dirección igual al dispositivo de salida
                                transaccion.dato = {transaccion.direccion, transaccion.info}; // Se empaqueta el dato
                                agnt_drvr_mbx[transaccion.dispositivo].put(transaccion); // Se envía la transacción por el mailbox
                            end
                        end
                    end
                
                    max_alternancia: begin
                        for (int i = 0; i < drvrs; i++) begin //Para cada uno de los drivers
                            aleatorizacion = new;
                            aleatorizacion.randomize();
                            cant_trans = aleatorizacion.num_trans; // Se genera una cantidad aleatoria de transacciones
                            agnt_chkr_mbx.put((cant_trans*2)); // Se envía el número de transacciones por realizar al checker

                            for (int j = 0; j < cant_trans; j++) begin // En cada una de las transacciones
                                transaccion = new; // Se crea una nueva transaccion
                                transaccion.max_retardo = max_retardo;
                                transaccion.randomize() with { info == {((pckg_sz-8)/2){2'b10}}; }; // Se aleatoriza la transacción con un dato que consiste en 101010...
                                transaccion.dato = {transaccion.direccion, transaccion.info}; // Se empaqueta el dato
                                agnt_drvr_mbx[transaccion.dispositivo].put(transaccion); // Se envía la transacción por el mailbox
                            end

                            for (int k = 0; k < cant_trans; k++) begin // En cada una de las transacciones
                                transaccion = new; // Se crea una nueva transaccion
                                transaccion.max_retardo = max_retardo;
                                transaccion.randomize() with { info == {((pckg_sz-8)/2){2'b01}}; }; // Se aleatoriza la transacción con un dato que consiste en 010101...
                                transaccion.dato = {transaccion.direccion, transaccion.info}; // Se empaqueta el dato
                                agnt_drvr_mbx[transaccion.dispositivo].put(transaccion); // Se envía la transacción por el mailbox
                            end
                        end
                    end
                endcase
            end
            
            else begin
                $display("[%g]  No hay instrucciones",$time);
            end
        end
    endtask
endclass
