# Functionality to statistically significant analysis on the DGSA as applied to the tsp
using Statistics, DelimitedFiles # from standard library
include("Julia/TravelingSales/src/TravelingSales.jl") # this path depends on your current working directory
using .TravelingSales

function doStats(v::Vector)
    average = round(mean(v), sigdigits=3)
    stdDev = round(std(v), sigdigits=3)
    bounds = round.(extrema(v), sigdigits=3)
    middle = round(median(v), sigdigits=3)
    return [bounds..., middle, average, stdDev]
end

# initialize data file
dataFile = open("analysis_data.csv", "w")
# create header
writedlm(dataFile, [["name", "minimum", "maximum", "median", "average", "standard deviation"]], ", ")

# create data
const NUM_EXPERIMENTS = 30
const NUM_STEPS       = 200 # choose 200 as in literature
const NUM_AGENTS      = 10  # choose 10 as in literature

problemVector = readdir()
statsMatrix = Matrix(undef, length(problemVector), 6#= number of stats as above e.g. name, minimum, etc. =#)

Threads.@threads for (index, tsp) in enumerate(problemVector)
    data = Vector(undef, NUM_EXPERIMENTS)
    Threads.@threads for i in 1:NUM_EXPERIMENTS
        data[i] = main([tsp, NUM_STEPS, NUM_AGENTS])[2]
    end
    statsMatrix[index, :] = doStats(data)
end

# write data
writedlm(dataFile, [[basename(ARGS[1]), stats...]], ", ")
