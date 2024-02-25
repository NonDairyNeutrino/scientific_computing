include("TravelingSales.jl")
using .TravelingSales
optimum, cost = main()
println("Optimal Tour: ", optimum, " Cost: ", cost)