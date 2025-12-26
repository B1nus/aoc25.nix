with builtins;
with import <nixpkgs/lib>;
with import ./common.nix;
rec {
        readPos = s: let
                toNumberList = compose [ (splitString ",") (map toInt) ];
                numberList = toNumberList s;
                numberAt = elemAt numberList;
        in
                { x = numberAt 0; y = numberAt 1; z = numberAt 2; };
        input = compose [ readInput lines (map readPos) ] ./8.txt;
        computeEdges = positions: thisIndex:
                if length positions <= 1 then
                        []
                else let
                        this = head positions;
                        rest = tail positions;
                        combiner = zipped: with zipped;
                                {
                                        inherit this thisIndex;
                                        that = fst;
                                        thatIndex = snd;
                                };
                        combined = map combiner (zipLists rest (genList (x: 1 + x + thisIndex) (length rest)));
                in
                        combined ++ computeEdges rest (thisIndex + 1);
        processPositionsToEdges = compose [ (flip computeEdges 0) attachLengths sortEdges ];
        inputEdges = processPositionsToEdges input;
        deltaPos = p1: p2:
                zipAttrsWith
                (name: values: head values - elemAt values 1)
                [ p2 p1 ];
        squareSum = compose [
                (mapAttrs (_: n: n * n))
                attrValues
                sum
        ];
        edgeLength = edge: with edge;
                squareSum (deltaPos this that);
        attachLengths =
                let
                        attachLength = edge: { length = edgeLength edge; } // edge;
                in
                        map attachLength;
        sortEdges = sort (a: b: a.length < b.length);
        inputGroups = map toList (lists.range 0 (length input - 1));
        # Changing from inputing the edges into instead just having an element makes all the difference. I guess the garbage collector is a bit sucky in this language. Investigate more. Maybe someone can make it better. Maybe I could try.
        connectInputGroups = groups: edge: i:
                let
                        inherit (edge) thisIndex thatIndex;
                        mergeGroups = compose [ (foldl1 concat) nub ];
                        predicate = x: elem thisIndex x || elem thatIndex x;
                        partitioned = partition predicate groups;
                        mergedGroup = (mergeGroups partitioned.right);
                        # This if statement made a big difference. presumably lot's of unnecessary memory stuff going on otherwise. Investigate more.
                        newGroups = if count predicate groups == 1 then groups else jayce (length groups - 1) (append mergedGroup partitioned.wrong);
                in
                {
                        inherit edge;
                        i = i + 1;
                        groups = newGroups;
                };
        isFullyConnected = groups:
                length groups == 1;
        lastConnectedEdge = { edge ? null, groups ? inputGroups, sortedEdges ? inputEdges, i ? 0 }:
                if isFullyConnected groups then
                        edge
                else
                        lastConnectedEdge (connectInputGroups groups (elemAt sortedEdges i) i);
        answer = with lastConnectedEdge {};
                this.x * that.x;
} // builtins
