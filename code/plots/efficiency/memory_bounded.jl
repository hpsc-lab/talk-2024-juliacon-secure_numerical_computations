# in this file investigation of memory boundness of OpenFHE operations is done 
using SecureArithmetic, Plots, CpuId, OpenFHE

GC.gc()
GC.gc()
println("Free space: ", Sys.free_memory()/2^20, "MB")

# init setup
function init_setup(ring_dim, mult_depth, num_slots)

    parameters = CCParams{CryptoContextCKKSRNS}()

    secret_key_distribution = UNIFORM_TERNARY
    SetSecretKeyDist(parameters, secret_key_distribution)

    SetSecurityLevel(parameters, HEStd_NotSet)
    SetRingDim(parameters, ring_dim)
    SetBatchSize(parameters, num_slots)

    rescale_technique = FLEXIBLEAUTO
    dcrt_bits = 59;
    first_modulus = 60;

    SetScalingModSize(parameters, dcrt_bits)
    SetScalingTechnique(parameters, rescale_technique)
    SetFirstModSize(parameters, first_modulus)
    SetMultiplicativeDepth(parameters, mult_depth)

    cc = GenCryptoContext(parameters)

    Enable(cc, PKE)
    Enable(cc, KEYSWITCH)
    Enable(cc, LEVELEDSHE)

    context = SecureContext(OpenFHEBackend(cc))
    public_key, private_key = generate_keys(context)
    init_multiplication!(context, private_key)
    return private_key, public_key, context
end

ring_dims_range = Int.(2 .^range(10, 20, 11))
mult_depth = 31
performance = zeros(length(ring_dims_range))
for i in range(1, length(ring_dims_range))
    ring_dim = ring_dims_range[i]
    N = Int(ring_dim/2)
    private_key, public_key, context = init_setup(ring_dim, mult_depth, N)
    v = zeros(N)
    v[1:end] .= 1 + pi/30
    ptxt = PlainVector(v, context)
    ciph = encrypt(ptxt, public_key)
    start = time_ns()
    for _ in range(1, 5)
        ciph*(1+pi/30)
    end
    stop = time_ns()
    performance[i] = 2 * 5 * ring_dim / ((stop - start) * 10^-9)
end
# plot error
p1 = plot(ring_dims_range, performance, label="data",
          foreground_color_legend = nothing, background_color_legend = nothing, xaxis=:log2,
          xticks=[1<<10, 1<<12, 1<<14, 1<<16, 1<<18, 1<<20],
          ylims=(0.0, maximum(performance)))
xlabel!("Ring dimension")
ylabel!("Performance, flops")
plot!(size=(400,300))
title!("Ciphertext - scalar multiplication", titlefontsize=12)
cache = cachesize()
# draw cache sizes
vline!([cache[3]/((mult_depth+1)*16)], label="Last level cache size")
savefig(p1, "out/efficiency/memory_bounded.pdf")
