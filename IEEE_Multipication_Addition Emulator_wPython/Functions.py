from itertools import count
from re import L


global mantissa_len 
global expo_len 
mantissa_len= 23
expo_len = 8

#For size purposes

def unpacktovalue (val,val_len):
    assert(type(val) == list)                   # This function unpacks the list
    lenofpresentvalues = len(val)
    assert(val_len >= lenofpresentvalues)       # This is array cropping, not unpacking !!
                                                # Enter {val_len} smaller bigger or equal to {len(val)}
    bin_str = ""
    for x in range (0,val_len):
        if(x<lenofpresentvalues):
           bin_str =  (bin_str + str(val[x]))
        else:
           bin_str =  (bin_str + str(0))

    return bin_str                              ##Returns string

def packtoarray(val,val_len):
    assert(type(val) == int)                    # This function packs the number to binary array
    binary_represent = list(str(bin(val)))

    lenofpresentvalues = len(binary_represent)

    till = val_len - (lenofpresentvalues-2)

    mynewlist = binary_represent[val_len-1:0]       ##>>>>>>>>>>>>>>>This does not feel rigth (does not cause probelems thoguh(Probably))
    #binary_represent[lenofpresentvalues-2:till]

    for x in range (0,val_len):
        if(x<lenofpresentvalues-2):
            # 0'b represented as
            mynewlist.append(binary_represent[(lenofpresentvalues-1)-x])
        else:
            mynewlist.append("0")

        # Appended with undesirable order so I switch
        reversed_list = list(reversed(mynewlist))

    return val_len, reversed_list


def packtoarray_msb(val,val_len):
    assert(type(val) == int)                    # This function packs the number to binary array
    binary_represent = list(str(bin(val)))

    lenofpresentvalues = len(binary_represent)

    mynewlist = binary_represent[val_len-1:0]
    #binary_represent[lenofpresentvalues-2:till]

    for x in range (0,val_len):
        if(x<lenofpresentvalues-2):
            # 0'b represented as
            mynewlist.append(binary_represent[x+2])
        else:
            mynewlist.append("0")

    return val_len, mynewlist #Testing

# This function packs the number to binary array 
# Purpose is to add the invisible one to  
"""""
def denormilize_mantissa(val,val_expo):         
    assert(type(val) == int)                    
    val = val >>1 
    val_expo = val_expo + 1
    _,array_val = packtoarray(val,mantissa_len)

    array_val[0] = "1"              ## Adds implied leading || could have done this: 1-shift rigth 2-add 2**23 

    return array_val, val_expo
"""
def denormilize_mantissa(val,val_expo):         
    assert(type(val) == int)                    
    _,val = packtoarray(val,mantissa_len)
    assert(type(val) == list)
    val.insert(0,"1")               ## Equvalent to shift
                                    ## Adds implied leading || could have done this: 1-shift rigth 2-add 2**23 
    val_expo = val_expo + 1
    return val, val_expo


# This function packs the number to binary array 
# Purpose is to add the invisible one to  
def multipication_normalize(val):  
    assert(type(val) == int)                    
    _,array_val = packtoarray(val,expo_len)
                                    ## Adds implied leading || could have done this: 1-shift rigth 2-add 2**23 
    return array_val


def normalize(val,expo):                 # !! Insert denormalized values only 
    assert(type(val) == list)            # This function inputs a list
    assert(type(expo) == int)            # This function inputs a list    

    count = 0
    for x in range (0,len(val)):
        if(val[x] == "1"):               # Becareful items are in form of string !!
            count =  x                   # The index of first one (Which we will disapear because it is implied)        
            expo = expo -x
            break

    if(count != 0):        
        for y in range (0,count): 
            del val[y]                      # Deletes the zeros(not actually neccesery)
    else:
        print("Already Normalized")
    
    return val,expo
        
    
                                    ## Adds implied leading || could have done this: 1-shift rigth 2-add 2**23 
    #return array_val

def finalize_mantissa(val,expo):
    assert(type(val) == list)            # This function inputs a list
    del val[0]
    value = unpacktovalue(val=val,val_len=mantissa_len)
    expo = expo - 1
    return value,expo





#myresult_3  = 3
#myresult,mynewexpo = denormilize_mantissa(myresult_3,1)
#
#print(myresult,"<--:My result        My new expo: -->",mynewexpo )
#print(len(myresult))

## Test the results
            #print( " \n \n ")
            #print( "---------------------------------------------- ")
            #myval_2 = 7
            #mynewlen,myresult_2 = Functions.packtoarray(myval_2,12)
            #print("-----> My Resutlt_2: " , myresult_2 , "My new len: ", mynewlen)

            #myresult = Functions.unpacktovalue(myresult_2,mynewlen)
            #print("-----> My Resutlt: " , myresult ,"My Result len" , len(myresult))



#   --- Use as imprort
        # mynewlen,myresult_2 = Functions.packtoarray(myval_2,12)
        # myresult = Functions.unpacktovalue(myresult_2,mynewlen)