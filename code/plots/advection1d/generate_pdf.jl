using Plots, Measures, CSV, DataFrames
# error
# read data 
table_error = CSV.read("out/advection1d/error.csv", DataFrame)
# plot
p1 = plot(table_error.steps, [table_error.L_inf_cipher_plain_FD table_error.L_inf_cipher_plain_LW],
          label=["1st order FD" "Lax-Wendroff"], xaxis="N_steps", yaxis="L_inf",
          margin=4mm, foreground_color_legend = nothing, background_color_legend = nothing,
          ylims=(0.0, maximum(table_error.L_inf_cipher_plain_LW)))
plot!(size=(400,300))
title!("1D sine wave ciphertext vs plaintext\napproximation, error introduced by OpenFHE,\n128 bit security",
       titlefontsize=10)
savefig(p1, "out/advection1d/ciph_vs_plain_error.pdf")

# time
# read data
table_time = CSV.read("out/advection1d/time.csv", DataFrame)
# plot
p1 = plot(table_time.steps,
          [table_time.timer_ciph_comp_vec_FD table_time.timer_ciph_conf_vec_FD table_time.timer_ciph_comp_vec_LW table_time.timer_ciph_conf_vec_LW],
          xaxis="N_steps", yaxis="time, s",
          label=["1st order FD computation" "1st order FD configuration" "Lax-Wendroff computation" "Lax-Wendroff configuration"],
          margin=4mm, foreground_color_legend = nothing, background_color_legend = nothing,
          ylims=(0.0, maximum(table_time.timer_ciph_comp_vec_LW)))
plot!(size=(400,300))
title!("Ciphertext execution times\n128 bit security", titlefontsize=11)

p2 = plot(table_time.steps, 
          [table_time.timer_plain_comp_vec_FD table_time.timer_plain_conf_vec_FD table_time.timer_plain_comp_vec_LW table_time.timer_plain_conf_vec_LW],
          xaxis="N_steps", yaxis="time, s",
          label=["1st order FD computation" "1st order FD configuration" "Lax-Wendroff computation" "Lax-Wendroff configuration"],
          margin=4mm, foreground_color_legend = nothing, background_color_legend = nothing,
          ylims=(0.0, maximum(table_time.timer_plain_comp_vec_LW)))
plot!(size=(400,300))
title!("Plaintext execution times", titlefontsize=11)

p3 = plot(p1, p2, layout = @layout([B C]), margin=4mm)
plot!(size=(800,300))
savefig(p3, "out/advection1d/execution_times.pdf")

# visualization
# read data
table_visualization = CSV.read("out/advection1d/visualization.csv", DataFrame)
# plot
plot(table_visualization.steps, [table_visualization.sol_ciph_FD table_visualization.sol_ciph_LW table_visualization.sol_exact], 
    label=["1st order FD ciphertext approximation" "Lax-Wendroff ciphertext approximation" "exact solution"],
    linestyle = [:solid :solid :dash] ,
    legendfontsize=7, foreground_color_legend = nothing, background_color_legend = nothing, margin=4mm)
plot!(size=(400,300))
title!("1D sine wave solution after one period,\n128 bit security", titlefontsize=10)
xlabel!("x")
ylabel!("u")
savefig("out/advection1d/visualization.pdf")
