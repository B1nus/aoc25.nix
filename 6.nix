with import <nixpkgs/lib>;
with import ./common.nix;
with builtins;
rec {
        inputText = readInput ./6.txt;
        inputLines = lines inputText;
        numberLines = dropEnd 1 inputLines;
        operatorLine = last inputLines;
        numbers = map (line: map toInt (words line)) numberLines;
        operators = words operatorLine;
        fold = operator:
                if operator == "*" then
                        foldl' mul 1
                else
                        foldl' add 0;
        bigFold = numbers: operators:
                if operators == [] then
                        0
                else
                        let
                                headNums = map head numbers;
                                operator = head operators;
                                tailNumbers = map tail numbers;
                                tailOperators = tail operators;
                        in
                                fold operator headNums + bigFold tailNumbers tailOperators;
}
