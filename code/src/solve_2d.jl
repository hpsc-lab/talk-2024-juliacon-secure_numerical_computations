function solve(ode::ODE{T, LinearScalarAdvectionEquation2D, 
    Semidiscretization2D}, method::String, callback=nothing) where {T}
    if method == "1st order FD"
        return solve_1st_order_FD(ode, callback)
    elseif method == "Lax-Wendroff"
        return solve_Lax_Wendroff(ode, callback)
    else
        error("No such method, currently implemented: 1st order FD, Lax-Wendroff")
    end
end

function solve_1st_order_FD(ode::ODE{T, LinearScalarAdvectionEquation2D, 
        Semidiscretization2D, PeriodicBoundaryConditions}, callback) where {T}

    u = deepcopy(ode.u0)
    dt = ode.dt
    t = ode.time_span[1]
    N_steps = ode.N_steps
    r_x = ode.eq.a[1]*dt/ode.semi.dx
    r_y = ode.eq.a[2]*dt/ode.semi.dy
    mult_depth_solve = 2
    mult_depth_bootstrap = 2
    mult_depth_required = mult_depth_solve + mult_depth_bootstrap + !ode.scale_one
    for i in range(0, N_steps-1)
        if level(u) + mult_depth_required > ode.mult_depth
            if !ode.scale_one
                u = u * (1/ode.scale_value)
            end
            u = bootstrap!(u)
            if !ode.scale_one
                u = u * ode.scale_value
            end
        end
        # perform step
        if ode.eq.a[1]>0 && ode.eq.a[2]>0
            u = u - (u - circshift(u, (0, 1)))*r_x - (u - circshift(u, (-1, 0)))*r_y
        elseif ode.eq.a[1]<=0 && ode.eq.a[2]>0
            u = u - (u - circshift(u, (0, -1)))*r_x - (u - circshift(u, (-1, 0)))*r_y
        elseif ode.eq.a[1]>0 && ode.eq.a[2]<=0
            u = u - (u - circshift(u, (0, 1)))*r_x - (u - circshift(u, (1, 0)))*r_y
        else
            u = u - (u - circshift(u, (0, -1)))*r_x - (u - circshift(u, (1, 0)))*r_y
        end
        t+=dt
        if !isnothing(callback) && i%callback.frequency == 0
            callback.run(u, t, ode, callback, i)
        end
        # run garbage collector for ciphertext simulations
        if u.context.backend isa OpenFHEBackend
            GC.gc()
        end
    end
    u
end

function solve_Lax_Wendroff(ode::ODE{T, LinearScalarAdvectionEquation2D, 
        Semidiscretization2D, PeriodicBoundaryConditions}, callback) where {T}

    u = deepcopy(ode.u0)
    dt = ode.dt
    t = ode.time_span[1]
    N_steps = ode.N_steps
    r_x = ode.eq.a[1]*dt/ode.semi.dx
    r_y = ode.eq.a[2]*dt/ode.semi.dy
    mult_depth_solve = 3
    mult_depth_bootstrap = 2
    mult_depth_required = mult_depth_solve + mult_depth_bootstrap + !ode.scale_one
    for i in range(0, N_steps-1)
        if level(u) + mult_depth_required > ode.mult_depth
            if !ode.scale_one
                u = u * (1/ode.scale_value)
            end
            u = bootstrap!(u)
            if !ode.scale_one
                u = u * ode.scale_value
            end
        end
        # perform step
        u = (1 - r_x*r_x - r_y*r_y)*u + (0.5*r_x*r_x - 0.5*r_x)*circshift(u, (0, -1)) +
            (0.5*r_x*r_x + 0.5*r_x)*circshift(u, (0, 1)) + (0.5*r_y*r_y - 0.5*r_y)*circshift(u, (1, 0)) +
            (0.5*r_y*r_y + 0.5*r_y)*circshift(u, (-1, 0)) + (0.25*r_x*r_y)*(circshift(u, (1, -1)) -
            circshift(u, (-1, -1)) - circshift(u, (1, 1)) + circshift(u, (-1, 1)))
        
        t+=dt
        if !isnothing(callback) && i%callback.frequency == 0
            callback.run(u, t, ode, callback, i)
        end
        # run garbage collector for ciphertext simulations
        if u.context.backend isa OpenFHEBackend
            GC.gc()
        end
    end
    u
end
