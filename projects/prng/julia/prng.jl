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

function benchmarkTimed(benchmark, point)
    timed = @timed benchmark(point)
    return [timed.time, timed.value]
end

function runExperiment(prng, benchmarkSymbol :: Symbol, nExperiments :: Int, dimension) :: Vector
    benchmark   = Benchmarks.symbolToFunction[benchmarkSymbol]
    domain      = Benchmarks.benchmarkDomain[benchmarkSymbol]

    pointVector = generatePoints(prng, domain, nExperiments, dimension)
    imageVector = benchmarkTimed.(benchmark, pointVector)
    return imageVector
end

function main()
    nExperiments, dimension = getParameters()
    # names() begins with the name of the package
    benchmarkSymbolVector = names(Benchmarks)[2:end]

    for benchmarkSymbol in benchmarkSymbolVector
        for prng in prngVector
            dataTimeMatrix = runExperiment(prng, benchmarkSymbol, nExperiments, dimension) |> stack
            valueVector    = dataTimeMatrix[2, :]
            timeVector     = dataTimeMatrix[1, :]
            statsValue     = doStats(valueVector)
            statsTime      = doStats(timeVector)
            println(string(benchmarkSymbol), " - ", typeof(prng))
            println("value stats: ", statsValue)
            println("time  stats: ", statsTime)
            println("==========================")
        end
    end
end

main()