# Generate the initial colelction of solutions for a given problem
using Random
#= 
1. import data
2. parse data into adjacency matrix
3. generate initial population == generate permutations of cities, city = index
=#

function generateInitialPopulation(agentCount :: Integer, dimension :: Integer)
    return [randperm(agentCount) for i in 1:dimension]
end