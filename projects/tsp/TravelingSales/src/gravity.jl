# Collection of functions containing functionality of the Gravitational Search Algorithm.
"""
    mass(worst :: Float64, best :: Float64, fitness :: Float64) :: Float64

Gives the analogous mass of a solution with a given fitness.
"""
function mass(worst :: Float64, best :: Float64, fitness :: Float64) :: Float64
    return (fitness - worst) / (best - worst)
end

"""
    bigG(maxSteps :: Integer, step :: Integer; initialG = 100, alpha = 20) :: Float64

Gives the analog of Newton's Universal Gravitational Constant.
"""
function bigG(maxSteps :: Integer, step :: Integer; initialG = 100, alpha = 20) :: Float64
    return initialG * exp(-alpha * step / maxSteps)
end

"""
    distance(sol1 :: Vector, sol2 :: Vector) :: Float64

Gives the distance between solutions.
"""
function distance(sol1 :: Solution, sol2 :: Solution) :: Float64
    # ?????????????????? Euclidean ???????????????????
    return abs(sol1.mass - sol2.mass)
end

"""
    gravity(bigG :: Float64, sol1 :: Solution, sol2 :: Solution; epsilon = 0.1, power = 1) :: Float64

Gives the attractive force between two solutions.
"""
function gravity(bigG :: Float64, sol1 :: Solution, sol2 :: Solution; epsilon = 0.1, power = 1) :: Vector{Float64}
    d = distance(sol1, sol2)
    return bigG * sol1.mass * sol2.mass * (sol2.position - sol1.position) / (d^power + epsilon)
end