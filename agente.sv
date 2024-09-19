class agent #(parameter bits = 1, parameter drvrs = 4, parameter pckg_sz = 16, parameter broadcast = {8{1'b1}});
    bus_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) agnt_drvr_mbx[drvrs];
    instr_pckg_mbx test_agent_mbx; //Mailbox del test al agente
    instruccion instruccion;

    task run_agent;
        $display("[%g]  El Agente fue inicializado",$time);
        forever begin
            if (test_agent_mbx.num() > 0) begin //Si hay un mensaje en el mailbox
                $display("[%g]  Agente: se recibe instruccion del test",$time);
                test_agent_mbx.get(instruccion); //Se saca la instruccion del mailbox
                case(instruccion)
                    aleatorio: begin
                        
                    end

                    broadcast: begin
                        
                    end

                    retardos: begin
                        
                    end

                    especifico: begin
                        
                    end
                endcase
            end
        end
    endtask
endclass