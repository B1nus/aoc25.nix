with builtins; with import <nixpkgs/lib>; with strings; rec {
  input = trim (readFile ./3.txt);
  toInts = s: reverseList (map toInt (stringToCharacters s));
  lines = splitString "\n";
  sum = foldl' add [ 0 ];
  maximum = foldl' max 0;
  minPos = x: l: if head l == x then 0 else 1 + minPos x (cut 1 0 l);
  cut = a: b: l: sublist a (length l - b) l;
  digits = l: let
    go = l: n: let
      digit = maximum (cut 0 (n - 1) l);
      index = minPos digit l;
    in
      if n == 0 then
        []
      else
        go (cut (index + 1) 0 l) (n - 1) ++ [ digit ];
  in
    go (reverseList l) 12;
  headOrZero = l: if length l == 0 then 0 else head l;
  tailOrEmpy = l: if length l == 0 then [] else tail l;
  jayce = dbg: x: deepSeq dbg (trace dbg x);
  add = l1: l2: let
    go = c: l1: l2: let
      digitl1 = headOrZero l1;
      digitl2 = headOrZero l2;
      digits = addDigits digitl1 digitl2 c;
      digit = head digits;
      carry = head (tail digits);
    in if length l1 == 0 && length l2 == 0 && c == 0 then [ ] else [ digit ] ++ go carry (tailOrEmpy l1) (tailOrEmpy l2);
  in let out = go 0 l1 l2; in jayce ((show l1) + " + " + (show l2) + " = " + (show out)) out;
  rem = a: b: a - (div a b) * b;
  addDigits = d1: d2: c: [ (rem (d1 + d2 + c) 10) (div (d1 + d2 + c) 10) ];
  parsed = map toInts (lines input);
  joltages = map joltage parsed;
  show = l: concatStrings (map toString (lists.reverseList l));
}
