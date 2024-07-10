# Code
In this folder and its subfolders, all code to reproduce the presented results is located.

## Set up Julia
Only required once:
```
julia --project=. -e 'using Pkg; Pkg.instantiate()'
```
## Generate plots
To re-create the results and generate all plots, execute the following line(s):
```bash
OMP_NUM_THREADS=1 julia --project=. ./plots/advection1d/run_examples.jl
OMP_NUM_THREADS=1 julia --project=. ./plots/advection1d/generate_pdf.jl
OMP_NUM_THREADS=1 julia --project=. ./plots/advection1d/convergence_test.jl
OMP_NUM_THREADS=1 julia --project=. ./plots/advection2d/run_examples.jl
OMP_NUM_THREADS=1 julia --project=. ./plots/advection2d/generate_pdf.jl
OMP_NUM_THREADS=1 julia --project=. ./plots/advection2d/convergence_test.jl
OMP_NUM_THREADS=1 julia --project=. ./plots/efficiency/addition.jl
OMP_NUM_THREADS=1 julia --project=. ./plots/efficiency/bootstrapping.jl
OMP_NUM_THREADS=1 julia --project=. ./plots/efficiency/encrypt_decrypt.jl
OMP_NUM_THREADS=1 julia --project=. ./plots/efficiency/memory_bounded.jl
OMP_NUM_THREADS=1 julia --project=. ./plots/efficiency/multiplication.jl
OMP_NUM_THREADS=1 julia --project=. ./plots/efficiency/rotate.jl
```

*Note:* Running all scripts may take more than 5 hours, depending on your system.
All test were conducted on a machine with an AMD Ryzen Threadripper 3990X CPU and with 256 GB RAM.
Since many of the scripts use a lot of memory, Julia can be killed if your machine has not enough main memory available.

A large part of the memory consumption is likely explained by some missing memory release
in the communication between Julia and C++. Resolving this issue is currently work in progress.


## Results
Generated plots can be found in the folder [`out/`](out/).
