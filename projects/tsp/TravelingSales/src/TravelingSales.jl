"""
Main module to solve the Traveling Sales problem in both its symmetric and asymmetric forms.
"""
module TravelingSales
export main
include("initialize.jl")
include("neighborhood.jl")
include("localsearch.jl")

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
    MAXSTEPS   = 200 # 200 from literature
    AGENTCOUNT = 10  # 10 from literature
    DATAFILEPATH = ""
    INITIALK   = 5   # 5 from literature
    
    INITIALG   = 0.5 # 0.5 from literature
    FINALG     = 0.1 # 0.1 from literature
    GSTEP      = (FINALG - INITIALG) / MAXSTEPS    # linear decrease from literature
    GVECTOR    = INITIALG .+ GSTEP .* (1:MAXSTEPS) # linear decrease from literature

    # DISTANCEMAX = # TODO: calculate maximum distance in search space

    # INITIALIZE
    ## initialize population
    tsp            = Problem(#= DATAFILEPATH =#)
    costFunction   = cost(tsp.matrix) # returns a function
    tourVector     = generateInitialPopulation(AGENTCOUNT, tsp.dimension)
    solutionVector = Solution.(tourVector) # velocity is randomly initialized upon Solution creation
    ## initialize masses
    costVector     = costFunction.(getproperty.(solutionVector, :position))
    best           = minimum(costVector)
    worst          = maximum(costVector)
    tempMassVector = (costVector .- worst) / (best - worst)
    totalMass      = sum(tempMassVector)
    setproperty!.(solutionVector, :mass, tempMassVector / totalMass) # intialize solution mass

    # CORE
    for step in 1:MAXSTEPS
        # # DEPENDENT MOVEMENT OPERATOR
        # G = GVECTOR[step]
        # K = # TODO: update K
        # Kbest = sort(solutionVector; by = (solution -> solution.mass), rev = true)[1:K]
        # for (index, solution) in enumerate(solutionVector)
        #     totalForce = 0
        #     for otherSolution in Kbest
        #         # GRAVITY
        #         distance = # TODO: calculate transposition distance between permutations 
        #         # above is the TSP specific result of using transposition as the small-move operator
        #         # as defined in literature
        #         distanceNormalized = 0.5 + distance / (2 * DISTANCEMAX)
        #         totalForce += rand() * GVECTOR[index] * solution.mass * otherSolution.mass * distance / distanceNormalized
        #     end
        #     acceleration = totalForce / solution.mass |> ceil
        #     solution.position += acceleration
        # end

        # INDEPENDENT MOVEMENT OPERATOR
        localSearch.(costFunction, solutionVector)
    end

    bestSolution = argmax(solution -> solution.mass, solutionVector)
    return bestSolution.position
end
end # module TravelingSales
