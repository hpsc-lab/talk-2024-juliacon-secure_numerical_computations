include("../src/secure_simulations.jl")
function generate_setup(a, timespan, N_steps, span, N, context::SecureContext,
    depth, init_cond::Function, scale_value, public_key)

    eq = LinearScalarAdvectionEquation2D(a)
    semi = Semidiscretization2D(span, span, N, N)
    u0 = zeros(N, N)
    set_initial_conditions!(u0, timespan[1], init_cond, semi)
    ptxt_u0 = PlainMatrix(u0, context)
    u0 = encrypt(ptxt_u0, public_key)
    ode = ODE(u0, eq, semi, timespan, N_steps, scale_value, true, depth)
    return ode
end

function sin2pi_sin2pi(x, t)
    return sin(2*pi*x[1])*sin(2*pi*x[2])
end

function solution_linear_advection_equation2D(a, timespan, span, N, init_cond::Function)
    sol = zeros(N, N)
    dx = (span[2]-span[1])/N
    for i in range(1, N)
        for j in range(1, N)
            sol[j, i] = init_cond([span[1] + dx*(i-1) - timespan[2]*a[1],
                                   span[1] + dx*(j-1) + timespan[2]*a[2]], 0)
        end
    end
    return sol
end

function advection2d(mode, method, N::Int, N_steps::Int, timespan, a, mult_depth::Int, secure::Bool=false, callback=nothing)
    println("Test started in mode $mode, method=$method, N_x=$N, N_y=$N, N_steps=$N_steps, timespan=$timespan, a=$a, mult_depth=$mult_depth, secure=$secure")
    span = (0.0, 1.0)
    solution = []
    exact(t) = solution_linear_advection_equation2D(a, (0,t), span, N, sin2pi_sin2pi)
    if mode == "CIPHERTEXT"
        start = time_ns()
        N_round = Int(2^ceil(log2(N*N)))
        cc = nothing
        if secure
            cc, mult_depth =  generate_secure_cryptocontext(mult_depth, N_round)
        else
            cc, mult_depth =  generate_cryptocontext(1<<12, mult_depth, N_round)
        end
        context = SecureContext(OpenFHEBackend(cc))
        public_key, private_key = generate_keys(context)
        init_multiplication!(context, private_key)
        init_bootstrapping!(context, private_key)
        if method == "1st order FD" && a[1] > 0 && a[2] > 0
            init_matrix_rotation!(context, private_key, [(0, 1), (-1, 0)], (N, N))
        elseif method == "1st order FD" && a[1] <= 0 && a[2] > 0
            init_matrix_rotation!(context, private_key, [(0, -1), (-1, 0)], (N, N))
        elseif method == "1st order FD" && a[1] > 0 && a[2] <= 0
            init_matrix_rotation!(context, private_key, [(0, 1), (1, 0)], (N, N))
        elseif method == "1st order FD" && a[1] <= 0 && a[2] <= 0
            init_matrix_rotation!(context, private_key, [(0, -1), (1, 0)], (N, N))
        elseif method == "Lax-Wendroff"
            init_matrix_rotation!(context, private_key, [(1, 0), (-1, 0), (0, 1), (0, -1), (1, 1),
                                                         (-1, 1), (1, -1), (-1, -1)], (N, N))
        else
            error("You need to initialize rotation for your method=", method)
        end
        ode = generate_setup(a, timespan, N_steps, span, N, context, 
                             mult_depth, sin2pi_sin2pi, 1.0, public_key)

        conf_time = Float64(time_ns() - start)*1e-9
        start = time_ns()
        if !isnothing(callback)
            callback.private_key = private_key
            callback.exact = exact
            callback.start_time = start
        end
        u = solve(ode, method, callback)
        sol_time = Float64(time_ns() - start)*1e-9
        res = decrypt(u, private_key)
        solution = collect(res)
        println("Test finished in ", sol_time+conf_time, " s")
        return conf_time, sol_time, solution
    elseif mode == "PLAINTEXT"
        start = time_ns()
        context_unencrypted = SecureContext(Unencrypted())
        public_key, private_key = generate_keys(context_unencrypted)
        ode = generate_setup(a, timespan, N_steps, span, N, context_unencrypted, 
                             typemax(Int), sin2pi_sin2pi, 1.0, public_key)

        conf_time = Float64(time_ns() - start)*10^-9
        start = time_ns()
        if !isnothing(callback)
            callback.private_key = private_key
            callback.exact = exact
            callback.start_time = start
        end
        u = solve(ode, method, callback)
        sol_time = Float64(time_ns() - start)*10^-9
        res = decrypt(u, private_key)
        solution = collect(res)
        println("Test finished in ", sol_time+conf_time, " s")
        return conf_time, sol_time, solution
    elseif mode == "EXACT"
        solution = solution_linear_advection_equation2D(a, timespan, span, N, sin2pi_sin2pi)
        println("Test finished")
        return solution
    else
        println("invalid mode")
    end
end