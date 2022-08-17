`timescale 1ns / 1ps

module FPU_addition_uni_t (
            input [31:0]a_in,
            input [31:0]b_in,
            input initate,
            input clk,
            
            output reg [31:0]result,
            output reg [1:0] warning
                        );
                  
localparam          load            = 3'b000,
            denormalize_sign_calc   = 3'b001,
            equallize_expo          = 3'b010,
            normalize_mantissa      = 3'b011,
            finilize_result         = 3'b100;

reg [2:0] state_reg= load; 
            
reg [22:0]  a_m       ;
reg [22:0]  b_m       ;
reg [7:0]   a_e       ;
reg [7:0]   b_e       ;
reg         a_s       ;
reg         b_s      ;

reg [1:0]   compare_expo ;       
reg [7:0]   expo_dif; 
reg [23:0]  a_m_denormalized,small_m_denormalized_f;
reg [23:0]  b_m_denormalized;
reg [24:0]  r_m_denormalized;
reg [8:0]   common_expo,common_expo_check;   
reg [7:0] temp_expo_smaller,temp_expo_eq_1,temp_expo_eq_2,temp_expo_smaller_b;

integer i_check; // For a loop
           
always @(posedge clk)  
begin

case (state_reg)
    load  :  begin if(initate == 1) begin
                    // Decode
                    decode(a_in,b_in,initate,a_m ,b_m,a_e,b_e,a_s,b_s);
                    compare_expo <= compare(a_e ,b_e);
                    state_reg <= denormalize_sign_calc;
    end end
    denormalize_sign_calc :  begin
                        if(compare_expo == 2'b01) begin
                            //First input value has higher exponent
                            denormalize_i(b_m,b_e,temp_expo_smaller,b_m_denormalized);
                            result[31] <= a_s; 
                            expo_dif <= a_e - b_e;  end
                        else if(compare_expo == 2'b10) begin
                            //Second input value has higher exponent
                            denormalize_i(a_m,a_e,temp_expo_smaller,a_m_denormalized);
                            denormalize_i(b_m,b_e,temp_expo_smaller_b,b_m_denormalized);
                            result[31] <= b_s; 
                            expo_dif <= b_e - a_e; end
                        else if(compare_expo == 2'b11) begin
                            // Exponents are equal
                            denormalize_i(a_m,a_e,temp_expo_eq_1,a_m_denormalized);
                            denormalize_i(b_m,b_e,temp_expo_eq_2,b_m_denormalized);
                            result[31] <= b_s;
                            expo_dif <= 0; 
                            temp_expo_smaller <= temp_expo_eq_2;
                            end
                        else 
                            warning <= 2'b01;
                        state_reg <= equallize_expo;
    end
    equallize_expo : begin
             //Mantisa have been denormalized (Implied one is added to msb)
                             if(compare_expo == 2'b01) begin
                              //First input value has higher exponent
                               shif_mantissa(b_m_denormalized,temp_expo_smaller,expo_dif,small_m_denormalized_f,common_expo_check);
                               if(a_e != common_expo_check) warning <= 2'b11;  // Exponents should have been same (Analyse for expo overflow)
                               r_m_denormalized <= a_m + (small_m_denormalized_f);
                               common_expo <= a_e;    end        
                              else if(compare_expo == 2'b10) begin                          
                              //Second input value has higher exponent
                               shif_mantissa(a_m_denormalized,temp_expo_smaller,expo_dif,small_m_denormalized_f,common_expo_check);
                               if(b_e != common_expo_check) warning <= 2'b11; // Exponents should have been same (Analyse for expo overflow)
                               r_m_denormalized <= (small_m_denormalized_f ) + b_m_denormalized;
                               common_expo <= b_e;    end 
                              else if(compare_expo == 2'b11) begin                          
                              // Exponents are equal 
                              r_m_denormalized <=     a_m_denormalized + b_m_denormalized ;  
                              if(temp_expo_eq_1 != temp_expo_eq_2) warning <= 2'b11; // Exponents should have been same (Analyse for expo overflow)                
                              common_expo <= temp_expo_eq_1;    end 
                              state_reg <= normalize_mantissa;
    end
    normalize_mantissa :   begin   normalize_mantissa_task(r_m_denormalized,common_expo,result[30:23],result[22:0],i_check);
                             state_reg <= finilize_result; end
    finilize_result:   begin
//                          compare_expo                                 <= 0                          ;                                                     
//                          expo_dif                                         <= 0                       ;                                                          
//                          a_m_denormalized                              <= 0                            ;              
//                          small_m_denormalized_f              <= 0                            ;                           
//                          b_m_denormalized                                <= 0                        ;                                                  
//                          r_m_denormalized                                <= 0                                ;                                                  
//                          common_expo   <= 0                                    ;           
//                          common_expo_check                   <= 0                                    ;                                     
//                        temp_expo_smaller<= 0  ;
//                        temp_expo_eq_1<= 0      ;
//                        temp_expo_eq_2                                  <= 0;  
//                        temp_expo_smaller_b              <= 0                                               ;  
                         state_reg <= load  ;
                        end
    
endcase

end  

                   
//           >>>>>>>>>>>>>        Tasks and functions         <<<<<<<<<<<<<<<<<<<         \\

// Decode opperands for convineance
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

// Compare exponents (Unsigned style)
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

task denormalize_i(
input [22:0]    c_m  ,
input [7:0]     c_e,
output [7:0]    temp_expo_smaller,
output [23:0]   c_m_denormalized_i
);
begin
c_m_denormalized_i[22:0]  = c_m;
c_m_denormalized_i[23]    = 1'b1;
temp_expo_smaller = c_e ;
end 
endtask


task shif_mantissa(
input [23:0]    c_m_denormalized_i ,
input [7:0]     c_e,
input [7:0]expo_dif,

output [23:0]    c_m_denormalized_i_f ,
output [7:0]     c_e_f
);
begin
$display("%b",expo_dif);
c_m_denormalized_i_f = (c_m_denormalized_i  >> (expo_dif));
c_e_f = c_e + (expo_dif);
end 
endtask

task normalize_mantissa_task(
input [24:0]r_m_denormalized,
input [8:0]common_exo,

output [7:0] result_expo,
output [22:0] result_mantissa,
output integer i_check
);
begin: normalize_block
integer i;
reg [24:0]temp_denormalized;
reg [8:0] temp_common_expo;
    begin: Loop_block
    for(i = 0 ; i<24 ; i= i + 1) begin
    // Find the most significant "1" in mantissa
    //  That will be shifted to implied invisible position.
    if( i > 0 ) begin
            if(r_m_denormalized[24-i] == 1)
             disable Loop_block;
         end end end
          temp_denormalized = r_m_denormalized << i ;
          temp_common_expo  = common_exo - (i-1);
          result_mantissa   = temp_denormalized[23:1];
          result_expo       = temp_common_expo[7:0];
          i_check = i; 
     end 
endtask


endmodule




