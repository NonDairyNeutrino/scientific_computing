include("TravelingSales.jl")
using .TravelingSales
optimum, cost = main(ARGS)
println("Optimal Tour: ", optimum, " Cost: ", cost)