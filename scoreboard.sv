class scoreboard #(parameter bits = 1, parameter drvrs = 4, parameter pckg_sz = 16, parameter broadcast = {8{1'b1}});
    //Plan de ataque:
    //Agarrar el mensaje del checker
    //Calcular el retardo 
    //Meterlo a un archivo csv (Tiempo de envio, terminal de origen, terminal de destino, tiempo de recibido, retraso en el envio)

    //Definicion de variables
    bit inicio;
    string tipo_test;
    string nombre_archivo;
    int test_aleatorio;
    int test_broadcast;
    int test_dir_inexistente;
    int cont;
    int flag;

    sb_pckg #(.drvrs(drvrs), .pckg_sz(pckg_sz)) transaccion_chkr;
  
    //Definicion de mailboxes
    test_type test_sb_mbx;
    sb_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) chkr_sb_mbx;
    trans_data chkr_sb_flag_mbx;
    trans_data sb_test_flag_mbx;

    function new();
        chkr_sb_mbx = new();
        test_sb_mbx = new();
        transaccion_chkr = new();
        chkr_sb_flag_mbx = new();
        sb_test_flag_mbx = new();
        inicio = 1;
        cont = 1;
        flag = 0;
        nombre_archivo = "Aleatorio.csv";
        tipo_test = "Nada";
    endfunction
    
    task update();
        forever begin
            test_sb_mbx.get(tipo_test);
            inicio = 1;
            cont = 1;
        end
    endtask

    task run();
        forever begin
            #1;
            case (tipo_test)
                
                "Aleatorio": begin
                        if (inicio) begin
                            test_aleatorio = $fopen(nombre_archivo, "w");
                            $fwrite(test_aleatorio, "Test: ", tipo_test, "\n");
                            $fwrite(test_aleatorio, "Parametros del Ambiente\n");
                            $fwrite(test_aleatorio, "Bits = %0d\n", bits);
                            $fwrite(test_aleatorio, "Drivers = %0d\n", drvrs);
                            $fwrite(test_aleatorio, "Tamaño del Paquete = %0d\n", pckg_sz);
                            $fwrite(test_aleatorio, "Identificador de Broadcast = %b\n", broadcast);
                            $fwrite(test_aleatorio, "Numero; Paquete; Estado; Dispositivo de Origen; Dispositivo Destino; Tiempo de Envio; Tiempo de Recibido; Latencia;\n");
                            $fclose(test_aleatorio);
                            inicio = 0;
                        end
    
                        else begin
                            chkr_sb_mbx.get(transaccion_chkr);
                            test_aleatorio = $fopen(nombre_archivo, "a");
                            $fwrite(test_aleatorio, "%d; 0x%h; %b; %d; %d; %d; %d; %d; \n", cont, transaccion_chkr.dato_enviado, transaccion_chkr.completado, transaccion_chkr.disp_origen, transaccion_chkr.disp_destino, transaccion_chkr.tiempo_push, transaccion_chkr.tiempo_pop, transaccion_chkr.latencia);
                            $fclose(test_aleatorio);
                            cont += 1;
                        end
    
                        if ((chkr_sb_mbx.num() == 0) && (chkr_sb_flag_mbx.num()>0)) begin
                            chkr_sb_flag_mbx.get(flag);
                            sb_test_flag_mbx.put(1);
                        end
                end

                "Broadcast": begin
                        nombre_archivo = "Broadcast.csv";
                        if (inicio) begin
                            test_broadcast = $fopen(nombre_archivo, "w");
                            $fwrite(test_broadcast, "Test: ", tipo_test, "\n");
                            $fwrite(test_broadcast, "Parametros del Ambiente\n");
                            $fwrite(test_broadcast, "Bits = %0d\n", bits);
                            $fwrite(test_broadcast, "Drivers = %0d\n", drvrs);
                            $fwrite(test_broadcast, "Tamaño del Paquete = %0d\n", pckg_sz);
                            $fwrite(test_broadcast, "Identificador de Broadcast = %b\n", broadcast);
                            $fwrite(test_broadcast, "Numero; Paquete; Estado; Dispositivo de Origen; Dispositivo Destino; Tiempo de Envio; Tiempo de Recibido; Latencia;\n");
                            $fclose(test_broadcast);
                            inicio = 0;
                        end
    
                        else begin
                            chkr_sb_mbx.get(transaccion_chkr);
                            test_broadcast = $fopen(nombre_archivo, "a");
                            $fwrite(test_broadcast, "%d; 0x%h; %b; %d; %d; %d; %d; %d; \n", cont, transaccion_chkr.dato_enviado, transaccion_chkr.completado, transaccion_chkr.disp_origen, transaccion_chkr.disp_destino, transaccion_chkr.tiempo_push, transaccion_chkr.tiempo_pop, transaccion_chkr.latencia);
                            $fclose(test_broadcast);
                            cont += 1;
                        end
    
                        if ((chkr_sb_mbx.num() == 0) && (chkr_sb_flag_mbx.num()>0)) begin
                            chkr_sb_flag_mbx.get(flag);
                            sb_test_flag_mbx.put(1);
                        end
                end

                "Direccion Inexistente": begin
                    nombre_archivo = "Dir_Inexistente.csv";
                    if (inicio) begin
                        test_dir_inexistente = $fopen(nombre_archivo, "w");
                        $fwrite(test_dir_inexistente, "Test: ", tipo_test, "\n");
                        $fwrite(test_dir_inexistente, "Parametros del Ambiente\n");
                        $fwrite(test_dir_inexistente, "Bits = %0d\n", bits);
                        $fwrite(test_dir_inexistente, "Drivers = %0d\n", drvrs);
                        $fwrite(test_dir_inexistente, "Tamaño del Paquete = %0d\n", pckg_sz);
                        $fwrite(test_dir_inexistente, "Identificador de Broadcast = %b\n", broadcast);
                        $fwrite(test_dir_inexistente, "Numero; Paquete; Estado; Dispositivo de Origen; Dispositivo Destino; \n");
                        $fclose(test_dir_inexistente);
                        inicio = 0;
                    end

                    else begin
                        chkr_sb_mbx.get(transaccion_chkr);
                        test_dir_inexistente = $fopen(nombre_archivo, "a");
                        $fwrite(test_dir_inexistente, "%d; 0x%h; %b; %d; %d; \n", cont, transaccion_chkr.dato_enviado, transaccion_chkr.completado, transaccion_chkr.disp_origen, transaccion_chkr.disp_destino);
                        $fclose(test_dir_inexistente);
                        cont += 1;
                    end

                    //if ((chkr_sb_mbx.num() == 0) && (chkr_sb_flag_mbx.num()>0)) begin
                        //chkr_sb_flag_mbx.get(flag);
                        //sb_test_flag_mbx.put(1);
                    //end
                end

                "Nada": begin
                    tipo_test = tipo_test;
                end

            endcase 
        end
    endtask
endclass
