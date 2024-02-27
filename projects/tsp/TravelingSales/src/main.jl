#=
this file is the top-level access point of the project
In the TravelingSales package directory, run this file with 
julia -t NUM_THREADS --project src/main.jl
where NUM_THREADS is the number of threads you would like to use
=#
include("TravelingSales.jl")
using .TravelingSales
optimum, cost = main(ARGS)
println("Optimal Tour: ", optimum, " Cost: ", cost)