with builtins; with import <nixpkgs/lib>; with import ./common.nix;
let 
        input = readInput ./1.txt;
        items = map parseRotation (lines input);
        parseRotation = s:
                toInt (strings.substring 1 (stringLength s - 1) s) * (if strings.substring 0 1 s == "R" then
                        1
                else
                        -1);
        allPoints = l:
                let
                        go = l: p:
                                if l == [] then
                                        0
                                else
                                        with do p (head l);
                                        points + go (tail l) newPos;
                in
                        go l 50; # Fuck me. That's one hour of sleep I won't get back.
        do = pos: rot:
                rec {
                        pos2 = pos + rot;
                        points = if pos2 >= 0 then
                                div pos2 100 + boolToInt (newPos == 0 && rot < 0)
                        else
                                div (100 - pos2) 100 - boolToInt (pos == 0);
                        newPos = mod pos2 100;
                };
        p = pos: rot: newPos': points': with do pos rot; points == points' && newPos' == newPos;
in
        assert p 0 1 1 0;
        assert p 0 (-1) 99 0;
        assert p 99 200 99 2;
        assert p 0 (-200) 0 2;
        assert p 1 (-1) 0 1;
        assert p 0 100 0 1;
        assert p 49 (-149) 0 2;
        assert p 1 (-100) 1 1;
        assert p 0 1 1 0;
        assert p 0 (-1) 99 0;
        assert p 99 200 99 2;
        assert p 0 (-200) 0 2;
        assert p 1 (-1) 0 1;
        assert p 0 100 0 1;
        assert p 49 (-549) 0 6;
        assert p 1 (-199) 2 2;
        allPoints items
