using CSV, DataFrames
include("../../examples/advection2d.jl")
include("../common_part.jl")
# setup parameters
N = 64
a = (1.0, 1.0)
N_steps = 150
mult_depth = 25
timespan = (0.0, 1.0)
frequency = 1

#Lax-Wendroff
GC.gc()
GC.gc()
println("Free space: ", Sys.free_memory()/2^20, "MB")
# plaintext simulation
plain_result = []
callback_record_run(u, t, ode, callback, i) = callback_record(u, t, ode, callback, i, plain_result)
callback = StandartCallback(L_inf, nothing, nothing, callback_record_run, frequency)
# disable GC for plaintext simulations
GC.enable(false)
# first run is not representative in sense of time
advection2d("PLAINTEXT", "Lax-Wendroff", N, N_steps, timespan, a, mult_depth, true, callback)
plain_result = []
callback_record_run(u, t, ode, callback, i) = callback_record(u, t, ode, callback, i, plain_result)
callback = StandartCallback(L_inf, nothing, nothing, callback_record_run, frequency)
# second run
timer_plain_conf_vec_LW, _, _ = advection2d("PLAINTEXT", "Lax-Wendroff", N, N_steps, timespan,
                                            a, mult_depth, true, callback)
timer_plain_comp_vec_LW = callback.time_step .- callback.time_step[1]
# ciphertext simulation
# enable GC for ciphertext simulations
GC.enable(true)
callback_compare_run(u, t, ode, callback, i) = callback_compare(u, t, ode, callback, i, plain_result)
callback = StandartCallback(L_inf, nothing, nothing, callback_compare_run, frequency)
timer_ciph_conf_vec_LW, _, sol_ciph_LW = advection2d("CIPHERTEXT", "Lax-Wendroff", N, N_steps,
                                                          timespan, a, mult_depth, true, callback)
timer_ciph_comp_vec_LW = callback.time_step
L_inf_cipher_plain_LW = callback.result_step


#1st order finite differences
GC.gc()
GC.gc()
println("Free space: ", Sys.free_memory()/2^20, "MB")
# plaintext simulation
# disable GC for plaintext simulations
GC.enable(false)
plain_result = []
callback_record_run(u, t, ode, callback, i) = callback_record(u, t, ode, callback, i, plain_result)
callback = StandartCallback(L_inf, nothing, nothing, callback_record_run, frequency)
# first run is not representative in sense of time
advection2d("PLAINTEXT", "1st order FD", N, N_steps, timespan, a, mult_depth, true, callback)
plain_result = []
callback_record_run(u, t, ode, callback, i) = callback_record(u, t, ode, callback, i, plain_result)
callback = StandartCallback(L_inf, nothing, nothing, callback_record_run, frequency)
# second run
timer_plain_conf_vec_FD, _, _ = advection2d("PLAINTEXT", "1st order FD", N, N_steps, timespan,
                                                 a, mult_depth, true, callback)
timer_plain_comp_vec_FD = callback.time_step .- callback.time_step[1]
# ciphertext simulation
# enable GC for ciphertext simulations
GC.enable(true)
callback_compare_run(u, t, ode, callback, i) = callback_compare(u, t, ode, callback, i, plain_result)
callback = StandartCallback(L_inf, nothing, nothing, callback_compare_run, frequency)
timer_ciph_conf_vec_FD, _, sol_ciph_FD = advection2d("CIPHERTEXT", "1st order FD", N, N_steps,
                                                          timespan, a, mult_depth, true, callback)
timer_ciph_comp_vec_FD = callback.time_step
L_inf_cipher_plain_FD = callback.result_step
steps = callback.steps

# get exact solution
sol_exact = advection2d("EXACT", "Lax-Wendroff", N, N_steps, timespan, a, mult_depth, true)


# write out results
# error
table_error = DataFrame(steps = steps,
                        L_inf_cipher_plain_LW = L_inf_cipher_plain_LW,
                        L_inf_cipher_plain_FD = L_inf_cipher_plain_FD)

CSV.write("out/advection2d/error.csv", table_error)
# time
timer_ciph_conf_vec_FD = timer_ciph_conf_vec_FD*ones(length(steps))
timer_ciph_conf_vec_LW = timer_ciph_conf_vec_LW*ones(length(steps))
timer_plain_conf_vec_FD = timer_plain_conf_vec_FD*ones(length(steps))
timer_plain_conf_vec_LW = timer_plain_conf_vec_LW*ones(length(steps))
table_time = DataFrame(steps = steps,
                       timer_ciph_comp_vec_FD = timer_ciph_comp_vec_FD,
                       timer_ciph_conf_vec_FD = timer_ciph_conf_vec_FD,
                       timer_ciph_comp_vec_LW = timer_ciph_comp_vec_LW,
                       timer_ciph_conf_vec_LW = timer_ciph_conf_vec_LW,
                       timer_plain_comp_vec_FD = timer_plain_comp_vec_FD,
                       timer_plain_conf_vec_FD = timer_plain_conf_vec_FD,
                       timer_plain_comp_vec_LW = timer_plain_comp_vec_LW,
                       timer_plain_conf_vec_LW = timer_plain_conf_vec_LW)

CSV.write("out/advection2d/time.csv", table_time)
# visualization
table_visualization = DataFrame(length = N*ones(N*N),
                                sol_ciph_FD = vec(sol_ciph_FD),
                                sol_ciph_LW = vec(sol_ciph_LW),
                                sol_exact = vec(sol_exact))

CSV.write("out/advection2d/visualization.csv", table_visualization)
