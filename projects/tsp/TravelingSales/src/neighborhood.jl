# define the neighborhood functionality
"""
    swap(vec :: Vector, i :: Int, j :: Int) :: Vector

Gives a copy of a vector whose i-th and j-th entries are swapped.
"""
function swap(vec :: Vector, i :: Int, j :: Int) :: Vector
    newVec = deepcopy(vec)
    newVec[i] = vec[j]
    newVec[j] = vec[i]
    return newVec
end

"""
    swap!(vec :: Vector, i :: Int, j :: Int) :: Vector

In-place swap the elements of a vector
"""
function swap!(vec :: Vector, i :: Int, j :: Int) :: Vector
    elemi = vec[i]
    elemj = vec[j]
    vec[i] = elemj
    vec[j] = elemi
    return vec
end

"""
    getNeighborhood(tour :: Vector{Int}; keep = false :: Bool) :: Vector{Vector{Int}}

Gives the collection of tours 
"""
function getNeighborhood(tour :: Vector{Int}; keep = false :: Bool) :: Vector{Vector{Int}}
    neighborhood = Vector{Int}[]
    for i in 1 : (length(tour) - 1)
        for j in i+1 : length(tour)
            push!(neighborhood, swap(tour, i, j))
        end
    end
    if keep
        pushfirst!(neighborhood, tour)
    end
    return neighborhood
end