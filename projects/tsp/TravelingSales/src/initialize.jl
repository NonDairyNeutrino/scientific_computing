# Generate the initial collection of solutions for a given problem
using Random

#= 
1. import data
2. parse data into adjacency matrix
3. generate initial population == generate permutations of cities, city = index
=#

"""
    Problem

Gives a structured representation of the Traveling Sales Problem
"""
struct Problem
    # import problem instance
    # parse into weighted adjacency matrix
    matrix    :: Matrix{T} where T <: Real
    dimension :: Int
    function Problem(matrix = rand(10,10) :: Matrix{T} where T <: Real)
        return new(matrix, size(matrix, 1))
    end
end

"""
    generateInitialPopulation(agentCount :: Integer, dimension :: Integer) :: Vector{Vector{Int}}

Generate the initial collection of agents.
"""
function generateInitialPopulation(agentCount :: Int, dimension :: Int) :: Vector{Vector{Int}}
    return [randperm(dimension) for i in 1:agentCount]
end
