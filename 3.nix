with builtins; with import <nixpkgs/lib>; with strings; with trivial; with lists; rec {
  input = trim (readFile ./3.txt);
  toInts = s: map toInt (stringToCharacters s);
  lines = splitString "\n";
  sum = foldl' add 0;
  maximum = foldl' max 0;
  minPos = l: x: findFirstIndex (y: y == x) null l;
  maxPos = l: x: length l - 1 - findFirstIndex (y: y == x) null (reverseList l);
  joltage = l:
    let
      firstDigit = maximum (sublist 0 (length l - 1) l);
      firstDigitPos = minPos l firstDigit;
      secondDigit = maximum (sublist (firstDigitPos + 1) (length l - firstDigitPos - 1) l);
    in
      firstDigit * 10 + secondDigit;
  parsed = map toInts (lines input);
  joltages = map joltage parsed;
}
