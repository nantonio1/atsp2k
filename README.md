# ATomic Structure Package — Version 2K

**Charlotte Froese Fischer** and **Georgio Tachiev**
Vanderbilt University

**Gediminas Gaigalas**
Institute for Theoretical Physics, Vilnius

**Michel Godefroid**
Free University of Brussels

**Copyright © 2006**

---

## Overview

This package is similar to the package described in the book:

> *Computational Atomic Structure: An MCHF Approach*
> C. Froese Fischer, Tomas Brage, and Per Jönsson

However, ATSP2K has been modified and extended in several important ways.

## Main Features and Extensions

1. Extended to arbitrarily filled **f-shells**.
2. Modified for a fully orthogonal methodology: **no non-orthogonality**.
3. Modified for more efficient evaluation of matrix elements.
4. Modified for sparse matrix methods using the **Davidson algorithm**.
5. Extended for optimization on multiple terms or eigenvalues.
6. Modified for efficient calculations of iso-electronic sequences.
7. Modified to use biorthogonal transformations for transitions.
8. Modified to include Message Passing Interface (**MPI**) versions of the code.

---

## Contributors to This Version

The modifications published in this version were performed by the following contributors:

| Area                      | Contributor                     |
| ------------------------- | ------------------------------- |
| Sparse methods            | C. Froese Fischer and her group |
| Angular integration       | Gediminas Gaigalas              |
| Radial and MPI codes      | Georgio Tachiev                 |
| Nonorthogonal transitions | Michel Godefroid                |

Contact information from the original release:

* Charlotte Froese Fischer: `Charlotte.F.Fischer@Vanderbilt.edu`
* Gediminas Gaigalas: `gaigalas@itpa.lt`
* Georgio Tachiev: `georgio@arc.fiu.edu`
* Michel Godefroid: `mrgodef@ulb.ac.be`

---

## Earlier Contributors

Other collaborators who contributed to earlier versions include:

* Tomas Brage
* Alan Hibbert
* Andrei Irimia
* Per Jönsson
* Bin Liu
* Gregory Miecznik
* Misha Saparov
* Andreas Stathopoulos
* Lennart Sturesson
* Vernea Meisner Umar
* Nathalie Vaeck
* Claes Goran Wahlstrom

Their contributions are greatly appreciated.

---

## Release Date

September 2006

---

## Acknowledgements

The work of C. Froese Fischer and her group was supported by the Chemical Sciences, Geosciences and Biosciences Division, Office of Basic Energy Sciences, Office of Science, U.S. Department of Energy, beginning in 1978.

---

# Installation

## Requirements

For installation, the package requires several environment variables to be correctly initialized.

A sample setup is provided below for a `.cshrc` file using the Portland Group Fortran compiler. For a more general discussion, consult the CPC publication associated with this release.

## Basic Compilation

From the top-level package directory:

```sh
cd src
make
```

The compiled binaries will be placed in:

```sh
${ATSP}/bin
```

The compiled libraries will be placed in:

```sh
${ATSP}/lib
```

## 64-bit Architectures

If code for 64-bit architectures is needed, copy:

```sh
src/lib/libcom/alloc_LINUX_64.f
```

to:

```sh
src/lib/libcom/alloc_LINUX.f
```

## Compiling `biotr_ang` and `biotr_tr`

To compile `biotr_ang` and `biotr_tr`, which split the `biotr` calculation, use:

```sh
cd src90
make
```

---

# Example Environment Setup

Below is an example `.cshrc` setup using a Portland Group Fortran compiler.

```csh
#########################################################################
# ATSP2K environment setup
#########################################################################

# Set the ATSP home directory and place binaries on the search path
# after executables have been created.

setenv ATSP ${HOME}/atsp_cpc
set path = ( ${ATSP}/bin $path . )

# Set the location of temporary MPI files
setenv MPI_TMP "/tmp/$USER"

# Define Fortran compiler variables
setenv FC "pgf90"                          # Fortran compiler
setenv FC_MPI "mpif90"                     # MPI compiler
setenv FC_FLAGS "-fast -tp p6 -byteswapio" # Serial code compiler flags
setenv FC_MPIFLAGS "-O2 "                  # Parallel code compiler flags
setenv FC_LD                               # Fortran loader flags
setenv FC_MPILD "-Bstatic"                 # Parallel linker flags
setenv FC_MALLOC LINUX                     # Memory allocation routine

# Define C++ compiler variables
setenv CPP "g++"                           # C++ compiler
setenv CPP_FLAGS "-O3"                     # C++ compiler flags
setenv CPP_LD "-static"                    # C++ linker

# Define LAPACK libraries
setenv LAPACK_DIR /usr/pgi/linux86/6.1/lib # Location of LAPACK libraries
setenv LAPACK_LIB "-llapack -lblas"        # Libraries to be searched
```
