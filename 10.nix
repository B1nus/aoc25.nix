# Idea:
#   Make a list of all possible combinations of button presses
#   Take the one with the least presses
#   
# This should work right? The language is lazy. So it should be
# fine. Surely?
let imports = builtins // import <nixpkgs/lib> // import ./common.nix; in with imports; rec {
        readLights  = s: with halfString "]" s;
                {
                        lights = tail (stringToCharacters left);
                        rest   = right;
                };
        readButtons = compose [
                (s: substring 2 (stringLength s) s)
                (splitString " (")
                (map (s: with halfString ")" s; left))
                (map (splitString ","))
                (map (map toInt))
        ];
        readMachine = s: with readLights s; {
                inherit lights;
                buttons = readButtons rest;
        };
        pressButton = lights: button: let
                switchLight    = light: if light == "#" then "." else "#";
                switchLightIf  = light: index:
                        if elem index button then switchLight light else light;
                switchLightSet = set: with set; switchLightIf fst snd;
                zipWithIndex   = list: zipLists list (range 0 (length list));
        in
                map switchLightSet (zipWithIndex lights);
        allNextForPrev   = lights: map (pressButton lights);
        allNextForPrevs  = buttons: prevs:
                nub (concatMap (flip allNextForPrev buttons) prevs);
        solutionDepth    = machine: with machine; let
                go = prevs: depth: 
                        if elem lights prevs then
                                depth
                        else
                                go (allNextForPrevs buttons prevs) (depth + 1);
        in
                go [ (map (x: ".") lights) ] 0;
        calculateFromMachines = compose [
                (map solutionDepth)
                sum
        ];
        answer                = calculateFromString (readInput ./10.txt);
        calculateFromString   = compose [
                lines
                (map readMachine)
                calculateFromMachines
        ];
} // imports
