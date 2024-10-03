module param_random;

    class rand_param;
        rand int drvrs;
        rand int pckg_sz;
        rand bit [7:0] broadcast;

        constraint const_params {
            drvrs >=4;
            drvrs <=8;
            pckg_sz inside {16,32,64};
            broadcast > drvrs;
            broadcast < 256;
        }

        function void set_parameters();
            int p_file;
            p_file = $fopen("parametros_test.sv", "w"); // Cambiarle el nombre
            if (p_file == 0) begin
                $fatal("Could not open test_parameters.sv for writing.");
            end
            $fwrite(p_file, "parameter bits = 1;\n");
            $fwrite(p_file, "parameter drvrs = %d;",drvrs,"\n");
            $fwrite(p_file, "parameter pckg_sz = %d;",pckg_sz,"\n");
            $fwrite(p_file, "parameter broadcast = 8'b%b;",broadcast,"\n");
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