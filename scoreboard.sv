class scoreboard #(parameter bits = 1, parameter drvrs = 4, parameter pckg_sz = 16, parameter broadcast = {8{1'b1}});
    //Definicion de variables
    bit inicio;                 // Variable que indica el inicio de una prueba
    string tipo_test;           // Variable que almacena el tipo de prueba que se realiza
    string nombre_archivo;      // Variable que almacena el nombre del archivo .csv donde se almacenan los datos
    int test_aleatorio;         // Variable tipo entero para almacenar el "file descriptor" del archivo de la prueba aleatoria
    int test_broadcast;         // Variable tipo entero para almacenar el "file descriptor" del archivo de la prueba broadcast
    int test_dir_inexistente;   // Variable tipo entero para almacenar el "file descriptor" del archivo de la prueba direccion inexistente
    int test_ret_0;             // Variable tipo entero para almacenar el "file descriptor" del archivo de la prueba retardo 0
    int test_mismo_disp;        // Variable tipo entero para almacenar el "file descriptor" del archivo de la prueba mismo dispositivo
    int test_max_alt;           // Variable tipo entero para almacenar el "file descriptor" del archivo de la prueba máxima alternancia
    int cont;                   // Variable para almacenar un contador
    int flag;                   // Bandera para indicar que una prueba terminó

    sb_pckg #(.drvrs(drvrs), .pckg_sz(pckg_sz)) transaccion_chkr; // Variable que almacena los datos provenientes del checker
  
    //Definicion de mailboxes
    test_type test_sb_mbx;                                          // Mailbox entre el test y el scoreboard
    sb_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) chkr_sb_mbx;    // Mailbox entre el checker y el scoreboard
    trans_data chkr_sb_flag_mbx;                                    // Mailbox de control entre checker y scoreboard
    trans_data sb_test_flag_mbx;                                    // Mailbox de control entre scoreboard y test

    // Función constructora del scoreboard
    function new();
        chkr_sb_mbx      = new();
        test_sb_mbx      = new();
        transaccion_chkr = new();
        chkr_sb_flag_mbx = new();
        sb_test_flag_mbx = new();
        inicio           = 1;
        cont             = 1;
        flag             = 0;
        nombre_archivo = "Aleatorio.csv";
        tipo_test = "Nada";
    endfunction
    
    // Task para leer el mailbox entre el test y el scoreboard constantemente
    task update();
        forever begin
            test_sb_mbx.get(tipo_test);
            inicio = 1;
            cont = 1;
        end
    endtask

    // Task para correr el scoreboard
    task run();
        forever begin
            #1;
            case (tipo_test) // Caso para escribir el archivo dependiendo del tipo de prueba
                "Aleatorio": begin
                        if (inicio) begin
                            test_aleatorio = $fopen(nombre_archivo, "w"); // Abre o crea el archivo csv si no existe
                            // Se escribe el header del archivo con información general
                            $fwrite(test_aleatorio, "Test: ", tipo_test, "\n");
                            $fwrite(test_aleatorio, "Parametros del Ambiente\n");
                            $fwrite(test_aleatorio, "Bits = %0d\n", bits);
                            $fwrite(test_aleatorio, "Drivers = %0d\n", drvrs);
                            $fwrite(test_aleatorio, "Tamaño del Paquete = %0d\n", pckg_sz);
                            $fwrite(test_aleatorio, "Identificador de Broadcast = %08b\n", broadcast);
                            $fwrite(test_aleatorio, "Numero; Paquete; Estado; Dispositivo de Origen; Dispositivo Destino; Tiempo de Envio; Tiempo de Recibido; Latencia;\n");
                            $fclose(test_aleatorio); // Se cierra el archivo para evitar corrupción de los datos
                            inicio = 0;
                        end
    
                        else begin
                            chkr_sb_mbx.get(transaccion_chkr); // Se toma el dato del checker del mmailbox
                            test_aleatorio = $fopen(nombre_archivo, "a"); // Se abre el archivo creado previamente
                            // Se escriben los datos obtenidos del mailbox
                            $fwrite(test_aleatorio, "%d; 0x%h; %b; %d; %d; %d; %d; %d; \n", cont, transaccion_chkr.dato_enviado, transaccion_chkr.completado, transaccion_chkr.disp_origen, transaccion_chkr.disp_destino, transaccion_chkr.tiempo_push, transaccion_chkr.tiempo_pop, transaccion_chkr.latencia);
                            $fclose(test_aleatorio); // Cierra el archivo csv
                            cont += 1;
                        end
    
                        if ((chkr_sb_mbx.num() == 0) && (chkr_sb_flag_mbx.num()>0)) begin // Si el checker no envía más paquetes y hay algo en el mailbox de control
                            chkr_sb_flag_mbx.get(flag); // Obtener la bandera de control desde el checker
                            sb_test_flag_mbx.put(1);    // Indicarle al test que puede continuar con la siguiente prueba
                        end
                end
                ////////////////////////////////////// Esta lógica se repite en el resto de casos //////////////////////////////////////

                "Broadcast": begin
                        nombre_archivo = "Broadcast.csv";
                        if (inicio) begin
                            test_broadcast = $fopen(nombre_archivo, "w");
                            $fwrite(test_broadcast, "Test: ", tipo_test, "\n");
                            $fwrite(test_broadcast, "Parametros del Ambiente\n");
                            $fwrite(test_broadcast, "Bits = %0d\n", bits);
                            $fwrite(test_broadcast, "Drivers = %0d\n", drvrs);
                            $fwrite(test_broadcast, "Tamaño del Paquete = %0d\n", pckg_sz);
                            $fwrite(test_broadcast, "Identificador de Broadcast = %08b\n", broadcast);
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
                        $fwrite(test_dir_inexistente, "Identificador de Broadcast = %08b\n", broadcast);
                        $fwrite(test_dir_inexistente, "Numero; Paquete; Estado; Dispositivo de Origen; Dispositivo Destino; \n");
                        $fclose(test_dir_inexistente);
                        inicio = 0;
                    end

                    else begin
                        chkr_sb_mbx.get(transaccion_chkr);
                        test_dir_inexistente = $fopen(nombre_archivo, "a");
                        $fwrite(test_dir_inexistente, "%d; 0x%h; %b; %d; %h; \n", cont, transaccion_chkr.dato_enviado, transaccion_chkr.completado, transaccion_chkr.disp_origen, transaccion_chkr.disp_destino);
                        $fclose(test_dir_inexistente);
                        cont += 1;
                    end

                    if ((chkr_sb_mbx.num() == 0) && (chkr_sb_flag_mbx.num()>0)) begin
                        chkr_sb_flag_mbx.get(flag);
                        sb_test_flag_mbx.put(1);
                    end
                end

                "Retardo 0": begin
                    nombre_archivo = "Retardo_0.csv";
                    if (inicio) begin
                        test_ret_0 = $fopen(nombre_archivo, "w");
                        $fwrite(test_ret_0, "Test: ", tipo_test, "\n");
                        $fwrite(test_ret_0, "Parametros del Ambiente\n");
                        $fwrite(test_ret_0, "Bits = %0d\n", bits);
                        $fwrite(test_ret_0, "Drivers = %0d\n", drvrs);
                        $fwrite(test_ret_0, "Tamaño del Paquete = %0d\n", pckg_sz);
                        $fwrite(test_ret_0, "Identificador de Broadcast = %08b\n", broadcast);
                        $fwrite(test_ret_0, "Numero; Paquete; Estado; Dispositivo de Origen; Dispositivo Destino; Tiempo de Envio; Tiempo de Recibido; Latencia;\n");
                        $fclose(test_ret_0);
                        inicio = 0;
                    end

                    else begin
                        chkr_sb_mbx.get(transaccion_chkr);
                        test_dir_inexistente = $fopen(nombre_archivo, "a");
                        $fwrite(test_ret_0, "%d; 0x%h; %b; %d; %d; %d; %d; %d; \n", cont, transaccion_chkr.dato_enviado, transaccion_chkr.completado, transaccion_chkr.disp_origen, transaccion_chkr.disp_destino, transaccion_chkr.tiempo_push, transaccion_chkr.tiempo_pop, transaccion_chkr.latencia);
                            $fclose(test_ret_0);
                        cont += 1;
                    end

                    if ((chkr_sb_mbx.num() == 0) && (chkr_sb_flag_mbx.num()>0)) begin
                        chkr_sb_flag_mbx.get(flag);
                        sb_test_flag_mbx.put(1);
                    end
                end

                "Mismo Dispositivo": begin
                    nombre_archivo = "Mismo_Dispositivo.csv";
                    if (inicio) begin
                        test_mismo_disp = $fopen(nombre_archivo, "w");
                        $fwrite(test_mismo_disp, "Test: ", tipo_test, "\n");
                        $fwrite(test_mismo_disp, "Parametros del Ambiente\n");
                        $fwrite(test_mismo_disp, "Bits = %0d\n", bits);
                        $fwrite(test_mismo_disp, "Drivers = %0d\n", drvrs);
                        $fwrite(test_mismo_disp, "Tamaño del Paquete = %0d\n", pckg_sz);
                        $fwrite(test_mismo_disp, "Identificador de Broadcast = %08b\n", broadcast);
                        $fwrite(test_mismo_disp, "Numero; Paquete; Estado; Dispositivo de Origen; Dispositivo Destino; Tiempo de Envio; Tiempo de Recibido; Latencia;\n");
                        $fclose(test_mismo_disp);
                        inicio = 0;
                    end

                    else begin
                        chkr_sb_mbx.get(transaccion_chkr);
                        test_dir_inexistente = $fopen(nombre_archivo, "a");
                        $fwrite(test_mismo_disp, "%d; 0x%h; %b; %d; %h; \n", cont, transaccion_chkr.dato_enviado, transaccion_chkr.completado, transaccion_chkr.disp_origen, transaccion_chkr.disp_destino);
                        $fclose(test_mismo_disp);
                        cont += 1;
                    end

                    if ((chkr_sb_mbx.num() == 0) && (chkr_sb_flag_mbx.num()>0)) begin
                        chkr_sb_flag_mbx.get(flag);
                        sb_test_flag_mbx.put(1);
                    end
                end

                "Maxima Alternancia": begin
                    nombre_archivo = "Maxima_Alternancia.csv";
                    if (inicio) begin
                        test_max_alt = $fopen(nombre_archivo, "w");
                        $fwrite(test_max_alt, "Test: ", tipo_test, "\n");
                        $fwrite(test_max_alt, "Parametros del Ambiente\n");
                        $fwrite(test_max_alt, "Bits = %0d\n", bits);
                        $fwrite(test_max_alt, "Drivers = %0d\n", drvrs);
                        $fwrite(test_max_alt, "Tamaño del Paquete = %0d\n", pckg_sz);
                        $fwrite(test_max_alt, "Identificador de Broadcast = %08b\n", broadcast);
                        $fwrite(test_max_alt, "Numero; Paquete; Estado; Dispositivo de Origen; Dispositivo Destino; Tiempo de Envio; Tiempo de Recibido; Latencia;\n");
                        $fclose(test_max_alt);
                        inicio = 0;
                    end

                    else begin
                        chkr_sb_mbx.get(transaccion_chkr);
                        test_max_alt = $fopen(nombre_archivo, "a");
                        $fwrite(test_max_alt, "%d; 0x%h; %b; %d; %d; %d; %d; %d; \n", cont, transaccion_chkr.dato_enviado, transaccion_chkr.completado, transaccion_chkr.disp_origen, transaccion_chkr.disp_destino, transaccion_chkr.tiempo_push, transaccion_chkr.tiempo_pop, transaccion_chkr.latencia);
                        $fclose(test_max_alt);
                        cont += 1;
                    end

                    if ((chkr_sb_mbx.num() == 0) && (chkr_sb_flag_mbx.num()>0)) begin
                        chkr_sb_flag_mbx.get(flag);
                        sb_test_flag_mbx.put(1);
                    end
                end

                "Nada": begin
                    tipo_test = tipo_test;
                end

            endcase 
        end
    endtask
endclass
