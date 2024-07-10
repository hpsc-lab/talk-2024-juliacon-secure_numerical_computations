using Plots, CSV, DataFrames
include("../../examples/advection1d.jl")
include("../common_part.jl")
# setup parameters
a = 1.0
mult_depth = 25
timespan = (0, 0.25)
# configure callback
L_2_squared(v1, v2) = sum((v1-v2).^2)
frequency = 1

#run simualtions for constant cfl number
N_range = [8, 16, 32, 64]
CFL = 0.4
#Lax-Wendroff
L2_mean_LW_cfl = []
for N in N_range
    local N_steps = Int(round(timespan[2]*N*a/CFL))
    # ciphertext simulation
    println("Free space: ", Sys.free_memory()/2^20, "MB")
    local callback = StandartCallback(L_2_squared, nothing, nothing, callback_run, frequency)
    local _, _, sol_ciph = advection1d("CIPHERTEXT", "Lax-Wendroff", N, N_steps, timespan, a, mult_depth, true, callback)
    #compute and save errors
    push!(L2_mean_LW_cfl, sqrt(sum(callback.result_step))/sqrt(callback.sample_size))
    GC.gc()
end
L2_mean_LW_cfl = round.(L2_mean_LW_cfl, digits=4)
# experimental order of convergence
EOC_LW_cfl = []
for i in range(2, length(L2_mean_LW_cfl))
    push!(EOC_LW_cfl, log2(L2_mean_LW_cfl[i-1]/L2_mean_LW_cfl[i]))
end
EOC_LW_cfl = round.(EOC_LW_cfl, digits=3)
#1st order finite differences
L2_mean_FD_cfl = []
for N in N_range
    local N_steps = Int(round(timespan[2]*N*a/CFL))
    # ciphertext simulation
    GC.gc()
    GC.gc()
    println("Free space: ", Sys.free_memory()/2^20, "MB")
    local callback = StandartCallback(L_2_squared, nothing, nothing, callback_run, frequency)
    local _, _, sol_ciph = advection1d("CIPHERTEXT", "1st order FD", N, N_steps, timespan, a, mult_depth, true, callback)
    #compute and save errors
    push!(L2_mean_FD_cfl, sqrt(sum(callback.result_step))/sqrt(callback.sample_size))
end
L2_mean_FD_cfl = round.(L2_mean_FD_cfl, digits=4)
# experimental order of convergence
EOC_FD_cfl = []
for i in range(2, length(L2_mean_FD_cfl))
    push!(EOC_FD_cfl, log2(L2_mean_FD_cfl[i-1]/L2_mean_FD_cfl[i]))
end
EOC_FD_cfl = round.(EOC_FD_cfl, digits=3)
push!(EOC_LW_cfl, round(sum(EOC_LW_cfl)/(length(N_range)-1), digits=3))
table_LW = DataFrame(N = vcat(N_range, "mean"),
                    Error = vcat(L2_mean_LW_cfl, "-"),
                    EOC = vcat("-", EOC_LW_cfl))

rename!(table_LW,["\$N_x\$","\$L2_{mean}\$", "\$EOC\$"])
CSV.write("out/advection1d/LW_convergence.csv", table_LW)
push!(EOC_FD_cfl, round(sum(EOC_FD_cfl)/(length(N_range)-1), digits=3))
table_FD = DataFrame(N = vcat(N_range, "mean"),
                     Error = vcat(L2_mean_FD_cfl, "-"),
                     EOC = vcat("-", EOC_FD_cfl))

rename!(table_FD,["\$N_x\$","\$L2_{mean}\$", "\$EOC\$"])
CSV.write("out/advection1d/FD_convergence.csv", table_FD)
