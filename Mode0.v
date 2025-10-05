module Mode0 #(
    parameter CLK_DIV = 4  // SPI Clock divider (must be even, >=2)
)(
    input        clk,         // System clock
    input        rst,         // Reset
    input        start,       // Start signal (1 cycle pulse)
    input  [7:0] data_in,     // Byte to transmit
    input        miso,        // Data from slave
    output reg   sclk,        // SPI clock
    output reg   mosi,        // Data to slave
    output reg   ss,          // Slave select (active low)
    output reg [7:0] data_out,// Data received
    output reg   busy         // High during transfer
);

    // FSM States using parameters (Verilog-2001)
    parameter STATE_IDLE     = 2'b00;
    parameter STATE_TRANSFER = 2'b01;
    parameter STATE_DONE     = 2'b10;

    reg [1:0] state = STATE_IDLE;

    // Internal registers
    reg [7:0] shift_out = 8'b0;
    reg [7:0] shift_in  = 8'b0;
    reg [2:0] bit_cnt   = 3'b0;

    // Clock divider
    reg [15:0] clk_cnt = 0;
    reg sclk_edge = 0;

    // SPI Clock Generation
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            clk_cnt   <= 0;
            sclk      <= 0;
            sclk_edge <= 0;
        end else begin
            if (state == STATE_TRANSFER) begin
                if (clk_cnt == (CLK_DIV / 2 - 1)) begin
                    clk_cnt <= 0;
                    sclk    <= ~sclk;
                    sclk_edge <= 1;
                end else begin
                    clk_cnt <= clk_cnt + 1;
                    sclk_edge <= 0;
                end
            end else begin
                clk_cnt <= 0;
                sclk    <= 0;
                sclk_edge <= 0;
            end
        end
    end

    // Main FSM Logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state     <= STATE_IDLE;
            ss        <= 1;
            busy      <= 0;
            mosi      <= 0;
            data_out  <= 0;
            shift_out <= 0;
            shift_in  <= 0;
            bit_cnt   <= 0;
        end else begin
            case (state)
                STATE_IDLE: begin
                    ss   <= 1;
                    busy <= 0;
                    sclk <= 0;
                    if (start) begin
                        ss        <= 0;
                        busy      <= 1;
                        shift_out <= data_in;
                        bit_cnt   <= 3'd7;
                        state     <= STATE_TRANSFER;
                    end
                end

                STATE_TRANSFER: begin
                    if (sclk_edge) begin
                        if (sclk == 0) begin
                            // Falling edge: drive MOSI
                            mosi <= shift_out[bit_cnt];
                        end else begin
                            // Rising edge: sample MISO
                            shift_in[bit_cnt] <= miso;
                            if (bit_cnt == 0)
                                state <= STATE_DONE;
                            else
                                bit_cnt <= bit_cnt - 1;
                        end
                    end
                end

                STATE_DONE: begin
                    ss       <= 1;
                    busy     <= 0;
                    data_out <= shift_in;
                    state    <= STATE_IDLE;
                end

                default: state <= STATE_IDLE;
            endcase
        end
    end

endmodule
