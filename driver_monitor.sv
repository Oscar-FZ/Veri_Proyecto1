class drvr_mntr #(parameter bits = 1, parameter drvrs = 4, parameter pckg_sz = 16, parameter broadcast = {8{1'b1}});

    bit pop;                            //Señal de pop de la FIFO
    bit push;                           //Señal de push de la FIFO
    bit pndng_bus;                      //Señal de pending del bus
    bit pndng_mntr;                     //Señal de pending del monitor
    bit [pckg_sz-1:0] data_bus_in;      //
    bit [pckg_sz-1:0] data_bus_out;     //
    bit [pckg_sz-1:0] queue_in [$];     //
    bit [pckg_sz-1:0] queue_out [$];    //
    int id;                             //
    bus_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) drvr_chkr_mbx;
    bus_pckg #(.drvrs(drvrs), .pckg_sz(pckg_sz)) transaccion;
  
    virtual bus_if #(.bits(bits), .drvrs(drvrs), .pckg_sz(pckg_sz)) vif;
  
    function new (input int identificador);
        drvr_chkr_mbx = new();
        transaccion = new();
        this.pop = 0;
        this.push = 0;
      	this.pndng_bus = 0;
        this.pndng_mntr = 0;
   	    this.data_bus_in = 0;
      	this.data_bus_out = 0;
        this.queue_in = {};
      	this.queue_out = {};
        this.id = identificador;
    endfunction
  
    //Este task revisa constantemente la señal de pop del bus para ver si el
    //bus esta listo para recibir un paquete.
    //Tambien conecta la señal de pending de la FIFO del driver con la señal
    //de pendign del bus.
    task update_drvr(); 
        
	    forever begin
	        @(negedge vif.clk);
	        pop = vif.pop[0][id];
	        vif.pndng[0][id] = pndng_bus;
            #1;
        end
    endtask

    //Este task esta revisando constantemente la señal de push del bus para
    //que el monitor sepa cuando va a recibir un dato.
    task update_mntr();
        
	    forever begin
	        @(negedge vif.clk);
	        push = vif.push[0][id];
            #1;
        end
    endtask
 
    //Este task se encarga de guardar el paquete que se va a enviar en D_pop
    //para que este sea enviado en el momento que el bus mande la señal de
    //pop.
    //Tambien actualiza la señal de peding del Driver.
    task send_data_bus();
	    forever begin
            
	        @(posedge vif.clk);
	        vif.D_pop[0][id] = queue_in[0]; //Probably check this as well
	        if (pop) begin
    	        transaccion.dato = queue_in.pop_front();
                transaccion.tiempo = $time;
                transaccion.dispositivo = id[drvrs-1:0];
                transaccion.direccion = transaccion.dato[pckg_sz-1:pckg_sz-8];
                transaccion.info = transaccion.dato[pckg_sz-9:0];
                drvr_chkr_mbx.put(transaccion);
	        end

	        if (queue_in.size() != 0) 
                pndng_bus = 1;
            else
                pndng_bus = 0;
            #1;
	    end
    endtask

    //Este task recibe el dato del bus que viene en D_push y lo guarda en la
    //FIFO del monitor.
    //Tambien actualiza el valor de pending de la FIFO del monitor.
    task receive_data_bus();
	    forever begin
            
	        @(posedge vif.clk);
	        if (push) begin
	            queue_out.push_back(vif.D_push[0][id]);
	        end
      
	        if (queue_out.size() != 0) begin 
                pndng_mntr = 1;
	        end
                else
                    pndng_mntr = 0;

	    end
    endtask     

    
    //Esta funcion imprimer las FIFO del Driver y del Monitor junto con sus
    //señales de control para debuguear.
    function void print(input string tag);
        $display("---------------------------");
        $display("[TIME %g]", $time);
        $display("%s", tag);
        $display("push=%b", this.push);
        $display("pop=%b", this.pop);
        $display("pndng_bus=%b", this.pndng_bus);
        $display("pndng_monitor=%b", this.pndng_mntr);
        $display("data_bus_in=%h", this.data_bus_in);
        $display("data_bus_out=%h", this.data_bus_out);
        $display("queue_in=%p", this.queue_in);
        $display("queue_out=%p", this.queue_out);
        $display("id=%d", this.id);
        $display("---------------------------");
    endfunction
    
