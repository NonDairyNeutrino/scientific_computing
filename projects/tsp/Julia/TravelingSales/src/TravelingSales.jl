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
    
    if length(args) == 1
        DATAFILEPATH = args[1]
        MAXSTEPS     = 200 # 200 from literature
        AGENTCOUNT   = 10  # 10 from literature
    elseif length(args) == 3
        adjacencyMatrix = nothing
        try 
            @assert isfile(args[1])
            DATAFILEPATH    = args[1]
            adjacencyMatrix = parseProblem(DATAFILEPATH)
        catch
            adjacencyMatrix = args[1]
        end
        MAXSTEPS, AGENTCOUNT = (PROGRAM_FILE == @__FILE__) ? parse.(Int, args[2:3]) : args[2:3]
    end

    INITIALK   = ceil(Int, 0.5 * AGENTCOUNT) # 5 from literature
    FINALK     = 1
    KSTEP      = (FINALK - INITIALK) / MAXSTEPS
    KVECTOR    = ceil.(Int, INITIALK .+ KSTEP .* (1:MAXSTEPS))

    INITIALG   = 0.5 # 0.5 from literature
    FINALG     = 0.1 # 0.1 from literature
    GSTEP      = (FINALG - INITIALG) / MAXSTEPS    # linear decrease from literature
    GVECTOR    = INITIALG .+ GSTEP * (1:MAXSTEPS) # linear decrease from literature

    # INITIALIZE
    ## initialize population
    
    tsp            = Problem(adjacencyMatrix)
    DISTANCEMAX    = tsp.dimension - 1 # max distance is the max swaps needed to get from one to another
    fitness        = tourWeight(tsp.matrix)
    localSearchFunction! = localSearch!(fitness)
    tourVector     = generateInitialPopulation(AGENTCOUNT, tsp.dimension)
    solutionVector = Solution.(0, tourVector, ceil.(Int, rand(Uniform(0, DISTANCEMAX), length(tourVector))), 0) # velocity is randomly initialized upon Solution creation
    setMasses!(fitness, solutionVector)

    updateInterval = 50
    # CORE
    for step in 1:MAXSTEPS
        # step % updateInterval == 0 ? println("step: ", step) : nothing
        # step % updateInterval == 0 ? println("best fitness: ", fitness(argmax(solution -> solution.mass, solutionVector).position)) : nothing

        G                        = GVECTOR[step]
        gravityFunction          = gravity(DISTANCEMAX, G)
        accelerationFunction     = acceleration(gravityFunction)
        multiTargetMoveFunction! = multiTargetMove!(accelerationFunction)

        K     = KVECTOR[step]
        KBest = sort(solutionVector; by = (solution -> solution.mass), rev = true)[1:K]

        for solution in solutionVector
            # DEPENDENT MOVEMENT OPERATOR
            multiTargetMoveFunction!(solution, KBest)
        end 

        Threads.@threads for solution in solutionVector
            # INDEPENDENT MOVEMENT OPERATOR
            localSearchFunction!(solution)
        end

        # UPDATE MASSES
        setMasses!(fitness, solutionVector)
    end

    bestSolution = argmax(solution -> solution.mass, solutionVector)
    return bestSolution.position, fitness(bestSolution.position)
end

"""
    julia_main() :: Cint

Provides support for pre-compilation when compiled with PackageCompiler.
"""
function julia_main() :: Cint
    optimum, cost = main(ARGS)
    println("Optimal Tour: ", optimum, " Cost: ", cost)
    return 0
end
end # module TravelingSales
