module Delegate

export @delegateInto_1field1var   ,  @delegate1f1v,     @delegate,  # aliases for @delegateInto_1field1var
       @delegateInto_1field2vars  ,  @delegate1f2v,
       @delegateInto_2fields1var  ,  @delegate2f1v,
       @delegateInto_3fields1var  ,  @delegate3f1v,
       @delegateInto_2fields2vars ,  @delegate2f2v,
       @delegateWith_1field1var   ,  @delegateWrap1f1v, @delegateWrap,  # aliases for @delegateWith_1field1var
       @delegateWith_1field2vars  ,  @delegateWrap1f2v,
       @delegateWith_2fields1var  ,  @delegateWrap2f1v,
       @delegateWith_3fields1var  ,  @delegateWrap3f1v,
       @delegateWith_2fields2vars ,  @delegateWrap2f2v
       

#=
    based on original work by John Myles White and Toivo Henningsson
    (see the end of this file for source code references)
=#



"""

A macro for type field delegation over func{T}(arg::T)
    
    import Base: length, last
    
    type MyInts     elems::Vector{Int} end;
    type MyNums{T}  elems::Vector{T}   end;

    @delegateInto_1field1var( MyInts, elems, [ length,  last ] );
    @delegateInto_1field1var( MyNums, elems, [ length,  last ] );

    myInts = MyInts([5, 4, 3, 2, 1]);
    myNums = MyNums([1.0, 2.0, 3.0]);
    
    length(myInts), length(myNums)   # 5, 3
    last(myInts),   last(myNums)     # 1, 3.0

"""
macro delegateInto_1field1var(sourcetype, field1, targets)
  typesname  = esc( :($sourcetype) )
  field1name = esc(Expr(:quote, field1))
  funcnames  = targets.args
  n = length(funcnames)
  fdefs = Array(Any, n)
  for i in 1:n
    funcname = esc(funcnames[i])
    fdefs[i] = quote
                 ($funcname)(a::($typesname), args...) = ($funcname)(getfield(a,($field1name)), args...)
               end
    end
  return Expr(:block, fdefs...)
end

"""
see @delegateInto_1field1var
"""
macro delegate(sourcetype, field1, targets)
    quote
        @delegateInto_1field1var($sourcetype, $field1, $targets)
    end
end

"""
see @delegateInto_1field1var
"""
macro delegate1f1v(sourcetype, field1, targets)
    quote
        @delegateInto_1field1var($sourcetype, $field1, $targets)
    end
end

# for methods that take two equi-typed source arguments

"""

A macro for type field delegation over func{T}(arg1::T, arg2::T)

    import Base: (<), (<=)
    
    type MyInt  val::Int  end;

    @delegateInto_1field2vars( MyInt, val, [ (<), (<=) ] );

    myFirstInt  = MyInt(3)
    mySecondInt = MyInt(7)

    myFirstInt  <  mySecondInt  # true
    mySecondInt <= myFirstInt   # false

"""     
macro delegateInto_1field2vars(sourcetype, field1, targets)
  typesname  = esc( :($sourcetype) )
  field1name = esc(Expr(:quote, field1))
  funcnames  = targets.args
  n = length(funcnames)
  fdefs = Array(Any, n)
  for i in 1:n
    funcname = esc(funcnames[i])
    fdefs[i] = quote
                 ($funcname)(a::($typesname), b::($typesname), args...) = 
                   ($funcname)(getfield(a,($field1name)), getfield(b,($field1name)), args...)
               end
    end
  return Expr(:block, fdefs...)
end

"""
see @delegateInto_1field2vars
"""
macro delegate1f2v(sourcetype, field1, targets)
    quote
        @delegateInto_1field2vars($sourcetype, $field1, $targets)
    end
end

# for methods that use multiple fields from the source type

"""

A macro for type field delegation over two fields of T func{T}(arg::T)
    
    import Base: hypot
    
    type RightTriangle   legA::Float64; legB::Float64;  end;

    @delegateInto_2fields1var( RightTriangle, legA, legB, [ hypot, ] );
  
    myRightTriangle  = RightTriangle( 3.0, 4.0 )
    
    hypot(myRightTriangle)   #  5.0

"""     
macro delegateInto_2fields1var(sourcetype, field1, field2, targets)
  typesname  = esc( :($sourcetype) )
  field1name = esc(Expr(:quote, field1))
  field2name = esc(Expr(:quote, field2))
  funcnames  = targets.args
  n = length(funcnames)
  fdefs = Array(Any, n)
  for i in 1:n
    funcname = esc(funcnames[i])
    fdefs[i] = quote
                 ($funcname)(a::($typesname), args...) = 
                   ($funcname)(getfield(a, ($field1name)), getfield(a, ($field2name)), args...)
               end
    end
  return Expr(:block, fdefs...)
end

"""
see @delegateInto_2fieldsd1var
"""
macro delegate2f1v(sourcetype, field1, field2, targets)
    quote
        @delegateInto_2field1var($sourcetype, $field1, $field2, $targets)
    end
end


