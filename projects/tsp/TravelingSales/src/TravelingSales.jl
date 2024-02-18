"""
Main module to solve the Traveling Sales problem in both its symmetric and asymmetric forms.
"""
module TravelingSales
include("initialize.jl")

"""
    Solution

Gives a structured object with mass, position, velocity, and acceleration.
"""
struct Solution
    mass         :: Real
    position     :: Vector
    velocity     :: Vector
    acceleration :: Vector
    function Solution(position :: Vector)

    end
end

"""
    fitness(problemMatrix :: Matrix, solution :: Vector) :: Real

Gives the cost of traveling the given tour.
"""
function fitness(problemMatrix :: Matrix, solution :: Vector) :: Real
    return sum(problemMatrix[solution[i], solution[i+1]] for i in 1 : (length(solution) - 1)) + problemMatrix[solution[end], solution[1]]
end

"""
    fitness(problemMatrix :: Matrix) :: Function

Gives a fitness function for a given problem.
"""
function fitness(problemMatrix :: Matrix) :: Function
    return solution -> fitness(problemMatrix, solution)
end

function main()
    # INITIALIZE
    # generate initial population (collection of agents)
    # LOOP BODY
    # evaluate fitness for each agent
    # update big g, best, and worst
    # calculate mass and acceleration for each agent
    # update velocity and position
    # LOOP TEST
    # test if converged
    # if converged, return best solution
    # else, loop

    # PARAMETERS
    maxSteps   = 10
    agentCount = 2
    dataFile   = ""

    # INITIALIZE
    tsp = Problem()
    population = generateInitialPopulation(agentCount, tsp.dimension)

    for step in 1:maxSteps
        fitness(tsp.matrix).(population) |> display
    end
end

main() #|> display

end # module TravelingSales
