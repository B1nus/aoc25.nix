with builtins; with (import <nixpkgs/lib>); let
  input = strings.trim (readFile ./1.txt);
  lines = strings.splitString "\n" input;
  items = map (l: toItem (strings.stringToCharacters l)) lines;
  toItem = l: (toSign (head l)) * (strings.toIntBase10 (strings.concatStrings (tail l)));
  toSign = c: if c == "R" then 1 else - 1;
  modulus = a: b: if a < 0 then modulus (a + b) b else mod a b;
  processItems = l: p: if length l == 0 then 0 else let
    newP = modulus (p + (head l)) 100;
    out = pointerToPoints p + processItems (tail l) newP;
  in trace newP out;
  pointerToPoints = p: if p == 0 then 1 else 0;
in processItems items 50
