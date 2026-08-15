module fpga_parking_assist (
    input  wire        CLOCK_50,
    input  wire [1:0]  KEY,
    input  wire [9:0]  SW,            
    inout  wire [15:0] ARDUINO_IO,    
    
   //7 seg display pins
    output wire [7:0]  HEX0, HEX1, HEX2,
    output wire [9:0]  LEDR,

    // VGA pins
    output wire [3:0]  VGA_R, VGA_G, VGA_B,
    output wire        VGA_HS, VGA_VS
);

    wire [15:0] raw_dist, filtered_dist, display_dist;
    wire trig_wire, alarm_wire;              

    assign ARDUINO_IO[0] = trig_wire;   
    wire echo_wire = ARDUINO_IO[1];     
    assign ARDUINO_IO[2] = alarm_wire;  

    // Wire for 25Mhz clock
    wire clk_25;
    
    vga_pll pll_inst (
        .inclk0(CLOCK_50),
        .c0(clk_25)
    );

    // Sensor, Filter, Alarm, Display
    ultrasonic_sensor sensor_inst (.clk(CLOCK_50), .reset_n(KEY[0]), .echo(echo_wire), .trigger(trig_wire), .distance(raw_dist));
    moving_average filter_inst (.clk(CLOCK_50), .raw_distance(raw_dist), .filtered_distance(filtered_dist));
    assign display_dist = SW[0] ? filtered_dist : raw_dist;
    
    buzzer_alarm alarm_inst (.clk(CLOCK_50), .distance(display_dist), .buzzer_pin(alarm_wire));
    
    // display driver outputs 7 bits. We add a '1' to turn off the 8th bit the decimal point
    wire [6:0] h0_temp, h1_temp, h2_temp;
    display_driver display_inst (.dist_cm(display_dist), .hex0(h0_temp), .hex1(h1_temp), .hex2(h2_temp));
    
    assign HEX0 = {1'b1, h0_temp}; 
    assign HEX1 = {1'b1, h1_temp};
    assign HEX2 = {1'b1, h2_temp};

    // VGA MODULES
    wire video_on;
    wire [9:0] x_coord, y_coord;

    vga_sync vga_sync_inst (
        .clk_25mhz(clk_25), 
        .hsync(VGA_HS),
        .vsync(VGA_VS),
        .video_on(video_on),
        .x_loc(x_coord),
        .y_loc(y_coord)
    );

    vga_drawer vga_drawer_inst (
        .x_loc(x_coord),
        .y_loc(y_coord),
        .video_on(video_on),
        .distance(display_dist), 
        .vga_r(VGA_R),
        .vga_g(VGA_G),
        .vga_b(VGA_B)
    );

endmodule
