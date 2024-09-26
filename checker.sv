class my_checker #(parameter drvrs = 4, parameter pckg_sz = 16, parameter broadcast = {8{1'b1}});

    //Plan actual
    //1 - Hacer una FIFO por cada dispositivo
    //2 - Guaradar los paquetes que manda el driver en el FIFO del dispositivo
    //    destino
    //3 - Recibir el paquete leido por el monitor
    //4 - Revisar en la FIFO si ese era el paquete esperado
    //TODO 
    
    bus_pckg #(.drvrs(drvrs), .pckg_sz(pckg_sz)) transaccion_drvr;
    bus_pckg #(.drvrs(drvrs), .pckg_sz(pckg_sz)) transaccion_mntr;
    bus_pckg #(.drvrs(drvrs), .pckg_sz(pckg_sz)) auxiliar;

    sb_pckg #(.drvrs(drvrs), .pckg_sz(pckg_sz)) to_sb;

    //bus_pckg #(.drvrs(drvrs), .pckg_sz(pckg_sz)) [drvrs-1:0] emul_fifo[$];
    bit [pckg_sz-1:0] emul_fifo[7:0][$];
    typedef enum {CORRECTO, INCORRECTO} valid;

    valid result = INCORRECTO;


    bus_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) drvr_chkr_mbx;
    bus_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) mntr_chkr_mbx;

    sb_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) chkr_sb_mbx;
    int contador_auxiliar;

    function new();
        for (int i = 0; i < drvrs; i++) begin
            emul_fifo[i] = {};
        end 
        contador_auxiliar   = 0;
        to_sb               = new();
        transaccion_drvr    = new();
        transaccion_mntr    = new();
        auxiliar            = new();
        drvr_chkr_mbx       = new();
        mntr_chkr_mbx       = new();
        chkr_sb_mbx         = new();
    endfunction


    task update();
        $display("[%g] El Checker se esta actualizando", $time);

        forever begin
            drvr_chkr_mbx.get(transaccion_drvr);
            $display("Transaccion recibida");
            if (transaccion_drvr.direccion == broadcast) begin
                for (bit [7:0] i = 8'b0; i < drvrs; i++) begin
                    if (i != transaccion_drvr.dispositivo) begin
                        emul_fifo[i].push_back(transaccion_drvr.dato);
                    end
                end
            end

            else begin
                emul_fifo[transaccion_drvr.direccion].push_back(transaccion_drvr.dato);
                transaccion_drvr.print("[CHECKER FIFO]");
            end
        end
    endtask

    task check();
        forever begin
            result = INCORRECTO;
            mntr_chkr_mbx.get(transaccion_mntr);
            for (int i = 0; i < emul_fifo[transaccion_mntr.direccion].size(); i++) begin
                auxiliar.dato = emul_fifo[transaccion_mntr.direccion][i];
                auxiliar.print("[AUXILIAR]");
                transaccion_mntr.print("[recibido]");

                if (emul_fifo[transaccion_mntr.direccion][i] == transaccion_mntr.dato) begin
                    $display("[CHECKER] LETS FUCKING GO!!!");
                    result = CORRECTO;
                    break;
                end

                else result = INCORRECTO;
            end

            if (result == INCORRECTO) begin
                $display("[CHECKER] Diay no :(");
                auxiliar.print("[AUXILIAR]");
                transaccion_mntr.print("[recibido]");
            end
        end
    endtask
endclass    
