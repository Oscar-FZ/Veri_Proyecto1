//Define una serie de clases y tipos que se utilizan para simular un bus de datos
typedef enum {
    lectura,
    escritura,
    reset} transaction;

typedef enum {
    retardo_promedio,
    reporte} solicitud_sb;

typedef enum {
    aleatorio,
    broadcast,
    retardos,
    especifico} instruccion;
    


class bus_pckg #(parameter drvrs = 4, parameter pckg_sz = 16);
    rand int retardo; //El tiempo que tarda el paquete en viajar por el bus.
    bit [pckg_sz-1:0] dato; //Los datos del paquete
    int tiempo;  //El tiempo en el que se creó el paquete
    transaction tipo; //El tipo de paquete
    int max_retardo; //El retardo máximo del paquete
    rand bit [drvrs-1:0] dispositivo;//El dispositivo al que está destinado el paquete
    rand bit [7:0] direccion; //La dirección de la ubicación de memoria que se leerá o escribirá
    rand bit [pckg_sz-9:0] info;//Información adicional sobre el paquete

    constraint const_retardo {retardo < max_retardo; retardo>0;}
    constraint const_direccion {direccion < drvrs; direccion >=0; direccion != dispositivo;}
    constraint const_dispositivo {dispositivo < drvrs; dispositivo >= 0;}

    //Se definen los valores por defecto de la clase
    function new (int ret = 0, bit [pckg_sz-1:0] dto = 0, int tmp = 0, transaction tpo = escritura, int mx_rtrd = 10, bit [drvrs-1:0] dsp = 0, bit [7:0] dir = 0, bit [pckg_sz-9:0] inf = 0);
	this.retardo = ret;
	this.dato = dto;
	this.tiempo = tmp;
	this.tipo = tpo;
        this.max_retardo = mx_rtrd;
	this.dispositivo = dsp;
	this.direccion = dir;
	this.info = inf;

    endfunction
    //Se muestra en pantalla los datos de la clase paquete
    function void print(input string tag = "");
	$display("---------------------------");
        $display("[TIME %g]", $time);
        $display("%s", tag);
        $display("tipo=%s", this.tipo);
        $display("retardo=%g", this.retardo);
	$display("direccion=0x%h", this.direccion);
	$display("dispositivo=0x%h",this.dispositivo);
	$display("info=0x%h", this.info);
 	$display("dato=0x%h", this.dato);


        $display("---------------------------");
    endfunction

endclass


class sb_pckg #(parameter drvrs = 4, parameter pckg_sz = 16);

  //Atributos
  bit [pckg_sz-1:0] dato_enviado; // Los datos que se enviaron en el bus.
  int tiempo_push; // El tiempo en el que los datos se enviaron al bus.
  int tiempo_pop; // El tiempo en el que los datos se recibieron del bus.
  bit completado; // Si el paquete se ha completado.
  bit reset; // Si el paquete es un paquete de reinicio.
  int latencia; // La latencia del paquete.

  // Limpiar los atributos del paquete
  function clean();
    //Inicialización de atributos
    this.dato_enviado = 0;
    this.tiempo_push = 0;
    this.tiempo_pop = 0;
    this.completado = 0;
    this.latencia = 0;
  endfunction

  //Calcular la latencia del paquete
  task calc_latencia;
    this.latencia = this.tiempo_push - this.tiempo_pop;
  endtask

  //Imprimir el contenido del paquete
  function void print(input string tag = "");

    $display("---------------------------");
    $display("[TIME %g]", $time);
    $display("%s", tag);
    $display("Dato enviado=%h", this.dato_enviado);
    $display("tiempo push=%g", this.tiempo_push);
    $display("tiempo pop=%g", this.tiempo_pop);
    $display("latencia=%g", this.latencia);
    $display("---------------------------");

  endfunction

endclass

//Define los atributos de la interface
interface bus_if #(parameter bits = 1,parameter drvrs = 4, parameter pckg_sz = 16, parameter broadcast = {8{1'b1}}) 
    (
        input clk
    );
    
    logic reset;
    logic pndng[bits-1:0][drvrs-1:0]; //Indica donde hay un paquete pendiente
    logic push[bits-1:0][drvrs-1:0]; 
    logic pop[bits-1:0][drvrs-1:0];
    logic [pckg_sz-1:0] D_pop[bits-1:0][drvrs-1:0];
    logic [pckg_sz-1:0] D_push[bits-1:0][drvrs-1:0];
endinterface

//Define 3 tipos diferentes de mailboxes
typedef mailbox #(bus_pckg #(.drvrs(4), .pckg_sz(16))) bus_pckg_mbx;
typedef mailbox #(sb_pckg #(.drvrs(4), .pckg_sz(16))) sb_pckg_mbx;
typedef mailbox #(instruccion) instr_pckg_mbx;
