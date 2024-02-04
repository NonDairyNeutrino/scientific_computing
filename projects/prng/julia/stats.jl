module MyStats
export doStats

using Statistics

function doStats(v::Vector)
    average = round(mean(v),     sigdigits = 3)
    stdDev  = round(std(v),      sigdigits = 3)
    bounds  = round.(extrema(v), sigdigits = 3)
    middle  = round(median(v),   sigdigits = 3)
    return (average = average, stdDev = stdDev, bounds = bounds, median = middle)
end
end