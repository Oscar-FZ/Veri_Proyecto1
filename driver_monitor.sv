//Esta clase define las FIFO que se vana conectar en la entrada y salida de cada dispositivo
class drvr_mntr #(parameter bits = 1, parameter drvrs = 4, parameter pckg_sz = 16, parameter broadcast = {8{1'b1}});

    bit pop;                            // Señal de pop de la FIFO
    bit push;                           // Señal de push de la FIFO
    bit pndng_bus;                      // Señal de pending del bus
    bit pndng_mntr;                     // Señal de pending del monitor
    bit [pckg_sz-1:0] data_bus_in;      // Señal de datos que se reciben en el dispositivo
    bit [pckg_sz-1:0] data_bus_out;     // Señal de datos que se envían desde el dispositivo
    bit [pckg_sz-1:0] queue_in [$];     // Cola de tamaño indefinifo para almacenar los datos que entran al dispositivo
    bit [pckg_sz-1:0] queue_out [$];    // Cola de tamaño indefinifo para almacenar los datos que salen del dispositivo
    int id;                             // Entero para identificar los distintos dispositivos conectados al bus

    bus_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) drvr_chkr_mbx; // Mailbox para comunicar el driver y el checker
    bus_pckg #(.drvrs(drvrs), .pckg_sz(pckg_sz)) transaccion;       // Transacción recibida por el mailbox

    bus_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) mntr_chkr_mbx; // Mailbox para comunicar el monitor y el checker
    bus_pckg #(.drvrs(drvrs), .pckg_sz(pckg_sz)) transaccion_mntr;  // Transacción recibida por el mailbox

  
    virtual bus_if #(.bits(bits), .drvrs(drvrs), .pckg_sz(pckg_sz)) vif; // Interfaz virtual con el DUT

    // Función constructora de los mailboxes y transacciones utilizadas por cada uno de los dispositivos conectados al bus
    function new (input int identificador);
        drvr_chkr_mbx = new();
        mntr_chkr_mbx = new();
        transaccion = new();
        transaccion_mntr = new();
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
    //Cuando ocurre un Pop este task manda el paquete con la informacion adicional necesaria hacia el checker por medio de un mailbox.
    task send_data_bus();
	    forever begin
	        @(posedge vif.clk);
	        vif.D_pop[0][id] = queue_in[0];
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
    //Cuando ocurre un push este task manda el paquete con la informacion adicional necesaria hacia el checker por medio de un mailbox.
	
    task receive_data_bus();
	    forever begin
            
	        @(posedge vif.clk);
	        if (push) begin
	            queue_out.push_back(vif.D_push[0][id]);
                transaccion_mntr.tiempo = $time;
                transaccion_mntr.dato = vif.D_push[0][id];
                transaccion_mntr.dispositivo = id[drvrs-1:0];
                transaccion_mntr.info = transaccion_mntr.dato[pckg_sz-9:0];
                if (transaccion_mntr.dato[pckg_sz-1:pckg_sz-8] == broadcast) begin
                    $display("BROADCAST IDENTIFICADO");
                end
                else begin
                    transaccion_mntr.direccion = transaccion_mntr.dato[pckg_sz-1:pckg_sz-8];
                end
                mntr_chkr_mbx.put(transaccion_mntr);
	        end
      
	        if (queue_out.size() != 0) begin 
                pndng_mntr = 1;
	        end
                else
                    pndng_mntr = 0;
	    end
    endtask     

    
    //Esta funcion imprime las FIFO del Driver y del Monitor junto con sus
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

//Esta clase define el comportamiento del monitor y del driver.
class drvr_mntr_hijo #(parameter bits = 1, parameter drvrs = 4, parameter pckg_sz = 16, parameter broadcast = {8{1'b1}});
    drvr_mntr #(.bits(bits), .drvrs(drvrs), .pckg_sz(pckg_sz), .broadcast(broadcast)) dm_hijo; //Este objeto son la FIFO de entrada y de salida de un dispositivo.

    bus_pckg #(.drvrs(drvrs), .pckg_sz(pckg_sz)) transaccion;      //Variable que se usa para guardar los paquetes provenientes del agente y que seran enviados por el driver.
    bus_pckg #(.drvrs(drvrs), .pckg_sz(pckg_sz)) transaccion_mntr; //Variable que se usa para guardar los paquetes leidos por el monitor.

    bus_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) agnt_drvr_mbx[drvrs]; //Mailbox entre el agente y el driver de cada dispositivo.
    bus_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) drvr_chkr_mbx;        //Mailbox entre el driver y el checker.
    bus_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) mntr_chkr_mbx;        //Mailbox entre el monitor y el checker.

    int espera; //Variable que se usa para contar el retardo que tiene que esperar cada paquete antes de entrar a la FIFO.
    int id;     //Variable que indica a cual dispositivo estan conectados el driver y el monitor.
    
    //Funcion constructora
    function new (input int identification);
      	dm_hijo = new(identification);
        id = identification;
	    transaccion = new();
	    transaccion_mntr = new(.tpo(lectura));

	    for (int i = 0; i<drvrs; i++) begin
		    agnt_drvr_mbx[i] = new();
	    end

	    drvr_chkr_mbx = new();
	    mntr_chkr_mbx = new();
    endfunction


    //Este task define el comportamiento del driver, para esto inicializa los task update_drvr() 
    //y send_data_bus() de la FIFO, también está constantemente esperando paquetes del agente por
    //medio de un mailbox.
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
            @(posedge dm_hijo.vif.clk);
	        agnt_drvr_mbx[id].get(transaccion);
	        while(espera <= transaccion.retardo) begin
	            @(posedge dm_hijo.vif.clk);
		        espera = espera + 1;
	        end
                
            if (transaccion.tipo == escritura) begin
                $display("[ESCRITURA]");
                dm_hijo.queue_in.push_back(transaccion.dato);
            end
        end
    endtask

    //Este task define el comportamiento del monitor, para esto inicializa los task update_mntr() 
    //y receive_data_bus().
    task run_mntr();
	    $display("[ID] %d", id);
        $display("[%g] El Monitor fue inicializado", $time);
	
	    fork
            dm_hijo.update_mntr();
	        dm_hijo.receive_data_bus();
	    join_none
    endtask
endclass

// Esta es la clase padre de todos los driver y monitores que se encarga de crear la cantidad de 
//driver y monitores requeridas y de inicializarlas.
class strt_drvr_mntr #(parameter bits = 1, parameter drvrs = 4, parameter pckg_sz = 16, parameter broadcast = {8{1'b1}});
    drvr_mntr_hijo #(.bits(bits), .drvrs(drvrs), .pckg_sz(pckg_sz), .broadcast(broadcast)) strt_dm [drvrs]; //Se crean las instancias del objeto que define el driver y el monitor

    //Funcion constructora. Inicializa todos los objetos requeridos.
    function new();
        for(int i = 0; i < drvrs; i++) begin
            strt_dm[i] = new(i);
        end
    endfunction

    //Inicia el funcionamiento de todos los drivers.
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

    //Inicia el funcionamuiento de todos los monitores.
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
