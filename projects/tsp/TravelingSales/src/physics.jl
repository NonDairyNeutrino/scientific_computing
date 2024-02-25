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

"""
    acceleration(gravityFunction :: Function, solution :: Solution, otherSolution :: Solution) :: Int

Gives the gravitational acceleration (i.e. dependent movement length) of one solution towards another.
"""
function acceleration(gravityFunction :: Function, solution :: Solution, otherSolution :: Solution) :: Int
    force = gravityFunction(solution, otherSolution)
    mass  = solution.mass != 0 ? solution.mass : 0.001 # 0.001 is arbitrary
    try
        return ceil(Int, force / mass) # sometimes throws runtime error but don't know why
    catch e
        @error "Something went wrong, aborting. Solutions:
        solution: $solution
        otherSolution: $otherSolution"
        display(e)
        exit()
    end
end

"""
    acceleration(gravityFunction :: Function) :: Function

Gives a function to calculate the gravitational acceleration of one solution towards another.
"""
function acceleration(gravityFunction :: Function) :: Function
    return (solution, otherSolution) -> acceleration(gravityFunction, solution, otherSolution)
end