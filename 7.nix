with builtins;
with import <nixpkgs/lib>;
with import ./common.nix;
rec {
        grid = compose [ readInput read2dString newGrid withStarterBeam (withSplits 0) ] ./7.txt;
        withStarterBeam = grid:
                withBeams (toList (newPos 0 (div grid.width 2))) grid;
        withBeams = beams: grid:
                {
                        inherit (grid) content width height;
                        inherit beams;
                };
        withSplits = splits: grid:
                {
                        inherit (grid) content width height beams;
                        inherit splits;
                };
        gravity = beam: with beam;
                {
                        row=row + 1;
                        inherit col;
                };
        split = beam: with beam;
                [
                        (newPos row (col - 1))
                        (newPos row (col + 1))
                ];
        newBeams = grid: with grid;
                if beams == [] then
                        []
                else
                        let
                                tailBeams = tail beams;
                                beam = head beams;
                                gravityBeam = gravity beam;
                                cell = elemAtGrid grid gravityBeam;
                        in
                                if cell == null then
                                toList beam ++ tailBeams
                        else if cell == "^" then
                                split gravityBeam ++ newBeams (withBeams tailBeams grid)
                        else
                                toList gravityBeam ++ newBeams (withBeams tailBeams grid);
        simulateEntire = grid:
                simulate (grid.height - 1) grid;
        simulate = steps: grid:
                if steps == 0 then
                        grid
                else 
                        let
                                nextBeams = (newBeams grid);
                                newSplits = length nextBeams - length grid.beams;
                        in
                                simulate (steps - 1) (withSplits
                                        (grid.splits + newSplits)
                                        (withBeams (nub nextBeams) grid));
}
