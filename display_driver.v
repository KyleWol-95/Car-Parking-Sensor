module display_driver (
    input  wire [15:0] dist_cm,
    output wire [6:0]  hex0, hex1, hex2
);
    // Extract digits
    wire [3:0] ones     = dist_cm % 10;
    wire [3:0] tens     = (dist_cm / 10) % 10;
    wire [3:0] hundreds = (dist_cm / 100) % 10;

    // Convert digits to 7 seg
    bcd_to_7seg d0 (.bcd(ones),     .seg(hex0));
    bcd_to_7seg d1 (.bcd(tens),     .seg(hex1));
    bcd_to_7seg d2 (.bcd(hundreds), .seg(hex2));
endmodule