`timescale 1ns / 1ns


module Verilog_behav_tests();

reg [4:0] a,a_2,c_2;
reg [5:0]b;
reg [5:0] c;

initial begin    
    $monitor("[%0t], a=%b b=%b,c=%b " , $time,a,b,c );
    
    a = 5'b10011;
    b = 6'b100101;
    b = b >> 1;
    c = a+b;
    a_2 = 5'b10001;
    c_2 = a + a_2;
    #5
    a = 5'b00011;
    b = 6'b100101;
     c = a+b[5:1];
    #5
    a = a << 1;
    b = a >> 1;
    c = a+b;
    
end





endmodule
