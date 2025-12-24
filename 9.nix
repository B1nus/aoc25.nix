with builtins;
with import <nixpkgs/lib>;
with import ./common.nix;
rec {
        comp = compose;
        # I really wish nix had enums.
        # Why the wierd enumeration? Well to be able to differentiate
        # diagonals with addition.
        input = comp [ readInput lines (map readPos) ] ./9.txt;
        testInput = let 
                newPos = x: y: { inherit x y; };
                positions = [
                        (newPos 0 0)
                        (newPos 2 0)
                        (newPos 2 2)
                        (newPos 0 2)
                ];
        in 
                positions;
        dir = rec {
                down = "v"; # Note to self. Symbols are way easier to understand
                            # Than text, maybe that idea isn't so bad for
                            # a programming language.
                up = "^";
                left = "<";
                right = ">";
                sum = d1: d2:
                        if d1 == down || d1 == up then
                                d1 + d2
                        else
                                d2 + d1;
        };
        inherit readInput;
        readPos = s: with halfString "," s;
                {
                        x = toInt left;
                        y = toInt right;
                };
        readPositions = comp [ lines (map readPos) ];
        nextElem = comp [ tail head ];
        changeHead = f: xs: comp [ head f toList ] xs ++ tail xs;
        forward = xs: tail xs ++ comp [ head toList ] xs;
        backward = xs: last xs ++ dropEnd 1 xs;
        attachInAndOutDirections = xs:
                let
                        prev = last xs;
                        this = head xs;
                        next = nextElem xs;
                        dirs = {
                                prev = directionToAdjacentPos prev this;
                                next = directionToAdjacentPos this next;
                        };
                        inside = insideDir dirs.prev dirs.next;
                        f = x:
                                x // dirs // { inherit inside; };
                in
                        if hasAttr "prev" this then
                                xs
                        else
                                       attachInAndOutDirections (forward (changeHead f xs));
        directionToAdjacentPos = this: other: with dir;
                if other.x > this.x then
                        right
                else if other.x < this.x then
                        left
                else if other.y > this.y then
                        down
                else if other.y < this.y then
                        up
                else
                        error "same position lol, bozo";
        insideDir = prev: next:
                let
                        sum = dir.sum prev next;
                in
                        if sum == "v>" then
                        "v<"
                else if sum == "^<" then
                        "^>"
                else if sum == "^>" then
                        "v>"
                else
                        "^<";
        isInDirection = direction: from: to:
                let
                        dx = to.x - from.x;
                        dy = to.y - from.y;
                in
                        any (isInSimpleDirection dx dy) (stringToCharacters direction);
        isInSimpleDirection = dx: dy: d: with dir;
                if d == up then
                        dy <= 0
                else if d == down then
                        dy >= 0
                else if d == left then
                        dx <= 0
                else
                        dx >= 0;
        isInsidePositions = pos1: pos2:
                isInDirection pos1.inside pos1 pos2 
                && isInDirection pos2.inside pos2 pos1;
        lineRects = ps:
                let
                        f = l: let
                                this = head l;
                                other = head (tail l);
                                line = posPairToRect this other;
                        in
                                if length l <= 1 then
                                        []
                                else
                                        toList line ++ f (tail l);
                in
                        f (postpend (head ps) ps);
        inputLines = lineRects input;
                                 # This is fucking retarded. give me an error
                                 # For having two definitions of the same variable
                                 # Like any sane language would. Good fucking dammit
                                 # It's not fucking recursion bitch. fuck you.
        rectangles = positions:
                let
                        this = head positions;
                        rest = tail positions;
                        allPosPairs = map (x: { inherit this; other=x; }) rest;
                        filteredPosPairs = filter (x: with x; isInsidePositions this other) allPosPairs;
                        rects = map (x: with x; posPairToRect this other) filteredPosPairs;
                        filteredRects = filter
                                (rect: !(any (overlapping rect) inputLines))
                                rects; 
                in
                        if length positions <= 1 then [] else filteredRects  ++ rectangles rest;
        rectArea = rect:
                with rect;
                (maxX - minX + 1) * (maxY - minY + 1);
        inherit maximum;
        # so, for each position, go through every other position and try
        # creating a rectangle.
        # concat all these rectangles into one list.
        # Could have made types for this instead. could also have made infix to avoid confusion
        # pos1 isLargerThan pos2 is easy to understand the order. We also avoid writing the type in the name because
        # of static typing.
        # isLargerThan pos1 pos2 is also easy to understand if the types are isLargerThan :: This -> Other -> Bool
        # Where type This, Other = Position
        # firstIsLargerPos = pos1: pos2:
        #         pos1.x + pos1.y > pos2.x + pos2.y;
        # largerPosObj = obj1: obj2:
        #         if firstIsLargerPos obj1 obj2 then obj1 else obj2;
        # cycleToBottomRight = cycle: with cycle; let
        #
        # positionsToTiles = ts:
        #         let
        #                 go = i:
        #                         let
        #                                 prev = elemAt (mod (i - 1) (length ts)) ts;
        #                                 this = elemAt (mod i (length ts)) ts;
        #                                 next = elemAt (mod (i + 1) (length ts)) ts;
        #                         in
        #                                 l;
        #         in
        #                 map (x: go x.fst) (genList (x: x) (length ts));
        # setDir = tile: dir:
        #         tile // { inherit dir; };
        posPairToRect = p1: p2:
                let
                        minX = min p1.x p2.x;
                        minY = min p1.y p2.y;
                        maxX = max p1.x p2.x;
                        maxY = max p1.y p2.y;
                in
                        rect minX minY maxX maxY;
        rect = minX: minY: maxX: maxY:
                { inherit minX minY maxX maxY; };
        overlapping = rect1: rect2:
                let
                        xr1 = range rect1.minX rect1.maxX;
                        yr1 = range rect1.minY rect1.maxY;
                        xr2 = range rect2.minX rect2.maxX;
                        yr2 = range rect2.minY rect2.maxY;
                in
                        rangesOverlapWithAtLeast 1 xr1 xr2
                        && rangesOverlapWithAtLeast 1 yr1 yr2;
        # overlappingWithAny = rect:
        #         any (overlapping rect);
        # bottomRightTileIndex = compose [
        #         (ts: zipLists (genList (x: x) (length ts)) ts)
        #         (sort (a: b: a.snd.x + a.snd.y > b.snd.x + b.snd.y))
        #         head
        #         (x: x.fst)
        # ];
        # reorderForBottomRightTile = ts:
        #         let
        #                 i = bottomRightTileIndex ts;
        #         in
        #                 toList (setDir (elemAt ts i) 0) ++ lists.drop (i + 1) ts ++ lists.take i ts;
        # # WARNING, after reorder only!
        # makeClockwise = ts:
        #         let
        #                 first = head ts;
        #                 second = elemAt ts 1;
        #         in
        #                 if first.x == second.x then reverseList ts else ts;
        # fixOrder = compose [ reorderForBottomRightTile makeClockwise ];
        # # WARNING, after fixOrder only!
        # setDirForAllTiles = i: ts:
        #         if i < length ts then
        #                 let
        #                         prev = elemAt (i - 1) ts;
        #                         cur  = elemAt  i      ts;
        #                         next = elemAt (mod (i + 1) (length ts)) ts;
        #
        #                         dirForCur = dirForNextTile prev cur next;
        #                 in
        #                         setDirForAllTiles (i + 1) (changeList ts i (setDir dirForCur cur) ts)
        #         else
        #                 ts;
        # dirForNextTile = prev: cur: next:
        #         topLeft;
        #         # if prev.dir == topLeft then
        #         #         (if next.y > cur.y /* */ || next.x < cur.x then topLeft else topRight)
        #         # else if prev.dir == topRight then
        #         #         (if prev.x == cur.x /* F J */ then
        #         #                 (if next.x > cur.x then 2 else 1)
        #         #         else
        #         #                 (if next.y > cur.y then 0 else 1))
}
