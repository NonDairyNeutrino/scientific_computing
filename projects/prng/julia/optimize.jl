include("benchmarks.jl")
include("generate.jl")
include("gradient.jl")
using .Benchmarks, .Generate, .EmpiricalGradient
#= General Idea
1. Choose a benchmark and a prng (e.g. Xoshiro or MersenneTwister)
2. Generate psuedo-random vectors (prv) in the domain of the benchmark
3. Minimize the benchmark starting at each of the prvs
=#
function getParameters() :: Tuple{Int, Int, Float64}
    print("Number of experiments: ")
    nVectors  = parse(Int, readline())
    print("Number of dimensions: ")
    dimension = parse(Int, readline())
    print("Step size: ")
    step      = parse(Float64, readline())
    return nVectors, dimension, step
end

function sampleDomain(prng, benchmarkSymbol :: Symbol, nExperiments :: Int, dimension) :: Vector
    domain      = Benchmarks.benchmarkDomain[benchmarkSymbol]
    pointVector = generatePoints(prng, domain, nExperiments, dimension)
    return pointVector
end

function main()
    nExperiments, dimension, step = getParameters()
    # names() begins with the name of the package
    benchmarkSymbolVector = names(Benchmarks)[2:end]

    Threads.@threads for benchmarkSymbol in benchmarkSymbolVector
        benchmark = Benchmarks.symbolToFunction[benchmarkSymbol]
        Threads.@threads for prng in prngVector
            pointBest = argmin(benchmark, sampleDomain(prng, benchmarkSymbol, nExperiments, dimension))
            println("Starting descent for $benchmark with $(typeof(prng)) on thread $(Threads.threadid())")
            optimizer, optimum = gradientDescent(step, benchmark, pointBest)
            println("Found $benchmark - $(typeof(prng)) optimum $optimum at $optimizer")
            println("=============================================================================================================")
        end
    end
end

main()