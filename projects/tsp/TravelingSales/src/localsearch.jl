"""
    localSearch(solution :: Solution) :: Solution

Performs a greedy local search and updates the solution
"""
function localSearch(costFunction :: Function, solution :: Solution) :: Solution
    currentCost = costFunction(solution.position)
    IML = rand() * solution.velocity |> ceil # independent movement length
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
function localSearch(costFunction :: Function) :: Function
    return solution -> localSearch(costFunction, solution)
end