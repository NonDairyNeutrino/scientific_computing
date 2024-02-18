using Documenter
using TravelingSales

makedocs(
    sitename = "TravelingSales.jl",
    authors  = "Nathan Chapman",
    format   = Documenter.HTML(),
    modules  = [TravelingSales],
    pages    = [
        "Home" => "index.md",
        "Gravitational Search Algorithm" => "gravity.md"
    ]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
# deploydocs(
#     repo      = "github.com/NonDairyNeutrino/scientific_computing.git",
#     devbranch = "trunk"
# )
