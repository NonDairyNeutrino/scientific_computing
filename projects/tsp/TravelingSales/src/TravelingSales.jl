"""
Main module to solve the Traveling Sales problem in both its symmetric and asymmetric forms.
"""
module TravelingSales
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
    FINALK     = 1
    KSTEP      = (FINALK - INITIALK) / MAXSTEPS
    KVECTOR    = ceil.(Int, INITIALK .+ KSTEP .* (1:MAXSTEPS))

    INITIALG   = 0.5 # 0.5 from literature
    FINALG     = 0.1 # 0.1 from literature
    GSTEP      = (FINALG - INITIALG) / MAXSTEPS    # linear decrease from literature
    GVECTOR    = INITIALG .+ GSTEP .* (1:MAXSTEPS) # linear decrease from literature

    # INITIALIZE
    ## initialize population
    tsp            = Problem(parseProblem(DATAFILEPATH))
    DISTANCEMAX    = tsp.dimension - 1 # max distance is the max swaps needed to get from one to another
    fitness        = tourWeight(tsp.matrix)
    tourVector     = generateInitialPopulation(AGENTCOUNT, tsp.dimension)
    solutionVector = Solution.(0, tourVector, ceil.(Int, rand(Uniform(0, DISTANCEMAX), length(tourVector))), 0) # velocity is randomly initialized upon Solution creation
    setMasses!(fitness, solutionVector)

    # CORE
    for step in 1:MAXSTEPS
        step % 50 == 0 ? println("step: ", step) : nothing

        G                        = GVECTOR[step]
        gravityFunction          = gravity(DISTANCEMAX, G)
        accelerationFunction     = acceleration(gravityFunction)
        multiTargetMoveFunction! = multiTargetMove!(accelerationFunction)

        K               = KVECTOR[step]
        KBest           = sort(solutionVector; by = (solution -> solution.mass), rev = true)[1:K]

        Threads.@threads for solution in solutionVector
            # DEPENDENT MOVEMENT OPERATOR
            multiTargetMoveFunction!(solution, KBest)
        # INDEPENDENT MOVEMENT OPERATOR
            localSearch(fitness, solution)
        end 

        # UPDATE MASSES
        setMasses!(fitness, solutionVector)
    end

    bestSolution = argmax(solution -> solution.mass, solutionVector)
    return bestSolution.position, tourWeight(tsp.matrix, bestSolution.position)
end
end # module TravelingSales
