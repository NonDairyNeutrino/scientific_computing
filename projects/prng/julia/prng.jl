# TODO: add timing
# TODO: add empirical-gradient descent
include("benchmarks.jl")
include("stats.jl")
using Random # standard library
using .Benchmarks, .MyStats, Distributions # not in standard library

matrixToVector(mat :: Matrix) = collect.(eachrow(mat))

function processBenchmark(benchmarkSymbol :: Symbol, nVectors :: Int, dimension :: Int, prngs...)
    # get benchmark and its domain
    benchmark = Benchmarks.symbolToFunction[benchmarkSymbol]
    domain    = Benchmarks.benchmarkDomain[benchmarkSymbol]
    # generate random vectors within respective domains
    randomVectorVector = matrixToVector.(rand.(prngs, Uniform(domain...), nVectors, dimension))
    # pass the random vectors through the benchmark function
    return [benchmark.(randomVector) for randomVector in randomVectorVector]
    # println("Finished $benchmark")
end

function main()
    # instantiate prngs
    rngXoshiro  = Xoshiro()
    rngMersenne = MersenneTwister()
    rngVector   = [Xoshiro, MersenneTwister]

    # generate random vectors with different prngs
    # can go up to nVectors = 3*10^6, dimension = 30 with reasonable runtime
    nVectors  = 30
    dimension = 30

    #= Threads.@threads =# 
    for benchmarkSymbol in names(Benchmarks)[2:end] # names() begins with the name of the package
        println("Starting $(string(benchmarkSymbol)) on thread $(Threads.threadid())")
        processedBenchmarks = processBenchmark(benchmarkSymbol, nVectors, dimension, rngXoshiro, rngMersenne)
        # println("Benchmark processing completed.")
        # # Statistics
        # println("Starting statistical analysis...")
        stats = doStats.(processedBenchmarks)
        for (rng, stats) in zip(rngVector, stats)
            println(rng, " : ", stats)
        end
        println("=======================================================================")
    end
end

main()