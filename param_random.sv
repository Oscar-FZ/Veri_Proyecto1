module param_random
    class rand_param;
        rand int drvrs;
        //rand int pckg_sz;
        //rand int broadcast;

        constraint const_params {
            drvrs inside {[4:16]};
            //pckg_sz inside {16,32,64};
            broadcast > drvrs;
            broadcast < 256;
        }
    endclass

    function void set_parameters;
        int p_file = $fopen("test_parameters.sv");
        $fwrite(p_file, "parameter bits = 1; \n");
        $fwrite(p_file, "parameter drvrs = %i; ", drvrs, "\n");
        $fwrite(p_file, "parameter pckg_sz = 16;\n");
        $fwrite(p_file, "broadcast = 255;\n");
    endfunction

    task randomize_parameters;
        rand_param parametros = new;
        parametros.randomize();
        parametros.set_parameters;
    endtask
endmodule