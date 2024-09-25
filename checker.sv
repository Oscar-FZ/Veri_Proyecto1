class my_checker #(parameter drvrs = 4, parameter pckg_sz = 16);

    //Plan actual
    //1 - Hacer una FIFO por cada dispositivo
    //2 - Guaradar los paquetes que manda el driver en el FIFO del dispositivo
    //    destino
    //3 - Recibir el paquete leido por el monitor
    //4 - Revisar en la FIFO si ese era el paquete esperado
    
    bus_pckg #(.drvrs(drvrs), .pckg_sz(pckg_sz)) transaccion_drvr;
    bus_pckg #(.drvrs(drvrs), .pckg_sz(pckg_sz)) transaccion_mntr;
    bus_pckg #(.drvrs(drvrs), .pckg_sz(pckg_sz)) auxiliar;

    sb_pckg #(.drvrs(drvrs), .pckg_sz(pckg_sz)) to_sb;

    //bus_pckg #(.drvrs(drvrs), .pckg_sz(pckg_sz)) [drvrs-1:0] emul_fifo[$];
    bit [7:0] emul_fifo[$];


    bus_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) drvr_chkr_mbx;
    bus_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) mntr_chkr_mbx;

    sb_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) cjkr_sb_mbx;
    int contador_auxiliar;

    function new();
        for (int i = 0; i < drvrs; i++) begin
            emul_fifo[i] = {};
        end 
        contador_auxiliar   = 0;
        to_sb               = new();
        transaccion_drvr    = new();
        transaccion_mntr    = new();
        drvr_chkr_mbx       = new();
        mntr_chkr_mbx       = new();
        chkr_sb_mbx         = new();
    endfunction


    task update();
        $display("[%g] El Checker se esta actualizando", $time);

        forever begin
            drvr_chkr_mbx.get(trannsaccion_drvr);
            $display("Transaccion recibida");
            emul_fifo[transaccion_drvr.direccion].push_front(transaccion_drvr);
        end
    endtask

    task check();
        mntr_chkr_mbx.get(transaccion_mntr);
        if (emul_fifo[transaccion_mntr.direccion].pop_back == transaccion_mntr) begin
            $display("[CHECKER] LETS FUCKING GO!!!");
        end

        else begin
            $display("[CHECKER] Diay no :(");
        end
    endtask

