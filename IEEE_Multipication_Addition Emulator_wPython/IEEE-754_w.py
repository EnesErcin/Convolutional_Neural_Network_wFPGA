import math
from array import *
import Functions
import MainClasses

global mantissa_len 
global expo_len 
mantissa_len= 23
expo_len = 8

def compare_f(Value_1,Value_2):
    assert(isinstance(Value_1,MainClasses.IEEE_FPU))       #This is not a IEEE_FPU Class
    assert(isinstance(Value_2,MainClasses.IEEE_FPU))        #This is not a IEEE_FPU Class    
  
    assert not(Value_1.value_expo == 255 and   (Value_1.value_mantissa > 0))       # Value 1 is NAN
    assert not(Value_2.value_expo == 255 and   (Value_1.value_mantissa > 0))       # Value 2 is NAN

    print("\n \n")
    print("------- || COMPERISON STAGE ||------- ")

    #Compare the expos (unsigned way)
    if bool(Value_1.value_expo > Value_2.value_expo):
        expodif =  Value_1.value_expo - Value_2.value_expo
        compare = 0
        print("\n ")
        print("******---------- Value_1 Has bigger Expo")
    else:
        expodif =  Value_2.value_expo - Value_1.value_expo
        compare = 1
        print("\n ")
        print("******---------- Value_2 Has bigger Expo")

    # Actually return equalize_expo(compare,expodif,Value_2,Value_1)
    return compare,expodif 

def equalize_expo(compare,expodif,Value_2,Value_1):
    #print("\n \n")
    #print("------- || EQUALIZED EXPONENT STAGE ||------- ")
    
    if(compare == 1):      ########## Value 2 has bigger expo -- // compare === 1  //
        Biggerexpo = Value_2
        Smallerexpo = Value_1
    elif(compare == 0):    ########## Value 1 has bigger expo -- // compare === 0  //
        Biggerexpo = Value_1
        Smallerexpo = Value_2
    else:
        assert(False)      ########## Inft or NAN values

    result_sign_end = Biggerexpo.value_sign
    # Mantissa of Samllerexpo should be shifted __right__ until exponents are same
    # But first implied leading one should be added  -- Step: Denormalization
    denormalized_mantsisa,denormalized_expo = Functions.denormilize_mantissa(Smallerexpo.value_mantissa,Smallerexpo.value_expo)
    denormalized_mantissa_val = Functions.unpacktovalue(denormalized_mantsisa,mantissa_len)
    denormalized_mantissa_val = int(denormalized_mantissa_val,2)
    smaller_val_mantissa = 0

    while  bool(denormalized_expo < Biggerexpo.value_expo):
        ## Shift Right Untill Exponents Are Equal
        smaller_val_mantissa = denormalized_mantissa_val >> 1
        denormalized_expo = denormalized_expo + 1
    else:
        return denormalized_expo,smaller_val_mantissa,result_sign_end
        
     
def add_and_checkforoverflow(mantissa_1, mantissa_2, common_expo):
        result_mantissa = mantissa_1 + mantissa_2
        mylen = len(bin(result_mantissa)) -2
        if(bool((mylen) = 24)):             # Already Normalized
            assert(common_expo<255)         # number Has reached infty
            print("\n \n")
            print("------- || add_and_checkforoverflow ||------- ")
        elif(bool((mylen) > 24)):
            # Mantissa Overflow
            pass
        elif(bool((mylen) < 24)):
            # Implied one does not exist as the msb
            # Find the msb of 1 then normalize
            pass
        return result_mantissa,common_expo






##### <<<<<<<<<<<<               How to add         >>>>>>>>>>>>>>>>>>>><<

##my_first_binary_1 = MainClasses.IEEE_FPU(value_sign = 0b0 , value_expo= 0b00000011, value_mantissa = 0b11111010000011110111011)
#my_first_binary_2 = MainClasses.IEEE_FPU(value_sign = 0b0 , value_expo= 0b00000101, value_mantissa = 0b00000010000011110111011)

 
            # compare_val , expo_diff= compare_f(my_first_binary_1,my_first_binary_2)            
            # modified_expo , modified_mantissa , result_sign = equalize_expo(compare_val,expo_diff,Value_2 = my_first_binary_2 ,Value_1 = my_first_binary_1) # Order matters
            # equalizeexpod_mantissa,common_expo = add_and_checkforoverflow(my_first_binary_2.value_mantissa,modified_mantissa,modified_expo)
            # print("------- || EVALUATE STAGE ||------- ")
            # print("Mantissa , Len: ", bin(equalizeexpod_mantissa), len(bin(equalizeexpod_mantissa)) -2, ">>>>>>> Results<<<<<",common_expo)


my_first_binary_1 = MainClasses.IEEE_FPU(value_sign = 0b0 , value_expo= 0b10000011, value_mantissa = 0b11111010000011110111011)
my_first_binary_2 = MainClasses.IEEE_FPU(value_sign = 0b0 , value_expo= 0b10000111, value_mantissa = 0b00000010000011110111011)