"""

A macro for type field delegation over three fields of T func{T}(arg::T)
    
    function add3{T<:Float64}(a::T, b::T, c::T)
        ab   = a+b
        hi   = ab+c
        lo   = a-(ab-b)
        lo  += b-(ab-a)
        lo  += c-(hi-ab)
        hi, lo
    end    
    
    type ThreeFloats a::Float64; B::Float64;  C::Float64;  end;

    @delegateInto_3fields1var( ThreeFloats, a, b, c, [ add3, ] );
  
    myThreeFloats = ThreeFloats( sqrt(2.), sqrt(22.), sqrt(15.) )
    
    add3(myThreeFloats)   #  (9.977612668403943,-6.661338147750939e-16)
    
"""     
macro delegateInto_3fields1var(sourcetype, field1, field2, field3, targets)
  typesname  = esc( :($sourcetype) )
  field1name = esc(Expr(:quote, field1))
  field2name = esc(Expr(:quote, field2))
  field3name = esc(Expr(:quote, field3))
  funcnames  = targets.args
  n = length(funcnames)
  fdefs = Array(Any, n)
  for i in 1:n
    funcname = esc(funcnames[i])
    fdefs[i] = quote
                 ($funcname)(a::($typesname), args...) = 
                   ($funcname)(getfield(a, ($field1name)), getfield(a, ($field2name)), getfield(a, ($field3name)), args...)
               end
    end
  return Expr(:block, fdefs...)
end

"""
see @delegateInto_3fields1var
"""
macro delegate3f1v(sourcetype, field1, field2, field3, targets)
    quote
        @delegateInto_1field2vars($sourcetype, $field1, $field2, $field3, $targets)
    end
end


"""
see help for @delegateInto_1field2vars
"""
macro delegateInto_2fields2vars(sourcetype, field1, field2, targets)
  typesname  = esc( :($sourcetype) )
  field1name = esc(Expr(:quote, field1))
  field2name = esc(Expr(:quote, field2))
  funcnames  = targets.args
  n = length(funcnames)
  fdefs = Array(Any, n)
  for i in 1:n
    funcname = esc(funcnames[i])
    fdefs[i] = quote
                 ($funcname)(a::($typesname), b::($typesname), args...) = 
                     ($funcname)(getfield(a, ($field1name)), getfield(a, ($field2name)),
                                 getfield(b, ($field1name)), getfield(b, ($field2name)), 
                                 args...)
               end
    end
  return Expr(:block, fdefs...)
end

"""
see @delegateInto_2fields2vars
"""
macro delegate2f2v(sourcetype, field1, field2, targets)
    quote
        @delegateInto_2fields2vars($sourcetype, $field1, $field2, $targets)
    end
end



# for methods that take one typed argument and return an iso-typed result

"""

A macro for type field delegation with an iso-typed result over func{T}(arg::T)
    
    import Base: (-), abs
    
    type MyInt  val::Int  end;

    @delegateWith_1field1var( MyInt, val, [ (-), abs ] );

    myFirstInt  = MyInt(3)

    myIntNegates   = -myFirstInt              # MyInt(-3)
    myIntAbsValues = abs(myIntNegates)        # MyInt( 3)    

"""
macro delegateWith_1field1var(sourcetype, field1, targets)
  typesname  = esc( :($sourcetype) )
  field1name = esc(Expr(:quote, field1))
  funcnames  = targets.args
  n = length(funcnames)
  fdefs = Array(Any, n)
  for i in 1:n
    funcname = esc(funcnames[i])
    fdefs[i] = quote
                 ($funcname)(a::($typesname), args...) = 
                   ($typesname)( ($funcname)(getfield(a,($field1name)), args...) )
               end
    end
  return Expr(:block, fdefs...)
end

"""
see @delegateWith_1field1var
"""
macro delegateWrap(sourcetype, field1, targets)
    quote
        @delegateWith_1field1var($sourcetype, $field1, $targets)
    end
end


"""
see @delegateWith_1field1var
"""
macro delegateWrap1f1v(sourcetype, field1, targets)
    quote
        @delegateWith_1field1var($sourcetype, $field1, $targets)
    end
end

# for methods that take two equi-typed source arguments) and return an iso-typed result

"""

A macro for type field delegation with an iso-typed result over func{T}(arg1::T, arg2::T)

    import Base: (+), (-), (*)
    
    type MyInt  val::Int  end;

    @delegateWith_1field2vars( MyInt, val, [ (+), (-), (*) ] );

    myFirstInt   = MyInt(3)
    mySecondInt  = MyInt(7)

    myIntAdds       = myFirstInt + mySecondInt    # MyInt(10)
    myIntSubtracts  = myFirstInt - mySecondInt    # MyInt(-4)
    myIntMultiplies = myFirstInt * mySecondInt    # MyInt(21) 

"""
macro delegateWith_1field2vars(sourcetype, field1, targets)
  typesname  = esc( :($sourcetype) )
  field1name = esc(Expr(:quote, field1))
  funcnames  = targets.args
  n = length(funcnames)
  fdefs = Array(Any, n)
  for i in 1:n
    funcname = esc(funcnames[i])
    fdefs[i] = quote
                 ($funcname)(a::($typesname), b::($typesname), args...) = 
                   ($typesname)( ($funcname)(getfield(a,($field1name)), getfield(b,($field1name)), args...) )
               end
    end
  return Expr(:block, fdefs...)
