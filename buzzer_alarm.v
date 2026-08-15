module buzzer_alarm (
    input  wire        clk,
    input  wire [15:0] distance,
    output reg         buzzer_pin
);

    // 26-bit counter to slow down the 50 MHz clock
    reg [25:0] timer = 0;
    
    // Tap into different bits for 3 distinct speeds!
    wire slow_pulse   = timer[25]; // Flips every 0.6 seconds slow beep
    wire medium_pulse = timer[23]; // Flips every 0.15 seconds med beep
    wire fast_pulse   = timer[21]; // Flips every 0.04 seconds fast beep

    always @(posedge clk) begin
        timer <= timer + 1;
    end

    // Decide how to beep based on exact VGA distance brackets
    always @(*) begin
        if (distance == 0 || distance >= 40) begin
            // Green Zone 40cm+: Completely silent
            buzzer_pin = 0;
            
        end else if (distance >= 25 && distance < 40) begin
            // Yellow Zone 25cm - 39cm: slow
            buzzer_pin = slow_pulse;
            
        end else if (distance >= 15 && distance < 25) begin
            // Orange Zone 15cm - 24cm: medium
            buzzer_pin = medium_pulse;
            
        end else if (distance > 0 && distance < 15) begin
            // Red Zone Under 15cm: fast
            buzzer_pin = fast_pulse;
            
        end else begin
            buzzer_pin = 0;
        end
    end

endmodule