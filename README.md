# Secure numerical computations using fully homomorphic encryption

[![License: MIT](https://img.shields.io/badge/License-MIT-success.svg)](https://opensource.org/licenses/MIT)

This is the companion repository for the talk

**Secure numerical computations using fully homomorphic encryption**  
[*Michael Schlottke-Lakemper*](https://www.uni-augsburg.de/fakultaet/mntf/math/prof/hpsc), *Arseniy Kholod*  
JuliaCon 2024, Eindhoven, Netherlands, 10th July 2024

The slides can be found here: [`talk-2024-juliacon-secure_numerical_computations.pdf`](talk-2024-juliacon-secure_numerical_computations.pdf).

## Reproducibility

To reproduce the secure numerical computations shown in the talk, perform the following steps:

### Install Julia
Go to https://julialang.org/downloads and download the latest stable version of Julia (this
repository was created with Julia v1.10.3).

### Get reproducibility repository
Clone this reproducibility repository by executing
```shell
git clone https://github.com/hpsc-lab/talk-2024-juliacon-secure-numerical-computations.git
```

### Start Julia and run code
Go to the cloned repository and start the Julia REPL with
```shell
julia --project=code
```

If you have not done it in a previous session, you need to install all required packages by running
the following code in the REPL (only needed once):
```julia
using Pkg
Pkg.instantiate()
```

To run the examples, include the relevant Julia files from the [`code/`](code) subdirectory in the REPL. More details can be found in the code-specific [README](code/README.md).

## Authors
This repository was initiated by
[Michael Schlottke-Lakemper](https://www.uni-augsburg.de/fakultaet/mntf/math/prof/hpsc) and Arseniy Kholod.

## License
The contents of this repository are licensed under the MIT license (see [LICENSE.md](LICENSE.md)).

