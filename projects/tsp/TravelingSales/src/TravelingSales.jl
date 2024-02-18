"""
Main module to solve the Traveling Sales problem in both its symmetric and asymmetric forms.
"""
module TravelingSales
"""
    Solution

Gives a structured object with mass, position, velocity, and acceleration.
"""
struct Solution
    mass         :: Real
    position     :: Vector
    velocity     :: Vector
    acceleration :: Vector
    function Solution(position :: Vector)

    end
end

end # module TravelingSales
