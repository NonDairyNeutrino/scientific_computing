# Functionality to statistically significant analysis on the DGSA as applied to the tsp
mainFunctionPath, dataDirectoryPath = ARGS
using Statistics, DelimitedFiles # from standard library
include(mainFunctionPath)
using .TravelingSales

function doStats(v::Vector)
    average = round(mean(v)   , sigdigits=3)
    stdDev = round(std(v)     , sigdigits=3)
    bounds = round.(extrema(v), sigdigits=3)
    middle = round(median(v)  , sigdigits=3)
    return [bounds..., middle , average, stdDev]
end

# create data
const NUM_EXPERIMENTS = 30
const NUM_STEPS       = 200 # choose 200 as in literature
const NUM_AGENTS      = 10  # choose 10 as in literature

problemVector = readdir(dataDirectoryPath, join=true)[1:1] # ONLY DO THE FIRST FILE IN THE DIRECTORY
statsMatrix = Matrix(undef, length(problemVector), 6#= number of stats as above e.g. name, minimum, etc. =#)

#= Threads.@threads =# for (index, tsp) in enumerate(problemVector)
    name = match(r"(?<name>\w+).", tsp)["name"]
    println("starting $name on thread ", Threads.threadid())

    data = Vector(undef, NUM_EXPERIMENTS)
    Threads.@threads for i in 1:NUM_EXPERIMENTS
        data[i] = main([tsp, NUM_STEPS, NUM_AGENTS])[2]
    end
    statsMatrix[index, 1]     = basename(tsp)
    statsMatrix[index, 2:end] = doStats(data)
end

# initialize data file
dataFile = open("analysis_data.csv", "w")
writedlm(dataFile, [["name", "minimum", "maximum", "median", "average", "standard deviation"]], ", ")
writedlm(dataFile, statsMatrix, ", ")
close(dataFile)