
class IEEE_FPU:
    def __init__(self,value_sign,value_expo,value_mantissa):
        ## Decode the Floating point
        self.value_sign = value_sign
        assert(value_expo>=0)               # Exponent is unsigned (Although it can be negative {Bias:127} )
        self.value_expo = value_expo
        assert(value_mantissa>=0)           # Mantissa is unsigned 
        self.value_mantissa = value_mantissa

