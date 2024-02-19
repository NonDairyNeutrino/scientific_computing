"""
Main module to solve the Traveling Sales problem in both its symmetric and asymmetric forms.
"""
module TravelingSales
include("initialize.jl")
include("gravity.jl")

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
    MAXSTEPS   = 200 # from literature
    AGENTCOUNT = 10  # from literature
    DATAFILEPATH = ""
    INITIALK   = 5   # from literature
    
    INITIALG   = 0.5 # from literature
    FINALG     = 0.1 # from literature
    GSTEP      = (FINALG - INITIALG) / MAXSTEPS    # linear decrease from literature
    GVECTOR    = INITIALG .+ GSTEP .* (1:MAXSTEPS) # linear decrease from literature

    DISTANCEMAX = # TODO: calculate maximum distance in search space

    # INITIALIZE
    tsp            = Problem()
    tourVector     = generateInitialPopulation(agentCount, tsp.dimension)
    solutionVector = Solution.(tourVector)
    bigGVector     = bigG.(maxSteps, 1:maxSteps)

    # LOOP
    for step in 1:maxSteps
        fitnessVector = fitness(tsp.matrix).(tourVector)
        best          = minimum(fitnessVector)
        worst         = maximum(fitnessVector)
        totalMass     = sum(solution.mass for solution in solutionVector)
        for (index, solution) in enumerate(solutionVector)
            solution.mass     = mass(worst, best, fitnessVector[index])
            totalForce        = sum(rand() * gravity(bigGVector[step], solution, otherSolution) for otherSolution in filter(solution -> solution.mass > 0.5 * totalMass, solutionVector))
            acceleration      = totalForce / (solution.mass / totalMass)
            solution.velocity = rand() * solution.velocity + acceleration
            solution.position = solution.position + solution.velocity
        end
    end

    bestSolution = filter(solution -> solution.mass == 1.0, solutionVector)[1]
    return bestSolution.position
end
end # module TravelingSales
