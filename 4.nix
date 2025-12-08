with import ./common.nix;
with import <nixpkgs/lib>;
with builtins;
with strings;
rec {
        grid = stringToGrid (readInput ./4.txt);
        stringToGrid = s:
                let
                        content = map stringToCharacters (lines s);
                        height = length content;
                        width = length (head content);
                in
                        { inherit content width height; };
        cellAtPos = grid: pos: elemAt (elemAt grid.content pos.row) pos.col;
        changeGrid = grid: pos: value:
                let
                        row  = elemAt grid.content pos.row;
                        row' = changeList row pos.col value;
                in
                        changeList grid.content pos.row row';
        adjacentPosList = grid: pos:
                let
                        posList = posRange
                                (pos.row - 1)
                                (pos.row + 1)
                                (pos.col - 1)
                                (pos.col + 1);
                        inBounds = pos':
                                pos'.row >= 0 &&
                                pos'.row < grid.height &&
                                pos'.col >= 0 &&
                                pos'.col < grid.width;
                        predicate = pos':
                                inBounds pos' &&
                                inBounds pos &&
                                pos' != pos;
                in
                        filter predicate posList;
        adjacentCells = grid: pos:
                map (cellAtPos grid) (adjacentPosList grid pos);
        adjacentRolls = grid: pos:
                count (cell: cell == "@") (adjacentCells grid pos);
        posIsRoll = grid: pos:
                isRoll (cellAtPos grid pos);
        isRoll = cell: cell == "@";
        posRange = startRow: endRow: startCol: endCol:
                let
                        colIds = lists.range startCol endCol;
                        rowIds = lists.range startRow endRow;
                        col = colId: map (rowId: { col=colId; row=rowId; }) rowIds;
                        raw = map col colIds;
                in
                        lists.concatMap (x: x) raw;
        entirePosList = grid: posRange 0 (grid.height - 1) 0 (grid.width - 1);
        accessable = grid:
                let
                        predicate = pos:
                                posIsRoll grid pos &&
                                adjacentRolls grid pos < 4;
                in
                        count predicate (entirePosList grid);
}
