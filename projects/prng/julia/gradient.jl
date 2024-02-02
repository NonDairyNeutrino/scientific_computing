# Empirical Gradient descent
# Author: Nathan Chapman
# Date: February 2024
module EmpiricalGradient
export gradientDescent

using LinearAlgebra

function gradient(step :: T, foo :: Function, pointCurrent :: Vector) where T <: Real
    # get the current image of the given point under foo
    imageCurrent = foo(pointCurrent)

    # create vector of copies of the input vector
    pointCurrentCopyVector = fill(pointCurrent, length(pointCurrent))
    # turn vector of vectors into matrixToVector to add scaled identity matrix
    pointNewMatrix         = stack(pointCurrentCopyVector) + step*I
    # turn back into vector of stepped-vectors
    pointNewVector         = collect.(eachrow(pointNewMatrix))

    # evaluate foo on each stepped point
    imageNewVector         = foo.(pointNewVector)
    # return the difference, giving the empirical gradient
    return imageNewVector .- imageCurrent
end

function updatePoint(step :: T, foo :: Function, pointCurrent :: Vector) where T <: Real
    grad = gradient(step, foo, pointCurrent)
    return pointCurrent - step * grad, grad
end

function gradientDescent(step :: T, foo :: Function, pointCurrent :: Vector; threshold = 10^-10) where T <: Real
    point = pointCurrent
    grad  = [threshold]
    while norm(grad) >= threshold
        point, grad = updatePoint(step, foo, point)
    end
    return point
end
# gradientDescent(0.001, point -> dot(point, point), [1,0]) |> display

end