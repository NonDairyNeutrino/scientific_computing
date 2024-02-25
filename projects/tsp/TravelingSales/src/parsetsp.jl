# functionality to parse tsp files into adjacency matrices

# NOTE: Geographic distance calculations
#= 
For converting coordinate input to longitude and latitude in radian:

  PI = 3.141592;

  deg = (int) x[i];
  min = x[i]- deg;
  rad = PI * (deg + 5.0 * min/ 3.0) / 180.0;
 
For computing the geographical distance:

 RRR = 6378.388;

 q1 = cos( longitude[i] - longitude[j] );
 q2 = cos( latitude[i] - latitude[j] );
 q3 = cos( latitude[i] + latitude[j] );
 dij = (int) ( RRR * acos( 0.5*((1.0+q1)*q2 - (1.0-q1)*q3) ) + 1.0); 
=#

"""
    parseProblem(path :: String) :: Matrix

Gives the adjacency matrix of the given TSP instance.
"""
function parseProblem(filePath :: String) :: Matrix
    problemString = readchomp(filePath)
    dimension = parse(Int, match(r"DIMENSION: (\d+)", problemString)[1])

    if contains(problemString, "EDGE_WEIGHT_TYPE: EXPLICIT") && contains(problemString, "EDGE_WEIGHT_FORMAT: FULL_MATRIX")
        regex = r"EDGE_WEIGHT_SECTION\n(?<weights>[\d\s]+)DISPLAY_DATA_SECTION"
        weightString = match(regex, problemString)["weights"] |> strip

        mat = Matrix{Int}(undef, dimension, dimension)
        for (i, row) in enumerate(eachmatch(r"[\d ]+", weightString))
            for (j, col) in enumerate(eachmatch(r"\d+", row.match))
                # println("row: $i, col: $j, n: ", col.match)
                mat[i, j] = parse(Int, col.match)
            end
        end
    end
    return mat
end
