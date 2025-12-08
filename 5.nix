with builtins;
with import <nixpkgs/lib>;
with import ./common.nix;
rec {
        ranges =
                with halfString "\n\n" (readInput ./5.txt);
                sort (a: b: a.left < b.left) (map toRange (lines left));
        toRange = s: with halfString "-" s; newRange (toInt left) (toInt right);
        newRange = left: right: { inherit left right; };
        overlapping = r1: r2: !(r1.right < r2.left || r1.left > r2.right);
        numbers = r: with r; right - left + 1;
        # String interpolation not workie in trace function.
        # Language bug?
        showRange = r: with r; toString left + "-" + toString right;
        mergeTwoRanges = r1: r2: newRange (min r1.left r2.left) (max r1.right r2.right);
        mergeRanges =
                sortedRanges:
                if sortedRanges == [ ] then
                        [ ]
                else if length sortedRanges == 1 then
                        sortedRanges
                else
                        let
                                r1 = head sortedRanges;
                                r2 = elemAt sortedRanges 1;
                        in
                                if overlapping r1 r2 then
                                mergeRanges (toList (mergeTwoRanges r1 r2) ++ drop 2 sortedRanges)
                        else
                                toList r1 ++ mergeRanges (drop 1 sortedRanges);
}
