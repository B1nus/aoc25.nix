with builtins;
with import <nixpkgs/lib>;
with import ./common.nix;
rec {
        cellss = compose [ readInput read2dString ] ./7.txt;
        beams = let
                        width = length (head cellss);
                        zeros = replicate (div width 2) 0;
                in
                        zeros ++ [ 1 ] ++ zeros;
        beamFilter = cellFilter: cell: beam:
                if cell == cellFilter then
                        beam
                else
                        0;
        collidingBeams = cellRow: beamRow:
                zipListsWith (beamFilter "^") cellRow beamRow;
        unsplitBeams = cellRow: beamRow:
                zipListsWith (beamFilter ".") cellRow beamRow;
        splitBeams = cellRow: beamRow:
                let
                        colliding = collidingBeams cellRow beamRow;
                in
                        zipListsWith
                add
                (tail colliding ++ toList 0)
                (toList 0 ++ colliding);
        nextBeams = cellRow: beamRow:
                zipListsWith
                add
                (splitBeams cellRow beamRow)
                (unsplitBeams cellRow beamRow);
        simulate = cellss: beams:
                if cellss == [] then
                        beams
                else
                        jayce beams (simulate (tail cellss) (nextBeams (head cellss) beams));
}
