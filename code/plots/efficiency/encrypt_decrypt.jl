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

# encrypt-decrypt
res = deepcopy(ciph_sin)
exact = deepcopy(u_sin)
error_encrypt_decrypt = zeros(mult_depth)
for i in range(1, mult_depth)
    ptxt = decrypt(res, private_key)
    global res = encrypt(PlainVector(collect(ptxt), res.context), public_key)
    error_encrypt_decrypt[i] = maximum(abs.(exact.-collect(decrypt(res, private_key))))
end
# plot error
p1 = plot(range(1, mult_depth), error_encrypt_decrypt, label="data",
          xaxis="Number of encryption-decryptions", yaxis="L_inf error",
          foreground_color_legend = nothing, background_color_legend = nothing,
          ylims=(0.0, maximum(error_encrypt_decrypt)))
plot!(size=(400,300))
title!("Consequtive encryption-decryption error", titlefontsize=12)



mult_depth_range = Int.(range(5, 25, 5))
time_encrypt = zeros(length(mult_depth_range))
time_decrypt = zeros(length(mult_depth_range))
for i in range(1, length(mult_depth_range))
    local mult_depth = mult_depth_range[i]
    local private_key, public_key, context, mult_depth_resulted = init_setup(mult_depth, N)
    mult_depth_range[i] = mult_depth_resulted
    local ciph_sin, _, _, _ = init_data(context, public_key, N)
    # decrypt
    start = time_ns()
    decrypt(ciph_sin, private_key)
    finish = time_ns()
    time_decrypt[i] = (finish-start)*10^-9
    ptxt = decrypt(ciph_sin, private_key)
    # encrypt
    start = time_ns()
    encrypt(collect(ptxt), public_key, ptxt.context)
    finish = time_ns()
    time_encrypt[i] = (finish-start)*10^-9
    GC.gc()
end
# plot time
p2 = plot(mult_depth_range, [time_encrypt, time_decrypt], label=["encrypt" "decrypt"],
          xaxis="Multiplicative depth", yaxis="time, s",
          foreground_color_legend = nothing, background_color_legend = nothing,
          ylims=(0.0, maximum(maximum.([time_encrypt, time_decrypt]))))
plot!(size=(400,300))
title!("Time for a single encryption/decryption", titlefontsize=11)

p3 = plot(p1, p2, layout = @layout([B C]), margin=4mm)
plot!(size=(800,300))
savefig(p3, "out/efficiency/encryption-decryption.pdf")
