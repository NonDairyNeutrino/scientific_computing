# Collection of functions used to initialize the problem
# from standard library
using Random # for randperm

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
    # TODO: change to take file path of data file
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
    cost(problemMatrix :: Matrix, solution :: Vector) :: Float64

Gives the cost of traveling the given tour.
"""
function cost(problemMatrix :: Matrix, solution :: Vector) :: Float64
    return sum(problemMatrix[solution[i], solution[i+1]] for i in 1 : (length(solution) - 1)) + problemMatrix[solution[end], solution[1]]
end

"""
    cost(problemMatrix :: Matrix) :: Function

Gives a fitness function for a given problem.
"""
function cost(problemMatrix :: Matrix) :: Function
    return solution -> cost(problemMatrix, solution)
end

"""
    generateInitialPopulation(agentCount :: Integer, dimension :: Integer) :: Vector{Vector{Int}}

Generate the initial collection of agents.
"""
function generateInitialPopulation(agentCount :: Int, dimension :: Int) :: Vector{Vector{Int}}
    return [randperm(dimension) for i in 1:agentCount]
end
