`timescale 1ns / 1ps


module Dot_product_test( );
              
Dot_Product_Module UUT
(
.filtersize(9),
.clk(),
.initate(),
.img_bit_0(),
.img_bit_1(),
.img_bit_2(),

.img_bit_3(),
.img_bit_4(),
.img_bit_5(),

.img_bit_6(),
.img_bit_7(),
.img_bit_8(),

.filter_0(),
.filter_1(),
.filter_2(),

.filter_3(),
.filter_4(),
.filter_5(),

.filter_6(),
.filter_7(),
.filter_8(),

.Result_out(),
.ready_dot()
);
         
                        
endmodule
