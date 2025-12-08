with builtins;
with import <nixpkgs/lib>;
rec {
        lines = splitString "\n";
        compose = functions: argument:
                if functions == [] then
                        argument
                else
                        compose (tail functions) ((head functions) argument);
        halfString = sep: s:
                let
                        parts = strings.splitString sep s;
                in
                        {
                        left = head parts;
                        right = elemAt parts 1;
                };
        words = compose [ (splitString " ") (filter (s: stringLength s > 0)) ];
        readInput = path: strings.trim (readFile path);
        changeList = l: i: x: lists.take i l ++ [ x ] ++ lists.drop (i + 1) l;
        rem = a: b: a - div a b * b;
        mod = a: b: let
                r = rem a b;
        in 
                if r < 0 then r + b else r;
        boolToInt = b: if b then 1 else 0;
        abs = x: if x < 0 then - x else x;
        sum = foldl' add 0;
        nub = l:
                if l == [] then
                        []
                else if elem (head l) (tail l) then
                        nub (tail l)
                else
                        [ (head l) ] ++ nub (tail l);
        jayce = stderr: out:
                deepSeq stderr (trace stderr out);
        jinx = out:
                jayce out out;
}
