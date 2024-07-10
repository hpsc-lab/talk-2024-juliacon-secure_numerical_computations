function L_inf(v1, v2)
    return maximum(abs.(v1-v2))
end

function L_2(v1, v2)
    return sum((v1-v2).^2)^0.5
end

# setup OpenFHE
function init_setup(mult_depth, N)
    cc, mult_depth =  generate_secure_cryptocontext(mult_depth, N)
    context = SecureContext(OpenFHEBackend(cc))
    public_key, private_key = generate_keys(context)
    init_multiplication!(context, private_key)
    init_bootstrapping!(context, private_key)
    init_rotation!(context, private_key, [1, -5, 25])
    return private_key, public_key, context, mult_depth
end
# init cipher and plaintexts
function init_data(context, public_key, N)
    u_sin = zeros(N)
    for i in range(1, N)
        u_sin[i] = sin(2*pi*i/N)
    end
    u_factor = zeros(N)
    u_factor[1:end] .= 1 + pi/30
    ptxt_sin = PlainVector(u_sin, context)
    ptxt_factor = PlainVector(u_factor, context)
    ciph_sin = encrypt(ptxt_sin, public_key)
    ciph_factor = encrypt(ptxt_factor, public_key)
    return ciph_sin, ciph_factor, ptxt_factor, u_sin
end

function callback_run(u, t, ode, callback, i)
    u_approx = collect(decrypt(u, callback.private_key))
    push!(callback.result_step, callback.norm(callback.exact(t), u_approx))
    push!(callback.time_step, Float64(time_ns() - callback.start_time)*10^-9)
    push!(callback.steps, i+1)
    callback.sample_size+=length(u_approx)
end

function callback_record(u, t, ode, callback, i, container)
    u_approx = collect(decrypt(u, callback.private_key))
    push!(container, u_approx)
    push!(callback.steps, i+1)
    push!(callback.time_step, Float64(time_ns() - callback.start_time)*10^-9)
end

function callback_compare(u, t, ode, callback, i, container)
    u_approx = collect(decrypt(u, callback.private_key))
    push!(callback.result_step, callback.norm(container[div(i, callback.frequency)+1], u_approx))
    push!(callback.steps, i+1)
    push!(callback.time_step, Float64((time_ns() - callback.start_time)*1e-9))
end

