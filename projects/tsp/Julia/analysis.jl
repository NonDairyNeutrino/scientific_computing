# Functionality to statistically significant analysis on the DGSA as applied to the tsp

# It's suggested to run this file from the tsp/Julia directory with the command
# julia -t auto --project=./TravelingSales analysis.jl TravelingSales/src/TravelingSales.jl ../data

using Statistics, DelimitedFiles # from standard library
using ProgressBars
include(mainFunctionPath)
using .TravelingSales

const NUM_EXPERIMENTS = 30  # must be at least 30; see central limit theorem
const NUM_STEPS       = 200 # choose 200 as in literature
const NUM_AGENTS      = 10  # choose 10 as in literature

if length(ARGS) == 2
    mainFunctionPath, dataDirectoryPath = ARGS
    println("no dimension bounds given, proceeding with 1 <= dim <= 20")
    MIN_DIMENSION, MAX_DIMENSION = [1, 20]
elseif length(ARGS) == 3
    mainFunctionPath, dataDirectoryPath = ARGS[1:2]
    MAX_DIMENSION = parse(Int, ARGS[3])
    MIN_DIMENSION = 1
elseif length(ARGS) == 4
    mainFunctionPath, dataDirectoryPath = ARGS[1:2]
    MIN_DIMENSION, MAX_DIMENSION = parse.(Int, ARGS[3:4])
else

end

function doStats(v::Vector)
    average = round(mean(v)   , sigdigits=3)
    stdDev = round(std(v)     , sigdigits=3)
    bounds = round.(extrema(v), sigdigits=3)
    middle = round(median(v)  , sigdigits=3)
    return [bounds..., middle , average, stdDev]
end

# sort problems by dimension
getDimension(name) = parse(Int, match(r"[a-zA-Z]+(?<dim>\d+)", name)["dim"])
const sortedProblemVector= sort(readdir(dataDirectoryPath, join=true), by = getDimension)
try
    global filteredProblemVector = filter(problem -> MIN_DIMENSION <= getDimension(problem) <= MAX_DIMENSION, sortedProblemVector)
    @assert !isempty(filteredProblemVector)
catch e
    println("no problems in dimension bounds. aborting.")
    exit()
end

# initialize data file
const dataFile = open("analysis_data.csv", "w")
writedlm(dataFile, ["experiments," NUM_EXPERIMENTS; "steps," NUM_STEPS; "agents," NUM_AGENTS])
writedlm(dataFile, [["name", "minimum", "maximum", "median", "average", "standard deviation"]], ", ")

for (index, tsp) in enumerate(filteredProblemVector)
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
