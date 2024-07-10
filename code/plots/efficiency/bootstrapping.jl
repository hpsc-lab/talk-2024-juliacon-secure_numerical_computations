using SecureArithmetic, Plots, Measures
include("../../src/secure_simulations.jl")
include("../common_part.jl")

GC.gc()
GC.gc()
println("Free space: ", Sys.free_memory()/2^20, "MB")

N = 64
mult_depth = 15
private_key, public_key, context, _ = init_setup(mult_depth, N)
ciph_sin, _, _, u_sin = init_data(context, public_key, N)

# Bootstrapping
res = deepcopy(ciph_sin)
error_bootstrap = zeros(mult_depth)
for i in range(1, mult_depth)
    ptxt1 = decrypt(res, private_key)
    for j in range(1, mult_depth-2)
        global res = res*1.0
    end
    ptxt2 = decrypt(res, private_key)
    bootstrap!(res)
    error_bootstrap[i] = maximum(abs.(collect(decrypt(res, private_key)).-u_sin.-collect(ptxt2)+collect(ptxt1)))
end
# plot error
p1 = plot(range(1, mult_depth), error_bootstrap, label="data",
          xaxis="Number of bootstrappings", yaxis="L_inf error",
          foreground_color_legend = nothing, background_color_legend = nothing,
          ylims=(0.0, maximum(error_bootstrap)))
plot!(size=(400,300))
title!("Bootstrapping error", titlefontsize=12)



mult_depth_range = Int.(range(5, 25, 5))
time_bootstrap = zeros(length(mult_depth_range))
for i in range(1, length(mult_depth_range))
    local mult_depth = mult_depth_range[i]
    local private_key, public_key, context, mult_depth_resulted = init_setup(mult_depth, N)
    mult_depth_range[i] = mult_depth_resulted
    local ciph_sin, _, _, _ = init_data(context, public_key, N)
    # Bootstrapping
    start = time_ns()
    bootstrap!(ciph_sin)
    finish = time_ns()
    time_bootstrap[i] = (finish-start)*10^-9
    GC.gc()
end
# plot time
p2 = plot(mult_depth_range, time_bootstrap, label="data",
          xaxis="Multiplicative depth", yaxis="time, s",
          foreground_color_legend = nothing, background_color_legend = nothing,
          ylims=(0.0, maximum(time_bootstrap)))
plot!(size=(400,300))
title!("Time for a single bootstrapping", titlefontsize=12)

p3 = plot(p1, p2, layout = @layout([B C]), margin=4mm)
plot!(size=(800,300))
savefig(p3, "out/efficiency/bootstrapping.pdf")
