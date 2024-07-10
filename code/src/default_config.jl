function generate_cryptocontext(ring_dim, levels_available_after_bootstrap, num_slots)
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

    level_budget = [3, 3]

    depth = levels_available_after_bootstrap + GetBootstrapDepth(level_budget, secret_key_distribution)
    SetMultiplicativeDepth(parameters, depth)

    cc = GenCryptoContext(parameters)

    Enable(cc, PKE)
    Enable(cc, KEYSWITCH)
    Enable(cc, LEVELEDSHE)
    Enable(cc, ADVANCEDSHE)
    Enable(cc, FHE)
    EvalBootstrapSetup(cc; level_budget, slots = num_slots)
    cc, depth
end

function generate_secure_cryptocontext(levels_available_after_bootstrap, num_slots)
    parameters = CCParams{CryptoContextCKKSRNS}()

    secret_key_distribution = SPARSE_TERNARY
    SetSecretKeyDist(parameters, secret_key_distribution)

    SetSecurityLevel(parameters, HEStd_128_classic)
    SetBatchSize(parameters, num_slots)

    rescale_technique = FLEXIBLEAUTO
    dcrt_bits = 59;
    first_modulus = 60;

    SetScalingModSize(parameters, dcrt_bits)
    SetScalingTechnique(parameters, rescale_technique)
    SetFirstModSize(parameters, first_modulus)

    level_budget = [4, 4]

    depth = levels_available_after_bootstrap + GetBootstrapDepth(level_budget, secret_key_distribution)
    SetMultiplicativeDepth(parameters, depth)

    cc = GenCryptoContext(parameters)
    println("Ring dimension: ", GetRingDimension(cc))

    Enable(cc, PKE)
    Enable(cc, KEYSWITCH)
    Enable(cc, LEVELEDSHE)
    Enable(cc, ADVANCEDSHE)
    Enable(cc, FHE)
    EvalBootstrapSetup(cc; level_budget, slots = num_slots)
    cc, depth
end