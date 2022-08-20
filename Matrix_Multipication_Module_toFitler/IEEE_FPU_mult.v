`timescale 1ns / 1ps

module IEEE_FPU_mult_i(
    input [31:0]a_in,b_in,
    input clk,
    input wire initate,
    
    output reg [2:0]expo_overflow_signal,
    output reg ready_mult_out,
    output reg [31:0]Result
    );
    
localparam Initate = 3'b000,
           Expo_Calc = 3'b001,
           Calc = 3'b010;
           
reg [3:0]state_reg;

reg [22:0]  a_m,b_m  ;
reg [7:0]   a_e,b_e,result_e  ;
reg         a_s,b_s  ;
reg   [23:0]   a_m_denormalized_i,b_m_denormalized_i  ;
reg   [47:0]   result_mantissa;
reg is_exponent_zero=0;
integer i_check;     
always @(posedge clk) begin

case (state_reg)

Initate :  begin
           
            if(initate == 1)begin
                decode(a_in,b_in,initate,a_m,b_m ,a_e, b_e,a_s,b_s);               
                // Very Quick Solution to 0 exponent may look werid 
                if(a_e ==8'b01111111 || b_e == 8'b01111111)
                is_exponent_zero <= 1;
                // Wierdness ended
                state_reg <= Expo_Calc;
                denormalize_i(a_m,a_e,a_m_denormalized_i);
                denormalize_i(b_m,b_e,b_m_denormalized_i);
                result_e  <= a_e + b_e ;
                Result[31] <=  a_in[31] ^ b_in[31];
            end
            end
Expo_Calc :  begin
                  ready_mult_out <= 0;
                  expo_overflow_signal = expo_overflow(a_e[7],b_e[7],result_e[7],is_exponent_zero) ;
                  if(expo_overflow_signal == 2'b00) begin 
                  result_e <= result_e + 8'b10000001;
                  result_mantissa <= a_m_denormalized_i * b_m_denormalized_i;
                  state_reg <= Calc; end
                  else if(expo_overflow_signal == 2'b01) 
                    state_reg <= Calc;
                  else if(expo_overflow_signal == 2'b01) 
                    state_reg <= Calc;
             end
Calc: begin 
                if(expo_overflow_signal == 2'b00) begin
                denormalize_mantissa(result_mantissa,result_e,i_check,Result[22:0],Result[30:23]);
                ready_mult_out <= 1;
                state_reg <= Initate; end
                else if(expo_overflow_signal == 2'b01) begin
                Result <= 31'b1111111011111111111111111111110;
                state_reg <= Initate; end
              else if(expo_overflow_signal == 2'b01) begin
                Result <= 31'b1111111011111111111111111111110;
                state_reg <= Initate; end
            
       end
default:   state_reg <= Initate ;
endcase
end   



   
task decode(
input   [31:0]a_in,
input   [31:0]b_in,
input load,

output [22:0]  a_m  ,
output [22:0]  b_m  ,
output [7:0]   a_e  ,
output [7:0]   b_e  ,
output         a_s  ,
output         b_s  
);
begin
// Decode
if(load == 1) begin
 a_m   =     a_in [22:0]     ;
 b_m   =     b_in [22:0]     ;
 a_e   =     a_in [30:23]    ;
 b_e   =     b_in [30:23]    ;
 a_s   =     a_in [31]       ;
 b_s   =     b_in [31]       ; 
end end
endtask

task denormalize_i(
input [22:0]    c_m  ,
input [7:0]     c_e,
output [23:0]   c_m_denormalized_i
);
begin
c_m_denormalized_i[22:0]  = c_m;
c_m_denormalized_i[23]    = 1'b1;
end 
endtask

task denormalize_mantissa (
input [47:0]    c_m  ,
input [7:0]     c_e,
output integer i_check,

output reg [23:0]   c_m_denormalized_i,
output reg [7:0]    c_e_final
);
reg [47:0]c_m_hold;
integer i;
begin
    begin:LoopBlock
    for(i = 0; i<=46 ;i = i +1) begin
        if(c_m[47-i] == 1)
         disable LoopBlock;
    end  end       
c_m_hold = c_m << i;
c_m_denormalized_i = c_m_hold[47:24];
c_e_final = c_e - (i-1);
i_check = i; //For easy debug --delete
end 
endtask


function [1:0] expo_overflow;
input a_e_sign, b_e_sign,result_e_sign,is_exponent_zero;
begin
    if(a_e_sign != a_e_sign)
    expo_overflow = 2'b00;
    else if(a_e_sign == a_e_sign)
    begin
    if(is_exponent_zero == 0) begin
        if(a_e_sign == 1 && result_e_sign== 1)
        expo_overflow = 2'b01;          // Expo overflow: Higher
        else if(a_e_sign == 1 && result_e_sign== 0)
        expo_overflow = 2'b00;          
        else if(a_e_sign == 0 && result_e_sign== 0)
        expo_overflow = 2'b10;          // Expo overflow: Lower
        else if(a_e_sign == 0 && result_e_sign== 1)
        expo_overflow = 2'b00; 
    end 
    else expo_overflow = 2'b00; 
    end
end 
endfunction

function [1:0]compare(input [7:0]a_e ,b_e);
begin

    if(a_e > b_e) 
        compare = 2'b01;
    else if(b_e > a_e)
        compare = 2'b10;
    else if(b_e == a_e)
        compare = 2'b11;
    else 
        compare = 2'b00;  
     end
// 1: first input is bigger 2: second input is bigger 3: inputs are equal     
endfunction


endmodule
