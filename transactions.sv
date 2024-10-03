////////////////////////////////////////////////////////////////////////////////////
// Define una serie de clases y tipos que se utilizan para simular un bus de datos
////////////////////////////////////////////////////////////////////////////////////
// Definición de estructura para generar comandos hacia el DUT
////////////////////////////////////////////////////////////////////////////////////
typedef enum {
  lectura,
  escritura,
  reset
} transaction;

////////////////////////////////////////////////////////////////////////////////////
// Definición de estructura para generar comandos hacia el scoreboard
////////////////////////////////////////////////////////////////////////////////////
typedef enum {
  retardo_promedio,
  reporte
} solicitud_sb;

////////////////////////////////////////////////////////////////////////////////////
// Definición de estructura para generar comandos hacia el agente
////////////////////////////////////////////////////////////////////////////////////
typedef enum {
  aleatorio,
  broadcast,
  retardos,
  especifico,
  dir_inex,
  mismo_disp,
  max_alternancia
} instruccion;
  

////////////////////////////////////////////////////////////////////////////////////
// bus_pckg representa las transacciones que entran y salen del bus de datos
////////////////////////////////////////////////////////////////////////////////////
class bus_pckg #(parameter drvrs = 4, parameter pckg_sz = 16);
  rand int retardo;                   // El tiempo que tarda el paquete antes de enviarse al bus.
  bit [pckg_sz-1:0] dato;             // Los el dato contenido en el paquete
  int tiempo;                         // El tiempo en el que se envio el paquete
  transaction tipo;                   // El tipo de paquete
  int max_retardo;                    // El retardo máximo del paquete
  rand bit [drvrs-1:0] dispositivo;   // El dispositivo del cual sale el paquete
  rand bit [7:0] direccion;           // La dirección del dispositivo hacia el que se dirige el paquete
  rand bit [pckg_sz-9:0] info;        // Información que contiene el paquete

  constraint const_retardo {retardo < max_retardo; retardo>0;}          // Constraint para definir el retardo máximo para el envio de paquetes
  constraint const_direccion {direccion < drvrs; direccion >=0;}        // Constraint para limitar la dirección hacia la que se envía el paquete
  constraint const_envio {direccion != dispositivo;}                    // Constraint para evitar que el dispositivo se envíe datos a si mismo
  constraint const_dispositivo {dispositivo < drvrs; dispositivo >= 0;} // Constraint para limtar el número de dispositivos de acuerdo con los parámetros

  // Se definen los valores por defecto de la clase
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

  // Función auxiliar para mostrar en pantalla los datos del paquete
  function void print(input string tag = "");
    $display("---------------------------");
    $display("[TIME sim = %g, pack = %d]", $time, this.tiempo);
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


////////////////////////////////////////////////////////////////////////////////////
// sb_pckg representa las transacciones que se pueden utilizar en el scoreboard
////////////////////////////////////////////////////////////////////////////////////
class sb_pckg #(parameter drvrs = 4, parameter pckg_sz = 16);
// Atributos
bit [pckg_sz-1:0] dato_enviado;   // Los datos que se enviaron en el bus.
bit [drvrs-1:0] disp_origen;      // El dispositivo de origen de los datos.
bit [pckg_sz-9:0] disp_destino;   // El dispositivo de destino de los datos.
int tiempo_push;                  // El tiempo en el que los datos se enviaron al bus.
int tiempo_pop;                   // El tiempo en el que los datos se recibieron del bus.
bit completado;                   // Si el paquete se ha completado.
bit reset;                        // Si el paquete es un paquete de reinicio.
int latencia;                     // La latencia del paquete.

// Limpiar los atributos del paquete
function clean();
  this.dato_enviado = 0;
  this.disp_origen = 0;
  this.disp_destino = 0;
  this.tiempo_push = 0;
  this.tiempo_pop = 0;
  this.completado = 0;
  this.latencia = 0;
endfunction

// Task auxiliar para calcular la latencia del paquete
task calc_latencia();
  this.latencia = this.tiempo_pop - this.tiempo_push;
endtask

// Función auxiliar para imprimir el contenido del paquete
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

////////////////////////////////////////////////////////////////////////////////////
// randomizer genera datos aleatorios utilizados en diversas pruebas
////////////////////////////////////////////////////////////////////////////////////
class randomizer #(parameter drvrs = 4, parameter pckg_sz = 16);
//Atributos
rand int num_trans;  // Número de transacciones que se van a realizar
rand int wrong_addr; // Dirección erronea a la que se enviarán los datos

// Constraints
constraint const_ntrans {num_trans >= 50; num_trans <= 100;}                            // Constraint para limitar el número de transacciones
constraint const_waddr {wrong_addr > drvrs; wrong_addr != broadcast; wrong_addr < 255;} // Constraint para limitar las posibles direcciones

//Valores por defecto de la clase
function new (int n_trans = 1, int w_addr = 1);
  this.num_trans = n_trans;
  this.wrong_addr = w_addr;
endfunction

// Función auxiliar para imprimir los datos
function void print(input string tag = "");
  $display("---------------------------");
  $display("Numero de transacciones=%i", this.num_trans);
  $display("Direccion erronea=%h", this.wrong_addr);
  $display("---------------------------");
endfunction
endclass

//Define los atributos de la interface
interface bus_if #(parameter bits = 1,parameter drvrs = 4, parameter pckg_sz = 16, parameter broadcast = {8{1'b1}}) 
  (
      input clk
  );
  
  logic reset;
  logic pndng[bits-1:0][drvrs-1:0]; 
  logic push[bits-1:0][drvrs-1:0]; 
  logic pop[bits-1:0][drvrs-1:0];
  logic [pckg_sz-1:0] D_pop[bits-1:0][drvrs-1:0];
  logic [pckg_sz-1:0] D_push[bits-1:0][drvrs-1:0];
endinterface

//Define 3 tipos diferentes de mailboxes
typedef mailbox #(bus_pckg #(.drvrs(4), .pckg_sz(16))) bus_pckg_mbx; // Definición de mailbox para comunicar las interfaces con tipo de dato bus_pckg
typedef mailbox #(sb_pckg #(.drvrs(4), .pckg_sz(16))) sb_pckg_mbx;   // Definición de mailbox para comunicar las interfaces con tipo de dato sb_pckg
typedef mailbox #(instruccion) instr_pckg_mbx;                       // Definición de mailbox para comunicar las interfaces con tipo de dato instruccion
typedef mailbox #(int) trans_data;                                   // Definición de mailbox para comunicar las interfaces con tipo de dato entero
typedef mailbox #(string) test_type;                                 // Referencia a Evangelion!

event fin_test;
