class my_checker #(parameter drvrs = 4, parameter pckg_sz = 16, parameter broadcast = {8{1'b1}});

    //Plan actual
    //TODO Que el checker no explote si llega un dato con direccion invalida
    //TODO El checker aun no envia informacion al scoreboard
    //TODO Caso reset
    //TODO Que el checker rciba cant_trans del test por medio de un mailbox

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

    //TODO Explicar que es esto
    int cant_trans;
    int cant_trans_total;
    int cant_trans_env;
    int cant_trans_rec;
    int stop;

    int brdcst_pckg [bit [pckg_sz-1:0]];



    //Definicion de los mailboxes
    bus_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) drvr_chkr_mbx; //Mailbox entre el driver y el checker
    bus_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) mntr_chkr_mbx; //Mailbox entre el monitor y el checker
    sb_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) chkr_sb_mbx;    //Mailbox entre el checker y el scoreboard

    //Nuevo mailbox
    trans_data agnt_chkr_mbx;

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

        //aver
        agnt_chkr_mbx   = new();
        //
        cant_trans          = 0; //TODO Cambiar a 0
        cant_trans_total    = 0;
        cant_trans_env      = 0;
        cant_trans_rec      = 0;
        stop                = 0;
    endfunction
    
    //El task update() esta constantemente revisando el mailbox del
    //driver-checker y cuando recibe un paquete lo guarda en la queue del
    //dispositivo al que ese paquete deberia de llegar.

    task update_cant_trans();
        forever begin
            agnt_chkr_mbx.get(cant_trans);
            cant_trans_total += cant_trans;
            $display("[AQUI] Total = %i; x = %i", cant_trans_total, cant_trans);
        end
    endtask
    task update();
        $display("[%g] El Checker se esta actualizando", $time);

        forever begin
            drvr_chkr_mbx.get(transaccion_drvr);
            //test_checker_mbx.get(cant_trans);
            //cant_trans += cant_trans;
            //$display("%i", cant_trans);
            //$display("Transaccion recibida");
            //$display("[DISPOSITIVOS] %b", drvrs);
            if (transaccion_drvr.direccion == broadcast) begin
                for (bit [drvrs-1:0] i = 8'b0; i < drvrs; i++) begin
                    if (i != transaccion_drvr.dispositivo) begin
                        emul_fifo[i].push_back(transaccion_drvr);
                        brdcst_pckg[transaccion_drvr.dato] = 0; 
                    end
                end
            end

            else if (transaccion_drvr.direccion >= drvrs[7:0]) begin
                $display("[ERROR] Direccion Inexistente");
            end

            else begin
                emul_fifo[transaccion_drvr.direccion].push_back(transaccion_drvr);
                //transaccion_drvr.print("[CHECKER FIFO]");
            end
            cant_trans_env += 1;
            if (cant_trans_env == cant_trans) begin 
                $display("[CHECKER] Se enviaron todos los paquetes");
            end
        end
    endtask

    //El task check() recibe paquetes del monitor y revisa la queue del
    //dispositivo correspondiente para ver si ese paquete es un paquete
    //esperado.
    task check();
        forever begin
            stop = 0;
            result = INCORRECTO;
            while (stop < 1000) begin
                #1;
                if (mntr_chkr_mbx.num()>0) break;
                else stop += 1;
            end

            if (stop >= 1000) begin
                $display("NO LLEGAN MAS PAQUETES");
                $finish;
            end

            else begin
                mntr_chkr_mbx.get(transaccion_mntr);
            end

            for (int i = 0; i < emul_fifo[transaccion_mntr.direccion].size(); i++) begin 
                if (emul_fifo[transaccion_mntr.direccion][i].dato == transaccion_mntr.dato) begin
                    $display("[CHECKER] Paquete Valido!");
                    result = CORRECTO;

                    if (transaccion_mntr.dato[pckg_sz-1:pckg_sz-8] == broadcast) begin
                        brdcst_pckg[transaccion_mntr.dato] += 1;

                        if (brdcst_pckg[transaccion_mntr.dato] == drvrs-1) begin
                            $display("[CHECKER] Broadcast Completado!");
                            cant_trans_rec += 1;
                        end
                    end

                    else cant_trans_rec += 1;
                    //TODO Enviar paquete al scoreboard
                    break;
                end

                else result = INCORRECTO;
            end

            if (result == INCORRECTO) begin
                $display("[CHECKER] El paquete recibido no era esperado");
                //TODO Enviar paquete erroneo al scoreboard para que lo
                //registre
            end
            
            $display("[CANTIDAD] Agnt = %i; Chkr = %i;", cant_trans_total, cant_trans_rec);
            if (cant_trans_rec == cant_trans_total) begin
                $display("[CHECKER] Se completaron todas las transacciones");
                //TODO Usar una bandera para indicarle al scoreboard que puede
                //iniciar
            end
        end
    endtask
endclass    
