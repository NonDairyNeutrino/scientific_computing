module MyStats
export doStats

using Statistics

function doStats(v::Vector)
    average = mean(v)
    stdDev = std(v)
    bounds = extrema(v)
    middle = median(v)
    return (average = average, stdDev = stdDev, bounds = bounds, middle = middle)
end
end