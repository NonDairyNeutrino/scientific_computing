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
include("physics.jl")

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
    setMasses!(fitnessFunction, solutionVector)

    # CORE
    for step in 1:MAXSTEPS
        step % 50 == 0 ? println("step: ", step) : nothing
        # DEPENDENT MOVEMENT OPERATOR
        G               = GVECTOR[step]
        gravityFunction = gravity(DISTANCEMAX, G)
        K               = ceil(Int, INITIALK - ((INITIALK - 1) / MAXSTEPS) * step) # goes from K to 1
        Kbest           = sort(solutionVector; by = (solution -> solution.mass), rev = true)[1:K]
        setAccelerationFunction! = setAcceleration!(Kbest, gravityFunction)

        # calculate dependent movement length (gravitational acceleration) for each agent
        for solution in solutionVector
            setAccelerationFunction!(solution)
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
        setMasses!(fitnessFunction, solutionVector)
    end

    bestSolution = argmax(solution -> solution.mass, solutionVector)
    return bestSolution.position, tourWeight(tsp.matrix, bestSolution.position)
end
end # module TravelingSales
