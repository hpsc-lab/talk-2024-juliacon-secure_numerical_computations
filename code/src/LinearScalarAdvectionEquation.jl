struct LinearScalarAdvectionEquation1D
    #struct defines linear scalar advection equation 1D:
    #∂u/∂t + a ∂u/∂x = 0
    a::Float64
end

struct LinearScalarAdvectionEquation2D
    #struct defines linear scalar advection equation 2D:
    #∂u/∂t + a[1] ∂u/∂x + a[2] ∂u/∂x= 0
    a::Tuple{Float64, Float64}
end