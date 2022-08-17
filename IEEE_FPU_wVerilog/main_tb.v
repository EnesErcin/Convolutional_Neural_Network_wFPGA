`timescale 1ns / 1ps


module main_tb();

reg clk = 0;
reg initate=0;
reg [31:0]a_inn,b_in;
wire [31:0]result;
wire[1:0]warning;

localparam ClockPeriod = 3;
always #(ClockPeriod/2) assign clk = ~clk ;

 FPU_addition_uni_t UUT(
    .a_in(a_inn),
    .b_in(b_in),
    .initate(initate),
    .clk(clk),
    .result(result),
    .warning(warning)
                );
initial begin
    initate <= 1;
    b_in <= 32'b11000011000100001000100001111110;
    a_inn <= 32'b11000001000100001000110001111110;
    #50
    initate <= 1;
    a_inn <= 32'b01010100110001010000001100110100;
    b_in <= 32'b01010101100000000000000000010110;
    #500    
    initate <= 0;
end                        
                       
                        
endmodule
