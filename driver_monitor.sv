class drvr_mntr #(parameter bits = 1, parameter drvrs = 4, parameter pckg_sz = 16);

    bit pop;
    bit push;
    bit pndng_bus;
    bit pndng_mntr;
    bit [pckg_sz-1:0] data_bus_in;
    bit [pckg_sz-1:0] data_bus_out;
    bit [pckg_sz-1:0] queue_in [$];
    bit [pckg_sz-1:0] queue_out [$];
    int id;
  
    virtual bus_if #(.bits(bits), .drvrs(drvrs), .pckg_sz(pckg_sz)) vif;
  
    function new (input int identificador);
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
  
    task update_drvr();
	    forever begin
	        @(negedge vif.clk);
	        pop = vif.pop[0][id];
	        vif.pndng[0][id] = pndng_bus;
        end
    endtask

    task update_mntr();
	    forever begin
	        @(negedge vif.clk);
	        push = vif.push[0][id];
        end
    endtask
 
  
    task send_data_bus();
	    forever begin
	        @(posedge vif.clk);
	        vif.D_pop[0][id] = queue_in[$]; //Probably check this as well
	        if (pop) begin
    	        queue_in.pop_back();
	        end

	        if (queue_in.size() != 0) 
                pndng_bus = 1;
            else
                pndng_bus = 0;
	    end
    endtask

    task receive_data_bus();
	    forever begin
	        @(posedge vif.clk);
	        if (push) begin
	            queue_out.push_front(vif.D_push[0][id]);
	        end
      
	        if (queue_out.size() != 0) begin 
                pndng_mntr = 1;
	        end
                else
                    pndng_mntr = 0;
	    end
    endtask     



    

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

    
class drvr_mntr_hijo #(parameter bits = 1, parameter drvrs = 4, parameter pckg_sz = 16);
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
    endfunction
    
    task run_drvr();
	    $display("[ID] %d", id);
        $display("[%g] El Driver fue inicializado", $time);
	    fork
            dm_hijo.update_drvr();
	        dm_hijo.send_data_bus();
	    join_none

        @(posedge dm_hijo.vif.clk);
        forever begin
            dm_hijo.vif.reset = 0;
	        espera = 0;
            
	        agnt_drvr_mbx[id].get(transaccion);
	        while(espera <= transaccion.retardo) begin
	            @(posedge dm_hijo.vif.clk);
		        espera = espera + 1;
	        end
                
            if (transaccion.tipo == escritura) begin
                $display("[ESCRITURA]");
		        transaccion.tiempo = $time;
                dm_hijo.queue_in.push_front(transaccion.dato); //Esto no debería ser transaccion.info? Se está guardando todo en la fifo
		        transaccion.print("[DEBUG] Dato enviado");
		        drvr_chkr_mbx.put(transaccion);
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
		        transaccion_mntr.dato = dm_hijo.queue_out.pop_back();
		        mntr_chkr_mbx.put(transaccion_mntr);
                $display("Dato leido del fifo:");
                $display(transaccion_mntr.dato);
		        //transaccion.print("[DEBUG] Dato recibido"); //Cambiar esto para imprimir los datos del mailbox
	        end
        end
    endtask
endclass

class strt_drvr_mntr #(parameter bits = 1, parameter drvrs = 4, parameter pckg_sz = 16);
    drvr_mntr_hijo #(.bits(bits), .drvrs(drvrs), .pckg_sz(pckg_sz)) strt_dm [drvrs];
	
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


