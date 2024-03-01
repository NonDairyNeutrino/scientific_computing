# Functionality to statistically significant analysis on the DGSA as applied to the tsp
using Statistics # from standard library
cd(
    include("./src/TravelingSales.jl"),
    "TravelingSales/"
)
using .TravelingSales

function doStats(v::Vector)
    average = round(mean(v), sigdigits=3)
    stdDev = round(std(v), sigdigits=3)
    bounds = round.(extrema(v), sigdigits=3)
    middle = round(median(v), sigdigits=3)
    return (average=average, stdDev=stdDev, bounds=bounds, median=middle)
end

[main([]) for i in 1:30]