# functionality for operations in the seach space

"""
    swap(vec :: Vector, i :: Int, j :: Int) :: Vector

Gives a copy of a vector whose i-th and j-th entries are swapped.

Also acts as the small movement operator.
"""
function swap(vec :: Vector, i :: Int, j :: Int) :: Vector
    newVec = copy(vec)
    newVec[i] = vec[j]
    newVec[j] = vec[i]
    return newVec
end

"""
    swap!(vec :: Vector, i :: Int, j :: Int) :: Vector

In-place swap the elements i and j of a vector
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

Gives the collection of tours that are one swap away from the given tour.
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

"""
    localSearch!(costFunction :: Function, solution :: Solution) :: Solution

Performs a greedy local search and updates the solution.
"""
function localSearch!(costFunction :: Function, solution :: Solution) :: Solution
    currentCost = costFunction(solution.position)
    IML = ceil(Int, rand() * solution.velocity) # independent movement length
    # TODO: use 2-opt for IMO and break when iteration == IML or all neighbors have been compared
    for i in 1:IML
        neighborhood                = getNeighborhood(solution.position)
        bestCost, bestNeighborIndex = findmin(costFunction, neighborhood)
        bestNeighbor                = neighborhood[bestNeighborIndex]
        if bestCost > currentCost
            break
        end
        solution.position = bestNeighbor
    end
    return solution
end

"""
    localSearch(costFunction :: Function) :: Function

Gives a function that can be applied to a solution.
"""
function localSearch!(costFunction :: Function) :: Function
    return solution -> localSearch!(costFunction, solution)
end

"""
    distance(x :: Vector, y :: Vector) :: Int

Gives the number of element swaps to get from one permutation to another.
"""
function distance(x :: Vector, y :: Vector) :: Int
    newy = deepcopy(y)
    for i in eachindex(x)
        index = findall(z -> z == x[i], newy)[1]
        swap!(newy, i, index)
        newy == x ? (return i) : continue
    end
end

"""
    simpleMove!(solution :: Solution, targetSolution :: Solution, iml :: Int) :: Nothing

Moves a solution toward a target for a given dependent movement length.
"""
function simpleMove!(solution :: Solution, targetSolution :: Solution, dml :: Int) :: Nothing
    for i in 1 : dml # what if acceleration > distance?
        # small move solution towards KBestSolution
        index = findall(z -> z == targetSolution.position[i], solution.position)[1]
        swap!(solution.position, i, index)
    end
    return
end

"""
    multiTargetMove(solution :: Solution, targetSolutionVector :: Vector{Solution}) :: Nothing

Performs 
"""
function multiTargetMove!(accelerationFunction :: Function, solution :: Solution, targetSolutionVector :: Vector{Solution}) :: Nothing
    for targetSolution in targetSolutionVector
        iml = accelerationFunction(solution, targetSolution)
        simpleMove!(solution, targetSolution, iml)
    end
end

function multiTargetMove!(accelerationFunction :: Function) :: Function
    (solution, targetSolutionVector) -> multiTargetMove!(accelerationFunction, solution, targetSolutionVector)
end