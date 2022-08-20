`timescale 1ns / 1ps


module Dot_product_test( );


//Definig inputs
reg[31:0] filter_0; 
reg[31:0] filter_1; 
reg[31:0] filter_2; 
     
reg[31:0] filter_3; 
reg[31:0] filter_4; 
reg[31:0] filter_5; 
   
reg[31:0] filter_6; 
reg[31:0] filter_7; 
reg[31:0] filter_8; 
reg[31:0] img_bit_0;
reg[31:0] img_bit_1;
reg[31:0] img_bit_2;
                  
reg[31:0] img_bit_3;
reg[31:0] img_bit_4;
reg[31:0] img_bit_5;
                  
reg[31:0] img_bit_6;
reg[31:0] img_bit_7;
reg[31:0] img_bit_8;
reg initate = 0;
//Outputs
wire [31:0]Result_out;
wire ready_dot;
          
reg clk;
parameter Clockperiod = 5;
initial clk = 1'b0;
always #(Clockperiod/2) clk = ~clk;
        
Dot_Product_Module 
#(.filtersize(9))
UUT(
.clk(clk),
.initate(initate),
.img_bit_0(img_bit_0),
.img_bit_1(img_bit_1),
.img_bit_2(img_bit_2),

.img_bit_3(img_bit_3),
.img_bit_4(img_bit_4),
.img_bit_5(img_bit_5),

.img_bit_6(img_bit_6),
.img_bit_7(img_bit_7),
.img_bit_8(img_bit_8),

.filter_0(filter_0),
.filter_1(filter_1),
.filter_2(filter_2),

.filter_3(filter_3),
.filter_4(filter_4),
.filter_5(filter_5),

.filter_6(filter_6),
.filter_7(filter_7),
.filter_8(filter_8),

.Result_out(Result_out),
.ready_dot(ready_dot)
);

integer               i    ; 

reg [31:0]filter_arr[8:0],img_arr[8:0];

initial begin 
$readmemh("filters_2.txt",filter_arr);  
load_fitlers();

$readmemh("img_bits_2.txt",img_arr);  
load_img();
end


always begin

#20 initate <= 1;
#5000 $finish();

end












task load_fitlers();
begin
filter_0 <= filter_arr[0];
filter_1 <= filter_arr[1];
filter_2 <= filter_arr[2];
        
filter_3 <= filter_arr[3];
filter_4 <= filter_arr[4];
filter_5 <= filter_arr[5];
        
filter_6 <= filter_arr[6];
filter_7 <= filter_arr[7];
filter_8 <= filter_arr[8];
end
endtask   
 
task load_img();
begin
img_bit_0 <= img_arr[0];
img_bit_1 <= img_arr[1];
img_bit_2 <= img_arr[2];
             
img_bit_3 <= img_arr[3];
img_bit_4 <= img_arr[4];
img_bit_5 <= img_arr[5];
             
img_bit_6 <= img_arr[6];
img_bit_7 <= img_arr[7];
img_bit_8 <= img_arr[8];
end
endtask  






            
endmodule
