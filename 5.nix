with builtins;
with import <nixpkgs/lib>;
with import ./common.nix;
rec {
        unparsed = with halfString "\n\n" (readInput ./5.txt);
                {
                        ranges = left;
                        foods = right;
                };
        toRange = s: with halfString "-" s;
                {
                        from = toInt left;
                        to = toInt right;
                };
        ranges = map toRange (lines unparsed.ranges);
        foods = map toInt (lines unparsed.foods);
        inRange = x: range: x >= range.from && x <= range.to;
        isFresh = food: any (inRange food);
        freshFoods = ranges: filter (flip isFresh ranges);
        countFresh = ranges: compose [ (freshFoods ranges) length ];
}
