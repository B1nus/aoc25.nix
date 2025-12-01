with builtins;
with (import <nixpkgs/lib>);
let
  input = strings.trim (readFile ./1.txt);
  lines = strings.splitString "\n";
  items = map (l: toItem (strings.stringToCharacters l)) (lines input);
  toItem =
    let
      toSign = c: if c == "R" then 1 else -1;
    in
    l: (toSign (head l)) * (strings.toIntBase10 (strings.concatStrings (tail l)));
  doAll =
    l: p:
    if length l == 0 then
      0
    else
      with (do p (p + head l));
      let
        out = pts + doAll (tail l) p';
        # Specifically string interpolation doesn't work with trace. No idea why. Maybe it's
        # a language bug.
        dbg =
          toString p
          + (if head l > 0 then "+" else "")
          + toString (head l)
          + " = "
          + toString p'
          + "("
          + toString pts
          + ")";
      in
      trace dbg out;
  abs = x: if x < 0 then -x else x;
  divrem =
    b:
    let
      neg =
        a:
        let
          n = neg (a + b);
        in
        if a >= 0 then
          {
            q = 0;
            r = a;
          }
        else
          {
            q = n.q - 1;
            r = n.r;
          };
      pos =
        a:
        let
          n = pos (a - b);
        in
        if a < b then
          {
            q = 0;
            r = a;
          }
        else
          {
            q = n.q + 1;
            r = n.r;
          };
    in
    a: if a >= b then pos a else neg a;
  bToI = b: if b then 1 else 0;
  do =
    p: p2:
    with divrem 100 p2;
    let
      pts = if p2 <= 0 && p >= 0 then bToI (r == 0) + abs q - bToI (p == 0) else abs q;
    in
    {
      pts = pts;
      p' = r;
    };
in
{
  inherit do items doAll;
}