def multiply_expo(Value_1,Value_2):
    compare,expo_diff =compare_f(Value_1=Value_1,Value_2=Value_2)
    Value_1_expo_regular = Value_1.value_expo #+  129 # same as -127 twos complement
    Value_2_expo_regular = Value_2.value_expo #+  129
    
    newexpo = (Value_1_expo_regular) + (Value_2_expo_regular)
    print("\n newexpo:",bin(newexpo), len(bin(newexpo))-2 )
    newexpo_check = Functions.multipication_normalize(newexpo)
    print("\n \n")
    print(newexpo_check)
    newexpo_check = Functions.unpacktovalue(newexpo_check,expo_len)
    print(newexpo_check,type(newexpo_check))
    print("-----------------------------------------------------------")
    print("\n \n")
    print("Actual exponent values:" ,Value_1_expo_regular-127 ,bin(Value_1_expo_regular),Value_2_expo_regular-127,bin(Value_2_expo_regular))#"Addition Result >>>",newexpo-127)
    #print("#################### New expo --> " , newexpo ,len(bin(newexpo))-2, bin(newexpo))
    print("############## Boolean test :: " , len(bin(newexpo)), bool(len(bin(newexpo))-2 <= 9) ,bin(newexpo) ,"\n" )
    if(bool(len(bin(newexpo))-2 <= 9)): 
        _,tocheck = Functions.packtoarray(val=newexpo,val_len=expo_len) # The overflow in these step does not have a meaning
                                                                        # Thus we only care about 8 lsb = expo_len
        print("\n \n \n")
        print(tocheck)
        tocheck = Functions.unpacktovalue(val=tocheck,val_len=expo_len)
        print(tocheck ,"<- STR INT->" ,int(tocheck,2) )
        newexpo_f = int(tocheck,2) 
        newexpo_f = newexpo_f + 129 # (add -127) is the twos compliment
        print(newexpo_f ,"<- Adjusted           Bin -> " ,bin(newexpo_f)) 
        
        ## Overflow Check
        print("\n\n<<<<<<<<<<<<<<<<OverlofCheck<<<<<<<<<<<<<<<<")
        over_check = list(bin(newexpo_f))
        if(bool(len(over_check)-2 != 9 )):
            print("No overflow")
            print("Newexpo ,Newexpo_f ==>" , bin(newexpo),len(bin(newexpo)),bin(newexpo_f),len(bin(newexpo)))
            return newexpo
        else:
            print("Exonent has more digits than expected")
            print(newexpo_f)
            _,tocheck = Functions.packtoarray(val=newexpo,val_len=10)
            #print(tocheck,  "New Expo :     ", bin(newexpo), newexpo)
            return None


def multiply_mantissa(Value_1,Value_2,common_expo):
    assert(isinstance(Value_1,MainClasses.IEEE_FPU))       #This is not a IEEE_FPU Class
    assert(isinstance(Value_2,MainClasses.IEEE_FPU))        #This is not a IEEE_FPU Class    

    val_1_mantissa,_ =  Functions.denormilize_mantissa(Value_1.value_mantissa,Value_1.value_expo)
    val_2_mantissa,_ =  Functions.denormilize_mantissa(Value_2.value_mantissa,Value_2.value_expo)
    # Denormalized to add implied one

    val_1_mantissa =  Functions.unpacktovalue(val_1_mantissa,mantissa_len+1)
    val_2_mantissa =  Functions.unpacktovalue(val_2_mantissa,mantissa_len+1)

    assert(bool(len(val_1_mantissa) == 24 ))    ## Denormalized mantisas have 24 bits
    assert(bool(len(val_2_mantissa) == 24 ))    ## Denormalized mantisas have 24 bits

    val_1_mantissa =  int(val_1_mantissa,2)
    val_2_mantissa =  int(val_2_mantissa,2)

    new_mantissa_f = val_1_mantissa * val_2_mantissa

    index_of_first_one = len(bin(new_mantissa_f))-2
    assert( bool(index_of_first_one <= 48)   )       # Mantissa overflow -- Solution Normalize (If exponent allows)

    # multiply mantissas
    _,new_mantissa_f =  Functions.packtoarray_msb(new_mantissa_f,mantissa_len+1)  #!!!!!! pack_to_array Function starts from least significant bit :( --> Ideally: Should have a parameter to choose directions
    # Normalize (Find the value 1 of the most significant bit)
    print("---------------------------------------")
    print(common_expo)
    normalized_mantissa,newexpo = Functions.normalize(new_mantissa_f,common_expo)
    final_mantissa,final_expo = Functions.finalize_mantissa(normalized_mantissa,newexpo)
    print(newexpo)

    print(final_mantissa , len(final_mantissa), final_expo)
    #return



newexpo = multiply_expo(my_first_binary_1,my_first_binary_2)

#multiply_mantissa(my_first_binary_1,my_first_binary_2,newexpo)

