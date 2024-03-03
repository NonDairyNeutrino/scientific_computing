# Functionality to statistically significant analysis on the DGSA as applied to the tsp
mainFunctionPath, dataDirectoryPath = ARGS
using Statistics, DelimitedFiles # from standard library
using ProgressBars
include(mainFunctionPath)
using .TravelingSales

function doStats(v::Vector)
    average = round(mean(v)   , sigdigits=3)
    stdDev = round(std(v)     , sigdigits=3)
    bounds = round.(extrema(v), sigdigits=3)
    middle = round(median(v)  , sigdigits=3)
    return [bounds..., middle , average, stdDev]
end

const NUM_EXPERIMENTS = 30  # must be at least 30; see central limit theorem
const NUM_STEPS       = 200 # choose 200 as in literature
const NUM_AGENTS      = 10  # choose 10 as in literature
const MAX_DIMENSION   = 100

# sort problems by dimension
getDimension(name) = parse(Int, match(r"[a-zA-Z]+(?<dim>\d+)", name)["dim"])
sortedProblemVector= sort(readdir(dataDirectoryPath, join=true), by = getDimension)
problemVector      = filter(problem -> getDimension(problem) <= MAX_DIMENSION, sortedProblemVector)

# initialize data file
dataFile = open("analysis_data.csv", "w")
writedlm(dataFile, ["experiments," NUM_EXPERIMENTS; "steps," NUM_STEPS; "agents," NUM_AGENTS])
writedlm(dataFile, [["name", "minimum", "maximum", "median", "average", "standard deviation"]], ", ")

for (index, tsp) in enumerate(problemVector)
    name = match(r"\w+/(?<name>\w+).", tsp)["name"]
    println("starting $name")
    adjacencyMatrix = TravelingSales.parseProblem(tsp)

    data = Vector(undef, NUM_EXPERIMENTS)
    Threads.@threads for i in ProgressBar(1:NUM_EXPERIMENTS)
        # println("starting $name - run $i/$NUM_EXPERIMENTS on thread ", Threads.threadid())
        data[i] = main([adjacencyMatrix, NUM_STEPS, NUM_AGENTS])[2]
    end

    writedlm(dataFile, [[name, doStats(data)...]], ", ")

    println("========== ", name, "COMPLETE ==========")
end

close(dataFile)