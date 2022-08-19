`timescale 1ns / 1ps

module Dot_Product_Module
#(parameter filtersize = 9)
// Not an actual parameter dont play with it
// If there was a way to create number of inputs with the parameter I have just defined
// Than it would be possible to paramaterize the filter size. 
// (It may be possible with systemverilog)
(
input wire clk,
input initate,
input wire [31:0] img_bit_0,
input wire [31:0] img_bit_1,
input wire [31:0] img_bit_2,
  
input wire [31:0] img_bit_3,
input wire [31:0] img_bit_4,
input wire [31:0] img_bit_5,
 
input wire [31:0] img_bit_6,
input wire [31:0] img_bit_7,
input wire [31:0] img_bit_8,

input wire [31:0] filter_0,
input wire [31:0] filter_1,
input wire [31:0] filter_2,
    
input wire [31:0] filter_3,
input wire [31:0] filter_4,
input wire [31:0] filter_5,
      
input wire [31:0] filter_6,
input wire [31:0] filter_7,
input wire [31:0] filter_8,

output reg [31:0] Result_out,
output reg ready_dot
);
wire [31:0] window_filter;
integer i;
integer timer= 0;
wire [31:0]  Filter_arr[8:0];
wire [31:0]  Img_bit_arr[8:0];
wire [31:0]  Multipication_reg[9:0];
wire [31:0]  Multipication_wire[9:0];

wire [31:0]  addition_reg_inital[8:1]; // Only 4 is used
wire [31:0]  addition_reg_second[1:0]; // All used
wire [31:0]  addition_reg_third; // All used

wire ready_mult_out;
reg initate_multipliers,initate_adders;
reg initate_second_stage,initate_third_stage,initate_final_stage;
wire ready_inital_adders,ready_second_stage,ready_third_stage,ready_final_stage;

// Load the filters, Img bits to an array for convinence
    //  Load Filters
assign Filter_arr[0] = filter_0;
assign Filter_arr[1] = filter_1;
assign Filter_arr[2] = filter_2;
assign Filter_arr[3] = filter_3;  
assign Filter_arr[4] = filter_4; 
assign Filter_arr[5] = filter_5; 
assign Filter_arr[6] = filter_6;  
assign Filter_arr[7] = filter_7; 
assign Filter_arr[8] = filter_8; 
    // Load Img Bits
assign Img_bit_arr[0] = img_bit_0;
assign Img_bit_arr[1] = img_bit_1;
assign Img_bit_arr[2] = img_bit_2;
assign Img_bit_arr[3] = img_bit_3;  
assign Img_bit_arr[4] = img_bit_4; 
assign Img_bit_arr[5] = img_bit_5; 
assign Img_bit_arr[6] = img_bit_6;  
assign Img_bit_arr[7] = img_bit_7; 
assign Img_bit_arr[8] = img_bit_8; 


                    

// FSM States
reg [2:0]Dot_Product_Stage_reg = 3'b000;

localparam Iniate                      = 3'b000,
           Initate_Multi_param         = 3'b001,
           Initate_first_stage_param   = 3'b010,
           Initate_second_stage_param  = 3'b011,
           Initate_third_stage_param   = 3'b100,
           Initate_final_stage_param   = 3'b101,
           Ready                       = 3'b110;

always @(posedge clk) begin
case(Dot_Product_Stage_reg) 

Iniate                    : begin 
    if(initate == 1)   
    Dot_Product_Stage_reg <= Initate_Multi_param  ;
    end
Initate_Multi_param           : begin  
                     
                        initate_multipliers <= 1'b1;
                        timer<= timer + 1;
                        if(ready_mult_out == 1)
                        Dot_Product_Stage_reg <= Initate_first_stage_param  ;               
                        end
Initate_first_stage_param     :begin
                        initate_multipliers <=1'b0;
                        initate_adders <=1'b1;
                        timer<= timer + 1;
                        if(ready_inital_adders == 1)
                        Dot_Product_Stage_reg <= Initate_second_stage_param  ;               
                        end
Initate_second_stage_param    : begin 
                        initate_adders <= 1'b0;
                        initate_second_stage =  1;
                        if(ready_second_stage == 1)
                        Dot_Product_Stage_reg <= Initate_third_stage_param   ;               
                        end
Initate_third_stage_param     :begin 
                        initate_second_stage = 0;
                        initate_third_stage =  1;
                        if(ready_third_stage == 1)
                       Dot_Product_Stage_reg <= Initate_final_stage_param   ;               
                        end
Initate_final_stage_param     :begin 
                        initate_third_stage = 0;
                        initate_final_stage =  1;
                      if(ready_final_stage == 1)
                        Dot_Product_Stage_reg <= Ready  ;               
                        end
Ready                  :begin
                        initate_final_stage =  0;
                        ready_dot <= 1;
                        end
            
default:ready_dot <= 1;

endcase
end

genvar numof_multiplier;                                
generate 
for (numof_multiplier = 0; numof_multiplier < filtersize +1 ; numof_multiplier = numof_multiplier + 1) begin
IEEE_FPU_mult_i(.initate(initate_multipliers),.a_in(Img_bit_arr[numof_multiplier]),.b_in(Filter_arr[numof_multiplier]),.clk(clk),.Result(Multipication_reg[numof_multiplier]),.ready_mult_out(ready_mult_out));
if(numof_multiplier % 2 == 1)   // Dont assume this numbers have any meaning
FPU_addition_uni_t first_stage_adders(.clk(clk),.initate(initate_adders),.a_in(Multipication_reg[numof_multiplier-1]),.b_in(Multipication_reg[numof_multiplier]),.ready(ready_inital_adders),.result(addition_reg_inital[numof_multiplier]));
if(numof_multiplier % 4 == 3)
FPU_addition_uni_t  second_stage_adders(.clk(clk),.initate(initate_second_stage),.a_in(addition_reg_inital[numof_multiplier-2]),.b_in(addition_reg_inital[numof_multiplier]),.ready(ready_second_stage),.result(addition_reg_second[numof_multiplier%3])); // numof_multiplier % 3
if(numof_multiplier % 7 == 6)
FPU_addition_uni_t  third_stage_adder(.clk(clk),.initate(initate_third_stage),.a_in(addition_reg_second[0]),.b_in(addition_reg_second[1]),.ready(ready_third_stage),.result(addition_reg_third));
if(numof_multiplier == 9)
FPU_addition_uni_t  final_adder(.clk(clk),.initate(initate_final_stage),.a_in(addition_reg_third),.b_in(Img_bit_arr[8]),.ready(ready_final_stage),.result(window_filter));      
end endgenerate   

// Load the filters, Img bits to an array for convinence




                           
endmodule
