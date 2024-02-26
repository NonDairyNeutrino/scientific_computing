# Collection of functions used to initialize the problem
# from standard library
using Random # for randperm

"""
    Problem

Gives a structured representation of the Traveling Sales Problem
"""
struct Problem
    matrix    :: Matrix{T} where T <: Real
    dimension :: Int
    function Problem(matrix = rand(10,10) :: Matrix{T} where T <: Real)
        return new(matrix, size(matrix, 1))
    end
end

"""
    Solution

Gives a structured object with mass, position, velocity, and acceleration.
"""
mutable struct Solution
    mass         :: Float64
    position     :: Vector
    velocity     :: Int
    acceleration :: Int
end

"""
    tourWeight(problemMatrix :: Matrix, solution :: Vector) :: Float64

Gives the weight of traveling the given tour.
"""
function tourWeight(edgeWeightMatrix :: Matrix, solution :: Vector) :: Float64
    goBackHomeWeight = edgeWeightMatrix[solution[end], solution[1]]
    tourWeight = 0
    for i in 1 : (length(solution) - 1)
        edgeWeight = edgeWeightMatrix[solution[i], solution[i+1]]
        tourWeight += edgeWeight
    end
    return tourWeight + goBackHomeWeight
end

"""
    tourWeight(problemMatrix :: Matrix) :: Function

Gives a fitness function for a given problem.
"""
function tourWeight(problemMatrix :: Matrix) :: Function
    return solution -> tourWeight(problemMatrix, solution)
end

"""
    generateInitialPopulation(agentCount :: Integer, dimension :: Integer) :: Vector{Vector{Int}}

Generate the initial collection of agents.
"""
function generateInitialPopulation(agentCount :: Int, dimension :: Int) :: Vector{Vector{Int}}
    return randperm.(fill(dimension, agentCount))
end
