# Objective: Generate psuedo-random vectors
# Author: Nathan Chapman
# Date: February 2024
module Generate
export prngVector, generatePoints
using Random, Distributions

# instantiate prngs
const prngVector = [Xoshiro(), MersenneTwister()]

"""
    generatePoints(prng :: Union{Xoshiro, MersenneTwister}, benchmarkSymbol :: Symbol, domain :: Tuple{T, T}, nVectors :: Int, dimension :: Int; samplingDistribution = Uniform) where T <: Real

Generate a list of psuedo-random vectors in the domain of the given benchmark using the given psuedo-random number generator.

# Examples

```jldoctest
julia> generatePoints(Xoshiro(), (-512, 512), 2, 2)
2-element Vector{Vector{Float64}}:
 [-460.50696404887265, -117.3051720494608]
 [-45.235979679764455, -261.973724737398]
```
"""
function generatePoints(prng :: Union{Xoshiro, MersenneTwister}, domain :: Tuple{T, T}, nVectors :: Int, dimension :: Int; samplingDistribution = Uniform) where T <: Real
    domainDistribution = samplingDistribution(domain...)
    prnMatrix          = rand(prng, domainDistribution, nVectors, dimension)
    pointVector        = collect.(eachcol(prnMatrix))
    return pointVector
end
end