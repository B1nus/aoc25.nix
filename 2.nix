with builtins; let
    input = "492410748-492568208,246-390,49-90,16-33,142410-276301,54304-107961,12792-24543,3434259704-3434457648,848156-886303,152-223,1303-1870,8400386-8519049,89742532-89811632,535853-567216,6608885-6724046,1985013826-1985207678,585591-731454,1-13,12067202-12233567,6533-10235,6259999-6321337,908315-972306,831-1296,406-824,769293-785465,3862-5652,26439-45395,95-136,747698990-747770821,984992-1022864,34-47,360832-469125,277865-333851,2281-3344,2841977-2953689,29330524-29523460";
    toInt =
    let
      matchStripInput = match "[[:space:]]*0*(-?[[:digit:]]+)[[:space:]]*";
      matchZero = match "0+";
    in
    str:
    let
      # RegEx: Match any leading whitespace, then match any zero padding,
      # capture possibly a '-' followed by one or more digits,
      # and finally match any trailing whitespace.
      strippedInput = matchStripInput str;

      # RegEx: Match at least one '0'.
      isZero = matchZero (head strippedInput) == [ ];

      # Attempt to parse input
      parsedInput = fromJSON (head strippedInput);

      generalError = "toIntBase10: Could not convert ${escapeNixString str} to int.";

    in
    # Error on presence of non digit characters.
    if strippedInput == null then
      throw generalError
    # In the special case zero-padded zero (00000), return early.
    else if isZero then
      0
    # Error if parse function fails.
    else if !isInt parsedInput then
      throw generalError
    # Return result.
    else
      parsedInput;
    stringToCharacters = s: genList (p: substring p 1 s) (stringLength s);
    escape = list: replaceStrings list (map (c: "\\${c}") list);
    addContextFrom = src: target: substring 0 0 src + target;
    escapeRegex = escape (stringToCharacters "\\[{()^$?*+|.");
    escapeNixString = s: escape [ "$" ] (toJSON s);
    splitString =
    sep: s:
    let
      splits = builtins.filter builtins.isString (
        builtins.split (escapeRegex (toString sep)) (toString s)
      );
    in
    map (addContextFrom s) splits;
    rangeStrs = splitString "," input;
    ranges = map parseId rangeStrs;
    charToInt = c: builtins.getAttr c asciiTable;
    rem = a: b: a - (div a b) * b;
    digits = x: let f = y: if y > 0 then 1 + f (div y 10) else 0; in if x == 0 then 1 else f x;
    drop = count: list: sublist count (length list) list;
    take = count: sublist 0 count;
    sublist =
    start: count: list:
    let
      len = length list;
    in
    genList (n: elemAt list (n + start)) (
      if start >= len then
        0
      else if start + count > len then
        len - start
      else
        count
    );
    concatStrings = concatStringsSep "";
    replicate = n: elem: genList (_: elem) n;
    repeated = l:
    let
	len = length l;
        jinx = div len 2;
	tries = map (n: { l'=l; p=take (n) l; }) (range 1 jinx);
	repeated' = set: with set; (length l' == 0 || (if take (length p) l' == p then (if l' == p then true else repeated' { l'=drop (length p) l'; p=p; }) else false));
    	out = any repeated' tries;
    in out;
    range = start: end: map (add (start - 1)) (genList (add 1) (end - start + 1));
    viktor = x: deepSeq x x;
    dbg = x: trace x x;
    dbg' = x: dbg (viktor x);
    jayce = s: x: trace (deepSeq s s) x;
    toChars = n: stringToCharacters (toString n);
    faulty = r: foldl' (acc: x: add acc x) 0 (map (x: if repeated (toChars x) then x else 0) r);
    parseId = s: let l = splitString "-" s; from = toInt (head l); to = toInt (head (tail l)); in range from to;
    sum = foldl' add 0;
in sum (map faulty ranges)
