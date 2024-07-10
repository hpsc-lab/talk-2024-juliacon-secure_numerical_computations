using Plots, Measures, CSV, DataFrames
include("../common_part.jl")
# error
# read data 
table_error = CSV.read("out/advection2d/error.csv", DataFrame)
# plot
p1 = plot(table_error.steps, [table_error.L_inf_cipher_plain_FD table_error.L_inf_cipher_plain_LW],
          label=["1st order FD" "Lax-Wendroff"], xaxis="N_steps", yaxis="L_inf",
          margin=4mm, foreground_color_legend = nothing, background_color_legend = nothing,
          ylims=(0.0, maximum(table_error.L_inf_cipher_plain_LW)))
plot!(size=(400,300))
title!("2D sine wave ciphertext vs plaintext\napproximation, error introduced by OpenFHE,\n128 bit security",
       titlefontsize=10)
savefig(p1, "out/advection2d/ciph_vs_plain_error.pdf")

# time
# read data
table_time = CSV.read("out/advection2d/time.csv", DataFrame)
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
savefig(p3, "out/advection2d/execution_times.pdf")
# visualization
# read data
table_visualization = CSV.read("out/advection2d/visualization.csv", DataFrame)
# plot
# errors
Linf_FD = round(L_inf(table_visualization.sol_exact, table_visualization.sol_ciph_FD); sigdigits=2)
Linf_LW = round(L_inf(table_visualization.sol_exact, table_visualization.sol_ciph_LW); sigdigits=2)
N = Int(table_visualization.length[1])
x = range(0.0, 1.0, N)
y = x

p1 = plot(x, y, reshape(table_visualization.sol_ciph_FD, (N,N)); st=:surface, legendfontsize=8, foreground_color_legend = nothing,
          background_color_legend = nothing, xlims=(0, 1.0), ylims=(0, 1.0),
          zlims=(-1.0, 1.0), colorbar=false)
plot!(size=(400,300))
title!("1st order FD after one period,\nL_inf=$Linf_FD, 128 bit security",
       titlefontsize=11)
xlabel!("x")
ylabel!("y")
zlabel!("u")
p2 = plot(x, y, reshape(table_visualization.sol_ciph_LW, (N,N)); st=:surface, legendfontsize=8, foreground_color_legend = nothing,
          background_color_legend = nothing, xlims=(0, 1.0), ylims=(0, 1.0),
          zlims=(-1.0, 1.0), colorbar=false)
plot!(size=(400,300))
title!("Lax-Wendroff after one period,\nL_inf=$Linf_LW, 128 bit security",
       titlefontsize=11)
xlabel!("x")
ylabel!("y")
zlabel!("u")
p3 = plot(x, y, reshape(table_visualization.sol_exact, (N,N)); st=:surface, legendfontsize=8, foreground_color_legend = nothing,
          background_color_legend = nothing, xlims=(0, 1.0), ylims=(0, 1.0),
          zlims=(-1.0, 1.0), colorbar=false)
plot!(size=(400,300))
title!("2D sin wave exact solution after one period", titlefontsize=11)
xlabel!("x")
ylabel!("y")
zlabel!("u")
p3 = plot(p1, p2, p3, layout = @layout([A B C]))
plot!(size=(1200,300))
savefig(p3, "out/advection2d/visualization.pdf")
