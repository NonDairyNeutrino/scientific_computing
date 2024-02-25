# functionality to implement the physics analog

"""
    setMasses!(fitnessFunction :: Function, solutionVector :: Vector) :: Nothing

Calculates and updates the mass for every given solution.
"""
function setMasses!(fitnessFunction :: Function, solutionVector :: Vector) :: Nothing
    fitnessVector  = fitnessFunction.(getproperty.(solutionVector, :position))
    best           = minimum(fitnessVector) # because we want to minimize the fitness/tourWeight
    worst          = maximum(fitnessVector)
    massVector     = (fitnessVector .- worst) / (best - worst)
    totalMass      = sum(massVector)
    setproperty!.(solutionVector, :mass, massVector / totalMass) # intialize solution mass
    return
end

"""
    gravity(maxDistance :: Int, G, solution :: Solution, otherSolution :: Solution) :: Float64

Calculates the gravitional force between two solutions.
"""
function gravity(maxDistance :: Int, G, solution :: Solution, otherSolution :: Solution) :: Float64
    dist = distance(solution.position, otherSolution.position)
    distanceNormalized = 0.5 + dist / (2 * maxDistance) # 0.5 for small offset
    return rand() * G * solution.mass * otherSolution.mass * dist / distanceNormalized
end

"""
    gravity(maxDistance :: Int, G) :: Function

Gives a function for the gravitational force for given parameters.
"""
function gravity(maxDistance :: Int, G) :: Function
    (solution, otherSolution) -> gravity(maxDistance, G, solution, otherSolution)
end

function totalGravity(KbestVector :: Vector{Solution}, gravityFunction :: Function, solution :: Solution)
    totalForce = sum(gravityFunction(solution, KbestSolution) for KbestSolution in KbestVector)
    try
        solution.acceleration = solution.mass != 0 ? ceil(Int, totalForce / solution.mass) : 0 # sometimes throws runtime error but don't know why
    catch e
        @error "Something went wrong, aborting.  Solution on crash: $solution"
        display(e)
        exit(1)
    end
end

"""
    totalGravity(KbestVector :: Vector, gravityFunction :: Function) :: Function

TBW
"""
function totalGravity(KbestVector :: Vector, gravityFunction :: Function) :: Function
    return solution -> totalGravity(KbestVector, gravityFunction, solution)
end