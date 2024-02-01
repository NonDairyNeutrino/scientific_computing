module Benchmarks
export schwefel, deJong1, rosenbrock, rastrigin, griewangk, sesw, svsw, ackley1, ackley2, eggHolder

using LinearAlgebra

const benchmarkDomain = Dict(
    :schwefel   => (-512, 512),
    :deJong1    => (-100, 100),
    :rosenbrock => (-100, 100),
    :rastrigin  => (-30, 30),
    :griewangk  => (-500, 500),
    :sesw       => (-30, 30),
    :svsw       => (-30, 30),
    :ackley1    => (-32, 32),
    :ackley2    => (-32, 32),
    :eggHolder  => (-500, 500)
)

function schwefel(x :: Vector{T}) where T <: Real
    magicNumber = 418.9829
    return magicNumber * length(x) + dot(x, sin.(sqrt.(abs.(x))))
end

function deJong1(x :: Vector{T}) where T <: Real
    return dot(x, x)
end

function rosenbrock(x :: Vector{T}) where T <: Real
    v1 = x[1:end-1].^2 - x[2:end]
    v2 = 1 .- x
    return 100 * dot(v1, v1) + dot(v2, v2)
end

function rastrigin(x :: Vector{T}) where T <: Real
    return 10 * length(x) * (dot(x, x) - sum(10 * cos.(2*pi * x)))
end

function griewangk(x :: Vector{T}) where T <: Real
    return 1 + dot(x, x) / 4000 - prod(cos.(x ./ sqrt.(1:length(x))))
end

function sesw(x :: Vector{T}) where T <: Real
    v1 = x[1:end-1].^2 + x[2:end].^2
    v2 = sin.(v1 .- 0.5) ./ (1 .+ 0.001 * v1)
    return -(length(x) - 1)/2 - dot(v2, v2)
end

function svsw(x :: Vector{T}) where T <: Real
    v1 = x[1:end-1].^2 + x[2:end].^2
    v2 = fourthroot.(v1)
    v3 = sin.(50 * v1.^0.1).^2
    return length(x) - 1 + dot(v2, v3)
end

function ackley1(x :: Vector{T}) where T <: Real
    v1 = x[1:end-1] .^ 2 + x[2:end] .^ 2
    v2 = exp(0.2)^-1 * sqrt.(v1)
    v3 = 3 * (cos.(2 * x[1:end-1]) + sin.(2 * x[2:end]))
    return sum(v2 + v3)
end

function ackley2(x :: Vector{T}) where T <: Real
    v1 = x[1:end-1] .^ 2 + x[2:end] .^ 2
    termConstant = (20 + exp(1)) * (length(x) - 1)
    term1 = -20 * exp.(-0.2 * sqrt.(0.5 * v1))
    term2 = exp.(0.5 * (cos.(2 * pi * x[1:end-1]) + cos.(2 * pi * x[2:end])))
    return termConstant + sum(term1 + term2)
end

function eggHolder(x :: Vector{T}) where T <: Real
    v1 = x[1:end-1] - x[2:end]
    term1 = dot(x[1:end-1], sin.(sqrt.(abs.(v1 .- 47))))
    term2 = dot(x[2:end] .+ 47, sin.(sqrt.(abs.(x[2:end] + 0.5 * x[1:end-1] .+ 47))))
    return -(term1 + term2)
end

const symbolToFunction = Dict(Symbol(foo) => foo for foo in [schwefel, deJong1, rosenbrock, rastrigin, griewangk, sesw, svsw, ackley1, ackley2, eggHolder])

end