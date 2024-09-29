class my_checker #(parameter drvrs = 4, parameter pckg_sz = 16, parameter broadcast = {8{1'b1}});

    //Plan actual
    //TODO Que el checker no explote si llega un dato con direccion invalida
    //TODO El checker aun no envia informacion al scoreboard
    //TODO Caso reset
    //TODO Verificar que todos los dispositivos hayan recibido el paquete de
    //un broadcast

    //Definicion de los paquetes
    bus_pckg #(.drvrs(drvrs), .pckg_sz(pckg_sz)) transaccion_drvr;  //Guarda los paquetes que vengan del driver 
    bus_pckg #(.drvrs(drvrs), .pckg_sz(pckg_sz)) transaccion_mntr;  //Guarda los paquetes que vengan del monitor
    sb_pckg #(.drvrs(drvrs), .pckg_sz(pckg_sz)) to_sb;              //Guarda los paquetes que van para el score board

    //Define una queue por dispositivo
    //bit [pckg_sz-1:0] emul_fifo[7:0][$];
    bus_pckg emul_fifo[7:0][$];
    //Se guardan los paquetes que envia el driver en la queue del dispositivo
    //al que este deberia de llegar para posteriormente cuando llegue un
    //paquete del monitor revisar si ese paquete era el esperado.

    //Se crea un tipo de dato enum que se usara para definir si un paquete es
    //valido o no.
    typedef enum {CORRECTO, INCORRECTO} valid;
    valid result = INCORRECTO;


    //Definicion de los mailboxes
    bus_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) drvr_chkr_mbx; //Mailbox entre el driver y el checker
    bus_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) mntr_chkr_mbx; //Mailbox entre el monitor y el checker
    sb_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) chkr_sb_mbx;    //Mailbox entre el checker y el scoreboard

    //Funcion constructora
    function new();
        for (int i = 0; i < drvrs; i++) begin
            emul_fifo[i] = {};
        end 
        to_sb               = new();
        transaccion_drvr    = new();
        transaccion_mntr    = new();
        drvr_chkr_mbx       = new();
        mntr_chkr_mbx       = new();
        chkr_sb_mbx         = new();
    endfunction
    
    //El task update() esta constantemente revisando el mailbox del
    //driver-checker y cuando recibe un paquete lo guarda en la queue del
    //dispositivo al que ese paquete deberia de llegar.
    task update();
        $display("[%g] El Checker se esta actualizando", $time);

        forever begin
            drvr_chkr_mbx.get(transaccion_drvr);
            $display("Transaccion recibida");
            $display("[DISPOSITIVOS] %b", drvrs);
            if (transaccion_drvr.direccion == broadcast) begin
                for (bit [drvrs-1:0] i = 8'b0; i < drvrs; i++) begin
                    if (i != transaccion_drvr.dispositivo) begin
                        emul_fifo[i].push_back(transaccion_drvr);
                    end
                end
            end

            else if (transaccion_drvr.direccion >= drvrs[7:0]) begin
                $display("[ERROR] Direccion Inexistente");
            end

            else begin
                emul_fifo[transaccion_drvr.direccion].push_back(transaccion_drvr);
                transaccion_drvr.print("[CHECKER FIFO]");
            end
        end
    endtask

    //El task check() recibe paquetes del monitor y revisa la queue del
    //dispositivo correspondiente para ver si ese paquete es un paquete
    //esperado.
    task check();
        forever begin
            result = INCORRECTO;
            mntr_chkr_mbx.get(transaccion_mntr);
            for (int i = 0; i < emul_fifo[transaccion_mntr.direccion].size(); i++) begin 
                //auxiliar.dato = emul_fifo[transaccion_mntr.direccion][i];
                //auxiliar.print("[AUXILIAR]");
                //transaccion_mntr.print("[recibido]");

                if (emul_fifo[transaccion_mntr.direccion][i].dato == transaccion_mntr.dato) begin
                    $display("[CHECKER] LETS FUCKING GO!!!");
                    emul_fifo[transaccion_mntr.direccion][i].print("[CHECKER] Dato Esperado");
                    transaccion_mntr.print("[CHECKER] Dato Recibido");
                    result = CORRECTO;
                    break;
                end

                else result = INCORRECTO;
            end

            if (result == INCORRECTO) begin
                $display("[CHECKER] El paquete recibido no era esperado");
                //auxiliar.print("[AUXILIAR]");
                //transaccion_mntr.print("[recibido]");
            end
        end
    endtask
endclass    
