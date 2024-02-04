# Empirical Gradient descent
# Author: Nathan Chapman
# Date: February 2024
module EmpiricalGradient
export gradientDescent

using LinearAlgebra

function gradient(step :: T, foo :: Function, pointCurrent :: Vector, imageCurrent :: T) where T <: Real
    # create vector of copies of the input vector
    pointCurrentCopyVector = fill(pointCurrent, length(pointCurrent))
    # turn vector of vectors into matrixToVector to add scaled identity matrix
    pointNewMatrix         = stack(pointCurrentCopyVector) + step*I
    # turn back into vector of stepped-vectors
    pointNewVector         = collect.(eachcol(pointNewMatrix))

    # evaluate foo on each stepped point
    imageNewVector         = foo.(pointNewVector)
    # return the difference, giving the empirical gradient
    return imageNewVector .- imageCurrent
end

function updatePoint(step :: T, foo :: Function, pointCurrent :: Vector, imageCurrent :: T) where T <: Real
    grad     = gradient(step, foo, pointCurrent, imageCurrent)
    pointNew = pointCurrent - step * grad
    return pointNew
end

function gradientDescent(step :: T, foo :: Function, initialGuess :: Vector; threshold = 10) where T <: Real
    point        = initialGuess
    imageNew     = foo(initialGuess)
    imageCurrent = imageNew + 1 # just to initialize and get into the loop

    while imageNew < imageCurrent
        imageCurrent = foo(point)
        point        = updatePoint(step, foo, point, imageCurrent)
        imageNew     = round(foo(point), digits = threshold)
    end
    return point, imageCurrent # <- optimizer, optimum
end
# gradientDescent(0.01, point -> dot(point, point), [1.1, 200.]) |> display

end