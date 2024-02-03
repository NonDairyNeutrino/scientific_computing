include("benchmarks.jl")
include("generate.jl")
include("stats.jl")
using .Benchmarks, .Generate, .MyStats
#= General Idea
1. Choose a benchmark and a prng (e.g. Xoshiro or MersenneTwister)
2. Generate psuedo-random vectors (prv) in the domain of the benchmark
3. Evaluate the benchmark on each of the prvs
4. Do statistical analysis on the results
=#
function getParameters() :: Tuple{Int, Int}
    print("Number of experiments: ")
    nVectors  = parse(Int, readline())
    print("Number of dimensions: ")
    dimension = parse(Int, readline())
    return nVectors, dimension
end

function runExperiment(prng, benchmarkSymbol :: Symbol, nExperiments :: Int, dimension) :: Vector
    benchmark   = Benchmarks.symbolToFunction[benchmarkSymbol]
    domain      = Benchmarks.benchmarkDomain[benchmarkSymbol]

    pointVector = generatePoints(prng, domain, nExperiments, dimension)
    imageVector = benchmark.(pointVector)
    return imageVector
end

function main()
    nExperiments, dimension = getParameters()
    # names() begins with the name of the package
    benchmarkSymbolVector = names(Benchmarks)[2:end]

    for benchmarkSymbol in benchmarkSymbolVector# get benchmark and its domain
        for prng in prngVector
            data  = @timed runExperiment(prng, benchmarkSymbol, nExperiments, dimension)
            stats = doStats(data.value)
            println(string(benchmarkSymbol), " - ", typeof(prng))
            println("value stats: ", stats)
            println("time  stats: ", data.time)
            println("==========================")
        end
    end
end

main()