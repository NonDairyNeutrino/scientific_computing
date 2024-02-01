# TODO: add timing
# TODO: add empirical-gradient descent
include("benchmarks.jl")
include("stats.jl")
using Random # standard library
using .Benchmarks, .MyStats, Distributions # not in standard library

matrixToVector(mat :: Matrix) = collect.(eachrow(mat))

function benchmarkTimed(benchmark :: Function, x) :: Vector
    benchmarkTimeValue = @timed benchmark(x)
    return [benchmarkTimeValue.time, benchmarkTimeValue.value]
end

function sampleDomain(prng, domainDistribution, nVectors :: Int, dimension :: Int) :: Tuple{Any, Vector{Vector}}
    return (typeof(prng), rand(prng, domainDistribution, nVectors, dimension) |> matrixToVector)
end

function processBenchmark(benchmarkSymbol :: Symbol, nVectors :: Int, dimension :: Int, prngs...; samplingDistribution = Uniform)
    # get benchmark and its domain
    benchmark = Benchmarks.symbolToFunction[benchmarkSymbol]
    domain    = Benchmarks.benchmarkDomain[benchmarkSymbol]

    # randomly sample the "dimension"-dimensional domain of the given benchmark nVectors times
    domainDistribution = samplingDistribution(domain...)
    points = sampleDomain.(prngs, domainDistribution, nVectors, dimension)

    # pass the random vectors through the benchmark function
    return [benchmarkTimed.(benchmark, randomVector) for randomVector in randomVectorVector]
    # println("Finished $benchmark")
end

function main()
    # instantiate prngs
    rngXoshiro  = Xoshiro()
    rngMersenne = MersenneTwister()
    rngVector   = [Xoshiro, MersenneTwister]

    # generate random vectors with different prngs
    # can go up to nVectors = 3*10^6, dimension = 30 with reasonable runtime
    nVectors  = 2
    dimension = 2

    #= Threads.@threads =# 
    for benchmarkSymbol in names(Benchmarks)[2:end] # names() begins with the name of the package
        println("Starting $(string(benchmarkSymbol)) on thread $(Threads.threadid())")
        processedBenchmarks = processBenchmark(benchmarkSymbol, nVectors, dimension, rngXoshiro, rngMersenne)
        println("Benchmark processing completed.")
        display(processedBenchmarks)
        # Statistics
        println("Starting statistical analysis...")
        stats = doStats.(processedBenchmarks)
        for (rng, stats) in zip(rngVector, stats)
            println(rng, " : ", stats)
        end
        println("=======================================================================")
    end
end

main()