"""
Main module to solve the Traveling Sales problem in both its symmetric and asymmetric forms.
"""
module TravelingSales
# not from standard library
using Distributions # for velocity

export main

include("parsetsp.jl")
include("initialize.jl")
include("searchspace.jl")

"""
    main(args :: Vector) :: Tuple{Vector{Int}, Int}

Tries to give an optimal solution to the Traveling Sales Problem
"""
function main(args :: Vector) :: Tuple{Vector{Int}, Float64}
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
    if isempty(args)
    DATAFILEPATH = "data/bays29.tsp"
        MAXSTEPS     = 200 # 200 from literature
        AGENTCOUNT   = 10  # 10 from literature
    else
        DATAFILEPATH         = args[1]
        MAXSTEPS, AGENTCOUNT = parse.(Int, args[2:3])
    end
    INITIALK   = ceil(Int, 0.5 * AGENTCOUNT) # 5 from literature
    
    INITIALG   = 0.5 # 0.5 from literature
    FINALG     = 0.1 # 0.1 from literature
    GSTEP      = (FINALG - INITIALG) / MAXSTEPS    # linear decrease from literature
    GVECTOR    = INITIALG .+ GSTEP .* (1:MAXSTEPS) # linear decrease from literature

    # INITIALIZE
    ## initialize population
    tsp            = Problem(parseProblem(DATAFILEPATH))
    DISTANCEMAX    = tsp.dimension - 1 # max distance is the max swaps needed to get from one to another
    fitnessFunction= tourWeight(tsp.matrix)
    tourVector     = generateInitialPopulation(AGENTCOUNT, tsp.dimension)
    solutionVector = Solution.(0, tourVector, ceil.(Int, rand(Uniform(0, DISTANCEMAX), length(tourVector))), 0) # velocity is randomly initialized upon Solution creation
    ## initialize masses
    fitnessVector  = fitnessFunction.(getproperty.(solutionVector, :position))
    best           = minimum(fitnessVector) # because we want to minimize the fitness/tourWeight
    worst          = maximum(fitnessVector)
    tempMassVector = (fitnessVector .- worst) / (best - worst)
    totalMass      = sum(tempMassVector)
    setproperty!.(solutionVector, :mass, tempMassVector / totalMass) # intialize solution mass

    # CORE
    for step in 1:MAXSTEPS
        # DEPENDENT MOVEMENT OPERATOR
        G = GVECTOR[step]
        K = ceil(Int, INITIALK - (INITIALK / MAXSTEPS) * step)
        Kbest = sort(solutionVector; by = (solution -> solution.mass), rev = true)[1:K]
        # calculate dependent movement length (gravitational acceleration) for each agent
        for solution in solutionVector
            totalForce = 0
            for otherSolution in Kbest
                # GRAVITY
                dist = distance(solution.position, otherSolution.position)
                # above is the TSP specific result of using transposition 
                # as the small-move operator as defined in literature
                    distanceNormalized = 0.5 + dist / (2 * DISTANCEMAX) # 0.5 for small offset
                totalForce += rand() * G * solution.mass * otherSolution.mass * dist / distanceNormalized
            end
                try
                    solution.acceleration = ceil(Int, totalForce / solution.mass) # sometimes throws runtime error but don't know why
                catch e
                    display(e)
                    @error "Something went wrong.  Variables: mass = $(solution.mass), zero distance: $(distance == 0), totalForce: $totalForce"
                end
        end
        ## MTMNS
        for solution in solutionVector
            # newSolution = deepcopy(solution)
            for otherSolution in Kbest
                ### SMNS
                for i in 1:otherSolution.acceleration # what if acceleration > distance?
                    # small move newSolution towards otherSolution
                    index = findall(z -> z == solution.position[i], otherSolution.position)[1]
                    swap!(solution.position, i, index)
                end
            end
        end 

        # INDEPENDENT MOVEMENT OPERATOR
        localSearch.(fitnessFunction, solutionVector)

        # UPDATE MASSES
        fitnessVector  = fitnessFunction.(getproperty.(solutionVector, :position))
        best           = minimum(fitnessVector)
        worst          = maximum(fitnessVector)
        tempMassVector = (fitnessVector .- worst) / (best - worst)
        totalMass      = sum(tempMassVector)
        setproperty!.(solutionVector, :mass, tempMassVector / totalMass)
    end

    bestSolution = argmax(solution -> solution.mass, solutionVector)
    return bestSolution.position, tourWeight(tsp.matrix, bestSolution.position)
end
end # module TravelingSales
