struct ODE{Data, Equation, Semidiscretization, BoundaryConditions <: AbstractBoundaryConditions}
    u0::Data
    du0
    eq::Equation
    semi::Semidiscretization
    time_span::Tuple
    dt::Float64
    N_steps::Int64
    scale_value::Float64
    scale_one::Bool
    mult_depth::Int64
    boundary_conditions::BoundaryConditions
    function ODE(u0::Data, eq::Equation, semi::Semidiscretization, time_span::Tuple, N_steps::Int64,
                 scale_value::Float64, scale_one::Bool, mult_depth::Int64,
                 boundary_conditions::BoundaryConditions = PeriodicBoundaryConditions()
                ) where {Data, Equation, Semidiscretization, BoundaryConditions}
        dt = (time_span[2] - time_span[1])/N_steps
        new{Data, Equation, Semidiscretization, BoundaryConditions}(u0, nothing, eq, semi, time_span,
                                                                            dt, N_steps, scale_value, scale_one,
                                                                            mult_depth, boundary_conditions)
    end
    function ODE(u0::Data, du0::Data, eq::Equation, semi::Semidiscretization, time_span::Tuple, N_steps::Int64,
                 scale_value::Float64, scale_one::Bool, mult_depth::Int64,
                 boundary_conditions::BoundaryConditions = PeriodicBoundaryConditions()
                ) where {Data, Equation, Semidiscretization, BoundaryConditions}
        # for periodic BC dt have to be defined a bit different for correctness
        if boundary_conditions == PeriodicBoundaryConditions()
            dt = (time_span[2] - time_span[1])/(N_steps-1)
        else
            dt = (time_span[2] - time_span[1])/N_steps
        end
        new{Data, Equation, Semidiscretization, BoundaryConditions}(u0, du0, eq, semi, time_span,
                                                                            dt, N_steps, scale_value, scale_one,
                                                                            mult_depth, boundary_conditions)
    end
end

function set_initial_conditions!(u, t, init_cond::Function, semi::Semidiscretization1D)
        for i in range(1, semi.size)
            u[i] = init_cond(semi.nodes[i], t)
        end
end

function set_initial_conditions!(u, t, init_cond::Function, semi::Semidiscretization2D)
        for i in range(1, semi.size_x)
            for j in range(1, semi.size_y)
                u[i, j] = init_cond([semi.nodes_x[i], semi.nodes_y[j]], t)
            end
        end
end