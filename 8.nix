with builtins;
with import <nixpkgs/lib>;
with import ./common.nix;
rec {
        parsePos = compose [ (splitString ",") (map toInt) ];
        positions = map parsePos (lines (readInput ./8.txt));
        groups = map toList (range 0 (length positions - 1));
        distSquared = i1: i2:
                sum (zipListsWith (x1: x2: squared (x2 - x1)) (elemAt positions i1) (elemAt positions i2));
        squared = x: x * x;
        edges = foldl (acc: i1:
                acc ++ foldl (acc: i2:
                        toList {
                                inherit i1 i2;
                                dist=distSquared i1 i2;
                        } ++ acc) [] (range (i1 + 1) (length positions - 1))) [] (range 0 (length positions - 1));
        kruskalEdges = flip take (sort (a: b: a.dist < b.dist) edges);
        connectEdge = groups: edge: with edge;
                let
                        groupWithA = findFirst (elem i1) null groups;
                        groupWithB = findFirst (elem i2) null groups;
                        otherGroups = filter (g: g != groupWithA && g != groupWithB) groups;
                in
                        append (nub (groupWithA ++ groupWithB)) otherGroups;
        connectEdges = groups: edges:
                if edges == [] then
                        groups
                else
                        connectEdges (connectEdge groups (head edges)) (tail edges);
}
