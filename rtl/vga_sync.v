module vga_sync (
    input  wire clk_25mhz,
    output reg  hsync,
    output reg  vsync,
    output wire video_on,
    output reg  [9:0] x_loc = 0,
    output reg  [9:0] y_loc = 0
);
    // 640x480 @ 60Hz timings
    parameter H_DISPLAY = 640, H_FRONT = 16, H_SYNC = 96, H_BACK = 48, H_TOTAL = 800;
    parameter V_DISPLAY = 480, V_FRONT = 10, V_SYNC = 2,  V_BACK = 33, V_TOTAL = 525;

    // Keep track of current X and Y pixel coordinates
    always @(posedge clk_25mhz) begin
        if (x_loc == H_TOTAL - 1) begin
            x_loc <= 0;
            if (y_loc == V_TOTAL - 1) y_loc <= 0;
            else y_loc <= y_loc + 1;
        end else begin
            x_loc <= x_loc + 1;
        end
    end

    // Generate synchronization pulses
    always @(posedge clk_25mhz) begin
        hsync <= ~(x_loc >= (H_DISPLAY + H_FRONT) && x_loc < (H_DISPLAY + H_FRONT + H_SYNC));
        vsync <= ~(y_loc >= (V_DISPLAY + V_FRONT) && y_loc < (V_DISPLAY + V_FRONT + V_SYNC));
    end

    // Only draw when we are in the visible display area
    assign video_on = (x_loc < H_DISPLAY) && (y_loc < V_DISPLAY);
    
endmodule
