using SecureArithmetic, Plots, Measures
include("../../src/secure_simulations.jl")
include("../common_part.jl")

GC.gc()
GC.gc()
println("Free space: ", Sys.free_memory()/2^20, "MB")

N = 64
mult_depth = 15
private_key, public_key, context, _ = init_setup(mult_depth, N)
ciph_sin, ciph_factor, ptxt_factor, u_sin = init_data(context, public_key, N)

# add ciphertext by ciphertext
res = deepcopy(ciph_sin)
exact = deepcopy(u_sin)
error_ciph_by_ciph = zeros(mult_depth)
for i in range(1, mult_depth)
    global res = res+ciph_factor
    global exact = exact.+(1 + pi/30)
    error_ciph_by_ciph[i] = maximum(abs.(exact.-collect(decrypt(res, private_key))))
end
# add ciphertext by plaintext
res = deepcopy(ciph_sin)
exact = deepcopy(u_sin)
error_ciph_by_plain = zeros(mult_depth)
for i in range(1, mult_depth)
    global res = res+ptxt_factor
    global exact = exact.+(1 + pi/30)
    error_ciph_by_plain[i] = maximum(abs.(exact.-collect(decrypt(res, private_key))))
end
# add ciphertext by scalar
res = deepcopy(ciph_sin)
exact = deepcopy(u_sin)
error_ciph_by_scalar = zeros(mult_depth)
for i in range(1, mult_depth)
    global res = res+(1 + pi/30)
    global exact = exact.+(1 + pi/30)
    error_ciph_by_scalar[i] = maximum(abs.(exact.-collect(decrypt(res, private_key))))
end
# plot error
p1 = plot(range(1, mult_depth), [error_ciph_by_ciph error_ciph_by_plain error_ciph_by_scalar],
          label=["ciphertext by ciphertext" "ciphertext by plaintext" "ciphertext by scalar"],
          xaxis="Number of additions", yaxis="L_inf error",
          foreground_color_legend = nothing, background_color_legend = nothing,
          ylims=(0.0, maximum(error_ciph_by_ciph)))
plot!(size=(400,300))
title!("Addition error", titlefontsize=12)



mult_depth_range = Int.(range(5, 25, 5))
time_ciph_by_ciph = zeros(length(mult_depth_range))
time_ciph_by_plain = zeros(length(mult_depth_range))
time_ciph_by_scalar = zeros(length(mult_depth_range))
for i in range(1, length(mult_depth_range))
    local mult_depth = mult_depth_range[i]
    local private_key, public_key, context, mult_depth_resulted = init_setup(mult_depth, N)
    mult_depth_range[i] = mult_depth_resulted
    local ciph_sin, ciph_factor, ptxt_factor, _ = init_data(context, public_key, N)
    # add ciphertext by ciphertext
    start = time_ns()
    ciph_sin+ciph_factor
    finish = time_ns()
    time_ciph_by_ciph[i] = (finish-start)*10^-9
    # add ciphertext by plaintext
    start = time_ns()
    ciph_sin+ptxt_factor
    finish = time_ns()
    time_ciph_by_plain[i] = (finish-start)*10^-9
    # add ciphertext by scalar
    start = time_ns()
    ciph_sin+(1 + pi/30)
    finish = time_ns()
    time_ciph_by_scalar[i] = (finish-start)*10^-9
    GC.gc()
end
# plot time
p2 = plot(mult_depth_range, [time_ciph_by_ciph time_ciph_by_plain time_ciph_by_scalar],
          label=["ciphertext by ciphertext" "ciphertext by plaintext" "ciphertext by scalar"],
          xaxis="Multiplicative depth", yaxis="time, s",
          foreground_color_legend = nothing, background_color_legend = nothing,
          ylims=(0.0, maximum(maximum.([time_ciph_by_ciph, time_ciph_by_plain, time_ciph_by_scalar]))))
plot!(size=(400,300))
title!("Time for a single addition", titlefontsize=12)

p3 = plot(p1, p2, layout = @layout([B C]), margin=4mm)
plot!(size=(800,300))
savefig(p3, "out/efficiency/add.pdf")
