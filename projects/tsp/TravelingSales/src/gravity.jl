# Collection of functions containing functionality of the Gravitational Search Algorithm.
"""
    mass(worst :: Real, best :: Real, fitness :: Real) :: Real

Gives the analogous mass of a solution with a given fitness.
"""
function mass(worst :: Real, best :: Real, fitness :: Real) :: Real
    return (fitness - worst) / (best - worst)
end

"""
    bigG(maxSteps :: Integer, step :: Integer; initialG = 100, alpha = 20) :: Real

Gives the analog of Newton's Universal Gravitational Constant.
"""
function bigG(maxSteps :: Integer, step :: Integer; initialG = 100, alpha = 20) :: Real
    return initialG * exp(-alpha * step / maxSteps)
end

"""
    distance(sol1 :: Vector, sol2 :: Vector) :: Real

Gives the distance between solutions.
"""
function distance(sol1 :: Vector, sol2 :: Vector) :: Real
    # ?????????????????? Euclidean ???????????????????
end

"""
    gravity(bigG :: Real, mass1 :: Real, mass2 :: Real, distance :: Real, position1 :: Vector, position2 :: Vector; epsilon = 0.1, power = 1) :: Real

Gives the attractive force between two solutions.
"""
function gravity(bigG :: Real, mass1 :: Real, mass2 :: Real, distance :: Real, position1 :: Vector, position2 :: Vector; epsilon = 0.1, power = 1) :: Real
    return bigG * mass1 * mass2 * (position2 - position1) / (distance^power + epsilon)
end