module param_random;

    class rand_param;
        rand int drvrs;
        //rand int pckg_sz;
        //rand int broadcast;

        constraint const_params {
            drvrs >=5;
            drvrs <=16;
            //pckg_sz inside {16,32,64};
            //broadcast > drvrs;
            //broadcast < 256;
        }

        function void set_parameters();
            int p_file;
            p_file = $fopen("parametros_test.sv", "w"); // Cambiarle el nombre
            if (p_file == 0) begin
                $fatal("Could not open test_parameters.sv for writing.");
            end
            $fwrite(p_file, "parameter bits = 1;\n");
            $fwrite(p_file, "parameter drvrs = %0d;\n", drvrs);
            $fwrite(p_file, "parameter pckg_sz = 16;\n");
            $fwrite(p_file, "parameter broadcast = 255;\n");
            $fclose(p_file); // Don't forget to close the file
        endfunction

        task randomize_parameters();
            if (this.randomize()) begin
                set_parameters();
            end else begin
                $warning("Randomization failed.");
            end
        endtask
    endclass

    initial begin
        rand_param parametros = new;
        parametros.randomize_parameters();
    end

endmodule