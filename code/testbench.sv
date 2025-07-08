module CPU_tb;
    reg clk;

    CPU cpu_inst(.clk(clk));

    initial begin
      clk = 0;
     $dumpfile("cpu_waveform.vcd");
        $dumpvars(0, CPU_tb);  
    end
    always #5 clk = ~clk;  
    initial begin
        #340
        $finish;
    end
endmodule