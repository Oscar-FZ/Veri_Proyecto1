// Módulo para aleatorizar los parámetros del DUT
module param_random;

    class rand_param;
        rand int drvrs;             // Variable para almacenar el número de dispositivos conectados al dut
        rand int pckg_sz;           // Variable para almacenar el tamaño de los paquetes que se van a transmitir
        rand bit [7:0] broadcast;   // Variable para almacenar el identificador de broadcast

        // Constraint para limitar los valores aleatorizados
        constraint const_params {
            drvrs >=4; drvrs <=8;
            pckg_sz inside {16,32,64};
            //broadcast > drvrs; Linea 537 de Library.sv
            broadcast == 255;
        }

        // Función para guardar los valores aleatorizados en un archivo
        function void set_parameters();
            int p_file; // Variable para almacenar el descriptor del archivo
            p_file = $fopen("parametros_test.sv", "w"); // Abre el archivo
            if (p_file == 0) begin // Verifica que se abrió correctamente
                $fatal("No se pudo abrir parametros_test.sv");
            end
            // Escribe en el archivo
            $fwrite(p_file, "parameter bits = 1;\n");
            $fwrite(p_file, "parameter drvrs = %d;",drvrs,"\n");
            $fwrite(p_file, "parameter pckg_sz = %d;",pckg_sz,"\n");
            $fwrite(p_file, "parameter broadcast = %d;",broadcast,"\n");
            $fclose(p_file); // Cierra el archivo
        endfunction

        // Task para aleatorizar los parámetros
        task randomize_parameters();
            if (this.randomize()) begin
                set_parameters();
            end else begin
                $warning("Error en la aleatorización.");
            end
        endtask
    endclass

    // Aleatorización de los parámetros
    initial begin
        rand_param parametros = new;
        parametros.randomize_parameters();
    end

endmodule