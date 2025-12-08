with builtins; with import <nixpkgs/lib>; rec {
        lines = strings.splitString "\n";
        readInput = path: strings.trim (readFile path);
        asList = f: l:
                let
                        out = f (strings.stringToCharacters l);
                in
                        if isList out && isString (head out) then
                                strings.concatStrings out
                        else
                                out;
        changeList = l: i: x:
                if i == 0 then
                        [ x ] ++ tail l
                else 
                        [ (head l) ] ++ changeList (tail l) (i - 1) x;
        rem = a: b: a - div a b * b;
        mod = a: b: let
                r = rem a b;
        in 
                if r < 0 then r + b else r;
        boolToInt = b: if b then 1 else 0;
        abs = x: if x < 0 then - x else x;
}
