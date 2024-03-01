# Functionality to statistically significant analysis on the DGSA as applied to the tsp
using Statistics, DelimitedFiles # from standard library
include("TravelingSales/src/TravelingSales.jl")
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
writedlm(dataFile, [["name", "minimum", "maximum", "median", "average", "standard deviation"]], ", ")

# create data
const NUM_EXPERIMENTS = 30
data = Vector(undef, NUM_EXPERIMENTS)
Threads.@threads for i in 1:NUM_EXPERIMENTS
    data[i] = main(ARGS)[2]
end
# do stats
stats = doStats(data)
# write data
writedlm(dataFile, [[basename(ARGS[1]), stats...]], ", ")
