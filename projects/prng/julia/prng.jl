include("benchmarks.jl")
using Random, Statistics # standard library
using .Benchmarks, Distributions # not in standard library

matrixToVector(mat :: Matrix) = collect.(eachrow(mat))

function doStats(v :: Vector)
    average = mean(v)
    stdDev  = std(v)
    bounds  = extrema(v)
    middle  = median(v)
end

function processBenchmark(benchmarkSymbol :: Symbol, prngs...)
    # get benchmark and its domain
    benchmark = Benchmarks.symbolToFunction[benchmarkSymbol]
    domain    = Benchmarks.benchmarkDomain[benchmarkSymbol]
    # println("Starting $benchmark on thread $(Threads.threadid())")
    # generate random vectors within respective domains
    randomVectorVector = matrixToVector.(rand.(prngs, Uniform(domain...), nVectors, dimension))
    # pass the random vectors through the benchmark function
    benchmark.(randomVectorVector)
    # println("Finished $benchmark")
end

function main()
    # instantiate prngs
    rngXoshiro  = Xoshiro()
    rngMersenne = MersenneTwister()

    # generate random vectors with different prngs
    # can go up to nVectors = 3*10^6, dimension = 30 with reasonable runtime
    nVectors  = 30
    dimension = 30

    # Threads.@threads 
    for benchmarkSymbol in names(Benchmarks)[2:end] # names() begins with the name of the package
        processBenchmark(benchmarkSymbol, rngXoshiro, rngMersenne)
        # Statistics

    end
end