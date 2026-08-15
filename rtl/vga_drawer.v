module vga_drawer (
    input  wire [9:0]  x_loc,
    input  wire [9:0]  y_loc,
    input  wire        video_on,
    input  wire [15:0] distance,
    output reg  [3:0]  vga_r,
    output reg  [3:0]  vga_g,
    output reg  [3:0]  vga_b
);
    // Center of the screen
    parameter CX = 320;
    parameter CY = 240;

    reg [9:0] box_radius;
    reg [3:0] color_r, color_g, color_b;

    // Cap the distance at 50cm so far distances do not go beyond boundaries
    wire [15:0] safe_dist = (distance > 50 || distance == 0) ? 50 : distance;

    // CALCULATE SMOOTH SIZE AND COLOR
    always @(*) begin
        // 1. Smooth Size Calculation
        // At 50cm, 250 - (50 * 4) = 50 radius Small
        // At 10cm, 250 - (10 * 4) = 210 radius Big
        box_radius = 250 - (safe_dist * 4);

        // 2. Smooth Color Gradient
        if (safe_dist >= 25) begin
            // 50cm to 25cm Green fading to Yellow
            // Green is fully on, Red smoothly fades up as distance drops
            color_r = ((50 - safe_dist) * 15) / 25; 
            color_g = 4'hF; 
            color_b = 4'h0;
        end else begin
            // 24cm to 0cm Yellow fading to Red
            // Red is fully on, Green smoothly fades down as distance drops
            color_r = 4'hF;
            color_g = (safe_dist * 15) / 25;
            color_b = 4'h0;
        end
    end

    // DRAW THE PIXELS 
    always @(*) begin
        if (video_on) begin
            // Is the current pixel inside our smoothly changing box?
            if ((x_loc >= CX - box_radius && x_loc <= CX + box_radius) &&
                (y_loc >= CY - box_radius && y_loc <= CY + box_radius)) begin
                vga_r = color_r;
                vga_g = color_g;
                vga_b = color_b;
            end else begin
                // Background is Black
                vga_r = 4'h0; vga_g = 4'h0; vga_b = 4'h0;
            end
        end else begin
            vga_r = 4'h0; vga_g = 4'h0; vga_b = 4'h0;
        end
    end
endmodule
