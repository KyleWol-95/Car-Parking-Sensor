module ultrasonic_sensor (
    input  wire       clk,       // 50 MHz
    input  wire       reset_n,   // active low
    input  wire       echo,      // echo input shifted to 3.3V instead of 5
    output reg        trigger,   // trigger output
    output reg [15:0] distance   //distance in cm
);

    // State encoding
    localparam IDLE       = 3'd0;
    localparam TRIG_HIGH  = 3'd1;
    localparam WAIT_ECHO  = 3'd2;
    localparam MEASURE    = 3'd3;
    localparam DONE       = 3'd4;

    reg [2:0] state;

    reg [21:0] delay_count;     // for delays between measurements
    reg [19:0] trig_count;      // counts 10 us trigger pulse
    reg [21:0] echo_count;      // counts echo pulse width

    // Synchronize echo to clock
    reg echo_sync1, echo_sync2;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            echo_sync1 <= 1'b0;
            echo_sync2 <= 1'b0;
        end else begin
            echo_sync1 <= echo;
            echo_sync2 <= echo_sync1;
        end
    end

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state      <= IDLE;
            trigger    <= 1'b0;
            distance   <= 16'd0;
            delay_count<= 22'd0;
            trig_count <= 20'd0;
            echo_count <= 22'd0;
        end else begin
            case (state)

                // Wait about 60 ms between measurements
                IDLE: begin
                    trigger <= 1'b0;
                    trig_count <= 20'd0;
                    echo_count <= 22'd0;

                    if (delay_count < 22'd3_000_000) begin
                        delay_count <= delay_count + 1'b1;
                    end else begin
                        delay_count <= 22'd0;
                        state <= TRIG_HIGH;
                    end
                end

                // 10 us trigger pulse = 500 cycles at 50 MHz
                TRIG_HIGH: begin
                    trigger <= 1'b1;
                    if (trig_count < 20'd499) begin
                        trig_count <= trig_count + 1'b1;
                    end else begin
                        trigger <= 1'b0;
                        trig_count <= 20'd0;
                        state <= WAIT_ECHO;
                    end
                end

                // Wait for echo to go high
                WAIT_ECHO: begin
                    if (echo_sync2) begin
                        echo_count <= 22'd0;
                        state <= MEASURE;
                    end else if (delay_count < 22'd1_500_000) begin
                        // timeout ~30 ms
                        delay_count <= delay_count + 1'b1;
                    end else begin
                        delay_count <= 22'd0;
                        distance <= 16'd0;
                        state <= IDLE;
                    end
                end

                // Count while echo stays high
                MEASURE: begin
                    if (echo_sync2) begin
                        echo_count <= echo_count + 1'b1;
                    end else begin
                        // distance(cm) = echo_count / 2900 for 50 MHz clock
                        distance <= echo_count / 22'd2900;
                        state <= DONE;
                    end
                end

                DONE: begin
                    delay_count <= 22'd0;
                    state <= IDLE;
                end

                default: begin
                    state <= IDLE;
                end

            endcase
        end
    end

endmodule
