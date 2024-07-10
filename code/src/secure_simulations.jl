using OpenFHE
using SecureArithmetic
include("default_config.jl")
include("LinearScalarAdvectionEquation.jl")
include("Semidiscretization.jl")
include("BoundaryConditions.jl")
include("ODE.jl")
include("Callback.jl")
include("solve_1d.jl")
include("solve_2d.jl")