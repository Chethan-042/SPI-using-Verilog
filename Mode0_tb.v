`timescale 1ns / 1ps

module Mode0_tb;

    parameter CLK_DIV = 4;          // Adjust SPI speed
    parameter CLK_PERIOD = 10;      // 100 MHz system clock

    // Inputs to SPI master
    reg clk = 0;
    reg rst = 0;
    reg start = 0;
    reg [7:0] data_in = 8'b10101010;
    reg miso = 0;

    // Outputs from SPI master
    wire sclk;
    wire mosi;
    wire ss;
    wire [7:0] data_out;
    wire busy;

    // Instantiate SPI Master
    Mode0 #(
        .CLK_DIV(CLK_DIV)
    ) uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .data_in(data_in),
        .miso(miso),
        .sclk(sclk),
        .mosi(mosi),
        .ss(ss),
        .data_out(data_out),
        .busy(busy)
    );

    // Clock generation (100 MHz)
    always #(CLK_PERIOD / 2) clk = ~clk;

    // Fake slave MISO response (sends 8'b11001100 back)
    reg [7:0] slave_data = 8'b11001100;
    reg [2:0] bit_idx = 7;

    always @(posedge sclk) begin
        if (!ss) begin
            miso <= slave_data[bit_idx];
            if (bit_idx != 0)
                bit_idx <= bit_idx - 1;
        end
    end

    // Simulation control
    initial begin
        $display("Starting SPI Master Simulation (Vivado)...");

        // Reset
        rst = 1;
        #50;
        rst = 0;

        // Wait for a few cycles
        #50;

        // Trigger SPI transfer
        start = 1;
        #CLK_PERIOD;
        start = 0;

        // Wait for transmission to complete
        wait (busy == 1);
        wait (busy == 0);

        // Display result
        $display("Transmission Complete");
        $display("Sent     = %b", data_in);
        $display("Received = %b", data_out);

        #100;
        $finish;
    end

endmodule
