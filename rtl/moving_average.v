module moving_average (
    input  wire        clk,
    input  wire [15:0] raw_distance,
    output reg  [15:0] filtered_distance
);

    // create a memory array to store the last 8 readings
    reg [15:0] history [7:0]; 
    reg [18:0] sum;
    integer i;

    //update the average continuously
    always @(posedge clk) begin
        // Shift all the old readings down by one slot
        for (i = 7; i > 0; i = i - 1) begin
            history[i] <= history[i-1];
        end
        
        // Put the newest raw reading into the first slot
        history[0] <= raw_distance;
        
        // Add them all together
        sum = 0;
        for (i = 0; i < 8; i = i + 1) begin
            sum = sum + history[i];
        end
        
        // Divide by 8 bit shifting right by 3 is the same as dividing by 8
        filtered_distance <= sum >> 3;
    end
endmodule
