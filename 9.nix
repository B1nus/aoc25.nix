with builtins;
with import <nixpkgs/lib>;
with import ./common.nix;
rec {
        toTile = s: with halfString "," s;
                map toInt [ left right ];
        tiles = map toTile (lines (readInput ./9.txt));
        area = tile1: tile2:
                abs (foldl' mul 1 (map (compose [ abs (add 1) ]) (zipListsWith sub tile1 tile2)));
        allAreas = ts:
                if ts == [] then
                        []
                else
                        zipListsWith area (replicate (length ts) (head ts)) (tail ts) ++ allAreas (tail ts);
}
