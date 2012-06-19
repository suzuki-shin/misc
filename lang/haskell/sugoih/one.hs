triples :: [(Int, Int, Int)]
triples = [(a, b, c) | c <- [1..10], a <- [1..10], b <- [1..10]]

right_triangles :: [(Int, Int, Int)]
right_triangles = [(a, b, c) | c <- [1..10], a <- [1..c], b <- [1..a], a^2 + b^2 == c^2]
