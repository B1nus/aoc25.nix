with import <nixpkgs/lib>;
with import ./common.nix;
with builtins;
rec {
        inputText = readInput ./6.txt;
        inputLines = lines inputText;
        numberLines = dropEnd 1 inputLines;
        operatorLine = last inputLines;
        safeToInt = s: if s == "" then null else toInt s;
        numbers = splitList
                isNull
                (map
                        (compose [ concatStrings trim safeToInt ])
                        (transpose (map stringToCharacters numberLines)));
        operators = words operatorLine;
        fold = operator:
                if operator == "*" then
                        foldl' mul 1
                else
                        foldl' add 0;
        bigFold = numbers: operators:
                foldl' (acc: x: acc + fold x.snd x.fst) 0 (zipLists numbers operators);
}
