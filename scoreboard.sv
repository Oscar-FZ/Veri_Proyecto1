class scoreboard #(parameter bits = 1, parameter drvrs = 4, parameter pckg_sz = 16, parameter broadcast = {8{1'b1}});
//Plan de ataque:
//Agarrar el mensaje del checker
//Calcular el retardo 
//Meterlo a un archivo csv (Tiempo de envio, terminal de origen, terminal de destino, tiempo de recibido, retraso en el envio)

  //Definicion de variables
  bit inicio;
  string tipo_test;
  string nombre_archivo;
  int test_aleatorio;
  
//Definicion de mailboxes
  test_type test_sb_mbx;
  sb_pckg #(parameter drvrs = 4, parameter pckg_sz = 16) chkr_sb_mbx;

  function new();
    chkr_sb_mbx.new();
    test_sb_mbx.new();
    inicio = 1;
    nombre_archivo = "Aleatorio.csv";
    tipo_test = "Aleatorio";
  endfunction

  task run();
    forever begin
      if (inicio) begin
        test_sb_mbx.get(tipo_test);
        test_aleatorio = $fopen(nombre_archivo, "w");
        $fwrite(test_aleatorio, "Test: " + tipo_test + "\n");
        $fwrite(test_aleatorio, "Parametros del Ambiente\n");
        $fwrite(test_aleatorio, "Bits = %i\n", bits);
        $fwrite(test_aleatorio, "Drivers = %i\n", drvrs);
        $fwrite(test_aleatorio, "Tamaño del Paquete = %i\n", pckg_sz);
        $fwrite(test_aleatorio, "Identificador de Broadcast = %b\n", broadcast);
        $fclose(test_aleatorio);
        inicio = 0;
      end
      $display("Aqui va el resto ajaj equis de");
      $finish;
      
    end
  endtask
endclass