endclass

    
class drvr_mntr_hijo #(parameter bits = 1, parameter drvrs = 4, parameter pckg_sz = 16, parameter broadcast = {8{1'b1}});
    drvr_mntr #(.bits(bits), .drvrs(drvrs), .pckg_sz(pckg_sz)) dm_hijo;
    //virtual bus_if #(.bits(bits), .drvrs(drvrs), .pckg_sz(pckg_sz)) vif_hijo;

    bus_pckg #(.drvrs(drvrs), .pckg_sz(pckg_sz)) transaccion;
    bus_pckg #(.drvrs(drvrs), .pckg_sz(pckg_sz)) transaccion_mntr;


    bus_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) agnt_drvr_mbx[drvrs];
    bus_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) drvr_chkr_mbx;
    bus_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) mntr_chkr_mbx;



    int espera;
    int id;
    
    function new (input int identification);
      	dm_hijo = new(identification);
      	//dm_hijo.vif = vif_hijo;
        id = identification;
	    transaccion = new();
	    transaccion_mntr = new(.tpo(lectura));

	    for (int i = 0; i<drvrs; i++) begin
		    agnt_drvr_mbx[i] = new();
	    end

	    drvr_chkr_mbx = new();
	    mntr_chkr_mbx = new();
        dm_hijo.drvr_chkr_mbx = drvr_chkr_mbx;
    endfunction


    
    task run_drvr();
	    $display("[ID] %d", id);
        $display("[%g] El Driver fue inicializado", $time);
	    fork
            dm_hijo.update_drvr();
	        dm_hijo.send_data_bus();
	    join_none

        @(posedge dm_hijo.vif.clk);
        //if (dm_hijo.vif.pop[0][id]) begin
        //    drvr_chkr_mbx.put(dm_hijo.queue_in[$]);
        //end        
        forever begin
            
            dm_hijo.vif.reset = 0;
	        espera = 0;
            @(posedge dm_hijo.vif.clk);
	        agnt_drvr_mbx[id].get(transaccion);
	        while(espera <= transaccion.retardo) begin
	            @(posedge dm_hijo.vif.clk);
		        espera = espera + 1;
	        end
                
            if (transaccion.tipo == escritura) begin
                $display("[ESCRITURA]");
		        //transaccion.tiempo = $time;
                dm_hijo.queue_in.push_back(transaccion.dato); //Esto no debería ser transaccion.info? Se está guardando todo en la fifo
		        //transaccion.print("[DEBUG] Dato enviado");
		        //drvr_chkr_mbx.put(transaccion);
                //transaccion.print("[DRIVER]");
            end
        end
    endtask

    task run_mntr();
	    $display("[ID] %d", id);
        $display("[%g] El Monitor fue inicializado", $time);
	
	    fork
            dm_hijo.update_mntr();
	        dm_hijo.receive_data_bus();
	    join_none
        
	    forever begin
            
            dm_hijo.vif.reset = 0;
            @(posedge dm_hijo.vif.clk);    
	        if (dm_hijo.pndng_mntr) begin
	    	    $display("[LECTURA]");
		        transaccion_mntr.tiempo = $time;
		        transaccion_mntr.dato = dm_hijo.queue_out.pop_front();
                transaccion_mntr.dispositivo = id[drvrs-1:0];
                transaccion_mntr.info = transaccion_mntr.dato[pckg_sz-9:0];
                if (transaccion_mntr.dato[pckg_sz-1:pckg_sz-8] == broadcast) begin
                    $display("BROADCAST IDENTIFICADO");
                    transaccion_mntr.direccion = id[7:0];
                end
                else begin
                    transaccion_mntr.direccion = transaccion_mntr.dato[pckg_sz-1:pckg_sz-8];
                end
		        mntr_chkr_mbx.put(transaccion_mntr);
                //transaccion_mntr.print("[MONITOR]");
		        //transaccion.print("[DRVER] Dato recibido");
                //$display("Dato leido del fifo:");
                //$display("%h", transaccion_mntr.dato);
	        end
        end
    endtask
endclass

class strt_drvr_mntr #(parameter bits = 1, parameter drvrs = 4, parameter pckg_sz = 16, parameter broadcast = {8{1'b1}});
    drvr_mntr_hijo #(.bits(bits), .drvrs(drvrs), .pckg_sz(pckg_sz), .broadcast(broadcast)) strt_dm [drvrs];
	
    function new();
        for(int i = 0; i < drvrs; i++) begin
            strt_dm[i] = new(i);
        end
    endfunction

    task start_driver();
        for (int i = 0; i < drvrs; i++)begin
            fork
                automatic int j=i;
                begin
                    strt_dm[j].run_drvr();
                end
            join_none
        end
    endtask

    task start_monitor();
        for (int i = 0; i < drvrs; i++)begin
            fork
                automatic int j=i;
                begin
                    strt_dm[j].run_mntr();
                end
            join_none
        end
    endtask

endclass


