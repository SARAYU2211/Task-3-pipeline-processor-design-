module testbench;
    reg clk, reset;

    pipelined_processor uut (.clk(clk), .reset(reset));

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset = 1;
        #12;
        reset = 0;
        #100; // Run for enough cycles to observe pipeline
        $finish;
    end
endmodule
