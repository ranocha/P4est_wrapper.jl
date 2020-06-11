using Libdl

P4EST_ARTIFACT = false
if VERSION < v"1.3"
    DEFAULT_P4EST_ROOT_DIR = "/usr"
else
    using P4est_jll
    P4EST_ARTIFACT = true
    DEFAULT_P4EST_ROOT_DIR = P4est_jll.artifact_dir
end

P4EST_FOUND        = true
P4EST_ROOT_DIR     = haskey(ENV,"P4EST_ROOT_DIR") ? ENV["P4EST_ROOT_DIR"] : DEFAULT_P4EST_ROOT_DIR
P4EST_DIR          = haskey(ENV,"P4EST_DIR") ? ENV["P4EST_DIR"] : P4EST_ROOT_DIR
P4EST_LIB_DIR      = haskey(ENV,"P4EST_LIB_DIR") ? ENV["P4EST_LIB_DIR"] : joinpath(P4EST_DIR,"lib")
P4EST_INCLUDE_DIR  = haskey(ENV,"P4EST_INCLUDE_DIR") ? ENV["P4EST_INCLUDE_DIR"] : joinpath(P4EST_DIR,"include")
P4EST_LIB_NAME     = haskey(ENV,"P4EST_LIB_NAME") ? ENV["P4EST_LIB_NAME"] : "libp4est"
P4EST_LIB          = haskey(ENV,"P4EST_LIB") ? ENV["P4EST_LIB"] : ""

DEFAULT_P4EST_ENABLE_MPI = P4EST_ARTIFACT ? false : true
P4EST_ENABLE_MPI   = haskey(ENV,"P4EST_ENABLE_MPI") ? Bool(ENV["P4EST_ENABLE_MPI"]) : DEFAULT_P4EST_ENABLE_MPI


# Check P4EST_DIR exists
if isdir(P4EST_DIR)
    @info "p4est directory found at: $P4EST_DIR"

    # Check P4EST_LIB_DIR (.../lib directory) exists
    if isdir(P4EST_LIB_DIR)
        @info "p4est lib directory found at: $P4EST_LIB_DIR"
    else
        @warn "P4EST lib directory not found: $P4EST_LIB_DIR"
    end

    if (cmp(P4EST_LIB,"") == 0)
    # Check P4EST_LIB (.../libp4est.so file) exists
        P4EST_LIB = string(Libdl.find_library(P4EST_LIB_NAME,[P4EST_LIB_DIR,P4EST_ROOT_DIR]),".",Libdl.dlext)
    end

    if isfile(P4EST_LIB)
        @info "P4EST library found at: $P4EST_LIB"
    else
        P4EST_FOUND = false
        @warn "P4EST lib ($P4EST_LIB) not found at: $P4EST_LIB_DIR"
    end

    # Check P4EST_INCLUDE_DIR (.../include directory) exists
    if isdir(P4EST_INCLUDE_DIR)
        @info "P4EST include directory found at: $P4EST_INCLUDE_DIR"
    else
        @warn "P4EST include directory not found: $P4EST_INCLUDE_DIR"
    end

else
    if (cmp(P4EST_LIB,"") == 0)
        # Check P4EST_LIB (.../libp4est.so file) exists
        P4EST_LIB = string(Libdl.find_library(P4EST_LIB_NAME,[P4EST_LIB_DIR,P4EST_ROOT_DIR]),".",Libdl.dlext)
    end

    if isfile(P4EST_LIB)
        @info "P4EST library found at: $P4EST_LIB"
    else
        P4EST_FOUND = false
        @warn "P4EST lib ($P4EST_LIB) not found at: $P4EST_ROOT_DIR"
    end
end

@info """
P4EST configuration:
==============================================
  - P4EST_FOUND           = $P4EST_FOUND
  - P4EST_DIR             = $P4EST_DIR
  - P4EST_LIB_DIR         = $P4EST_LIB_DIR
  - P4EST_INCLUDE_DIR     = $P4EST_INCLUDE_DIR
  - P4EST_LIB             = $P4EST_LIB
  - P4EST_ENABLE_MPI      = $P4EST_ENABLE_MPI
"""

if !P4EST_FOUND
    error("P4EST library not found")
end

# Write P4EST configuration to deps.jl file
deps_jl = "deps.jl"

if isfile(deps_jl)
  rm(deps_jl)
end

open(deps_jl,"w") do f
  println(f, "# This file is automatically generated")
  println(f, "# Do not edit")
  println(f)
  println(f, :(const P4EST_FOUND           = $P4EST_FOUND))
  println(f, :(const P4EST_DIR             = $P4EST_DIR))
  println(f, :(const P4EST_LIB_DIR         = $P4EST_LIB_DIR))
  println(f, :(const P4EST_INCLUDE_DIR     = $P4EST_INCLUDE_DIR))
  println(f, :(const P4EST_LIB             = $P4EST_LIB))
  println(f, :(const P4EST_ENABLE_MPI      = $P4EST_ENABLE_MPI))
end
