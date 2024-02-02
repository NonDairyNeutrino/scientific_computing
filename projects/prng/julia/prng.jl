# TODO: add empirical-gradient descent
include("benchmarks.jl")
include("stats.jl")
using Random # standard library
using .Benchmarks, .MyStats, Distributions # not in standard library

matrixToVector(mat :: Matrix) = collect.(eachrow(mat))

function benchmarkTimed(benchmark :: Function, x :: Vector) :: Vector
    benchmarkTimeValue = @timed benchmark(x)
    return [benchmarkTimeValue.time, benchmarkTimeValue.value]
end

function benchmarkTimed(benchmark :: Function, x :: Vector{Vector}) :: Vector
    benchmarkTimed.(benchmark, x)
end

function sampleDomain(prng, domainDistribution, nVectors :: Int, dimension :: Int) :: Vector{Vector}
    return rand(prng, domainDistribution, nVectors, dimension) |> matrixToVector
end

function processBenchmark(benchmarkSymbol :: Symbol, nVectors :: Int, dimension :: Int, prngVector :: Vector; samplingDistribution = Uniform)
    # get benchmark and its domain
    benchmark = Benchmarks.symbolToFunction[benchmarkSymbol]
    domain    = Benchmarks.benchmarkDomain[benchmarkSymbol]

    # randomly sample the "dimension"-dimensional domain of the given benchmark nVectors times
    domainDistribution = samplingDistribution(domain...)
    # don't have to worry about which set goes with which prng because
    # it will always be in the same order as prngVector
    rngPoints = sampleDomain.(prngVector, domainDistribution, nVectors, dimension)

    # pass the random vectors through the benchmark function
    return benchmarkTimed.(benchmark, rngPoints)
end

function main()
    benchmarkSymbolVector = names(Benchmarks)[2:end] # names() begins with the name of the package
    # instantiate prngs
    rngVector = [Xoshiro(), MersenneTwister()]
    # can go up to nVectors = 3*10^6, dimension = 30 with reasonable runtime
    nVectors  = 2
    dimension = 2

    #= Threads.@threads =# 
    for benchmarkSymbol in benchmarkSymbolVector
        # Benchmarks
        println("Starting $(string(benchmarkSymbol)) on thread $(Threads.threadid())")
        processedBenchmarks = processBenchmark(benchmarkSymbol, nVectors, dimension, rngVector)
        display(processedBenchmarks)
        println("Benchmark processing completed.")

        # Statistics
        # TODO: processedBenchmarks also gives timing; need to remove for stats on solutions
        println("Starting statistical analysis...")
        stats = doStats.(processedBenchmarks)
        for (rng, stats) in zip(rngVector, stats)
            println(rng, " : ", stats)
        end
        println("=======================================================================")
    end
end

main()