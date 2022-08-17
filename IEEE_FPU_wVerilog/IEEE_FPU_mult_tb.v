`timescale 1ns / 1ps

module IEEE_FPU_mult_tb( );


reg clk = 0;
reg initate=0;
reg [31:0]a_in,b_in;

wire ready_mult_out;
wire [2:0]expo_overflow_signal;
wire [31:0]Result;

localparam ClockPeriod = 3;
always #(ClockPeriod/2) assign clk = ~clk ;

 IEEE_FPU_mult_i UUT(
    .a_in(a_in),
    .b_in(b_in),
    .initate(initate),
    .clk(clk),
    .Result(Result),
    .expo_overflow_signal(expo_overflow_signal),
    .ready_mult_out(ready_mult_out)
    );

initial begin
    initate <= 1;
    b_in <= 32'b11000011000100001000100001111110;
    a_in <= 32'b11000001000100001000110001111110;
    #50
    initate <= 1;
    a_in <= 32'b01010100110001010000001100110100;
    b_in <= 32'b01010101100000000000000000010110;
    #500    
    initate <= 0;
end  


endmodule