end

"""
see @delegateWith_1field2vars
"""
macro delegateWrap1f2v(sourcetype, field1, targets)
    quote
        @delegateWith_1field2var($sourcetype, $field1, $targets)
    end
end


# for methods that use two fields of the source type and return an iso-typed result

"""

A macro for type field delegation with an iso-typed result over two fields of T func{T}(arg::T)

    function renormalize(a::Float64, b::Float64)
        hi = a + b
        t = hi - a
        lo = (a - (hi - t)) + (b - t)
        hi,lo
    end

    type HiLo  hi::Float64; lo::Float64;   end;
    

    @delegateWith_2fields1var( HiLo, hi, lo, [ renormalize, ] );

    myHiLo = renormalize( HiLo(12.555555555, 8000.333333333) ) # HiLo(8012.89,4.44089e-14)
    showall(myHiLo)     # HiLo(8012.888888888,4.440892098500626e-14)

"""
macro delegateWith_2fields1var(sourcetype, field1, field2, targets)
  typesname  = esc( :($sourcetype) )
  field1name = esc(Expr(:quote, field1))
  field2name = esc(Expr(:quote, field2))
  funcnames  = targets.args
  n = length(funcnames)
  fdefs = Array(Any, n)
  for i in 1:n
    funcname = esc(funcnames[i])
    fdefs[i] = quote
                 ($funcname)(a::($typesname), args...) = 
                    ($typesname)( ($funcname)(getfield(a, ($field1name)), getfield(a, ($field2name)), args...)... )
               end
    end
  return Expr(:block, fdefs...)
end

"""
see @delegateWith_2fields1var
"""
macro delegateWrap2f1v(sourcetype, field1, field2, targets)
    quote
        @delegateWith_2fields1var($sourcetype, $field1, $field2, $targets)
    end
end


"""
see help for @delegateWith_2fields1var
"""
macro delegateWith_3fields1var(sourcetype, field1, field2, field3, targets)
  typesname  = esc( :($sourcetype) )
  field1name = esc(Expr(:quote, field1))
  field2name = esc(Expr(:quote, field2))
  field3name = esc(Expr(:quote, field3))
  funcnames  = targets.args
  n = length(funcnames)
  fdefs = Array(Any, n)
  for i in 1:n
    funcname = esc(funcnames[i])
    fdefs[i] = quote
                 ($funcname)(a::($typesname), args...) = 
                    ($typesname)( ($funcname)(getfield(a, ($field1name)), getfield(a, ($field2name)), getfield(a, ($field3name)), args...)... )
               end
    end
  return Expr(:block, fdefs...)
end


"""
see @delegateWith_3fields1var
"""
macro delegateWrap3f1v(sourcetype, field1, field2, field3, targets)
    quote
        @delegateWith_3fields1var($sourcetype, $field1, $field2, $field3, $targets)
    end
end


"""
see help for @delegateWith_1field2vars
"""
macro delegateWith_2fields2vars(sourcetype, field1, field2, targets)
  typesname  = esc( :($sourcetype) )
  field1name = esc(Expr(:quote, field1))
  field2name = esc(Expr(:quote, field2))
  funcnames  = targets.args
  n = length(funcnames)
  fdefs = Array(Any, n)
  for i in 1:n
    funcname = esc(funcnames[i])
    fdefs[i] = quote
                 ($funcname)(a::($typesname), b::($typesname), args...) = 
                    ($typesname)( ($funcname)(getfield(a, ($field1name)), getfield(a, ($field2name)),
                                              getfield(b, ($field1name)), getfield(b, ($field2name)), 
                                              args...)... )
               end
    end
  return Expr(:block, fdefs...)
end

"""
see @delegateWith_2fields2vars
"""
macro delegateWrap2f2v(sourcetype, field1, field2, targets)
    quote
        @delegateWith_2fields2vars($sourcetype, $field1, $field2, $targets)
    end
end




end # module Delegate

#=
    initial implementation
    (description and logic from https://gist.github.com/johnmyleswhite/5225361)
    additional macro text from
      https://github.com/JuliaLang/DataStructures.jl/blob/master/src/delegate.jl
     
    and from Toivo for delegation with nary ops
    (https://groups.google.com/forum/#!msg/julia-dev/MV7lYRgAcB0/-tS50TreaPoJ)
    
    julia> type T
               x
           end
    julia> import Base.sin, Base.cos
    julia> for f in (:+, :- )    # delegate binary + and - to T.x
               @eval $f(a::T, b::T) = $f(a.x, b.x)
           end
    julia> for f in (:sin, :cos) # delegate sin and cos
               @eval $f(a::T) = $f(a.x)
           end
=#
