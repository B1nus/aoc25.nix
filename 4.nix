with import ./common.nix;
with import <nixpkgs/lib>;
with builtins;
with strings;
rec {
        grid = compose [ readInput read2dString newGrid ] ./4.txt;
        cellAtPos = grid: pos:
                elemAt (elemAt grid.content pos.row) pos.col;
        changeGrid = grid: pos: value:
                newGrid (change2dList grid.content pos.row pos.col value);
        showGrid = grid:
                map concatStrings grid.content;
        adjacentPosList = grid: pos:
                let
                        posList = posRange
                                (pos.row - 1)
                                (pos.row + 1)
                                (pos.col - 1)
                                (pos.col + 1);
                        inBounds = isInGridBounds grid;
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
                        rowIds = if endRow - startRow > 3 && endRow - startRow < 100 then lists.range (startRow + 1) (endRow - 1) else lists.range startRow endRow;
                        col = colId: map (rowId: { col=colId; row=rowId; }) rowIds;
                        raw = map col colIds;
                in
                        lists.concatMap (x: x) raw;
        entirePosList = grid: posRange 0 (grid.height - 1) 0 (grid.width - 1);
        accessablePosList = grid:
                let
                        predicate = pos:
                                posIsRoll grid pos &&
                                adjacentRolls grid pos < 4;
                in
                        filter predicate (entirePosList grid);
        removeRolls = grid: posList:
                if posList == [] then
                        grid
                else
                        let
                                newGrid = changeGrid grid (head posList) ".";
                        in
                                removeRolls newGrid (tail posList);
        step = grid:
                let 
                        accessableRollsPos = accessablePosList grid;
                        newGrid = removeRolls grid accessableRollsPos;
                        rolls = length accessableRollsPos;
                in 
                        { inherit rolls; newGrid = newGrid; };
        stepPartitioned = grid:
                let
                        first = partitionGrid grid 0 69;
                        second = partitionGrid grid 70 137;
                        first' = step first;
                        second' = step second;
                        residual' = step (concatGridPartitions first'.newGrid second'.newGrid);
                in
                        {
                                rolls = first'.rolls + second'.rolls + residual'.rolls;
                                newGrid = residual'.newGrid;
                        };
        concatGridPartitions = partition1: partition2:
                rec {
                        content = partition1.content ++ partition2.content;
                        width = partition1.width;
                        height = partition1.height + partition2.height;
                };
        partitionGrid = grid: startRow: endRow:
                rec {
                        content = lists.sublist
                                startRow
                                height
                                grid.content;
                        width = grid.width;
                        height = 1 + endRow - startRow;
                };
        allRolls = grid:
                let
                        next = step grid;
                in
                        if next.rolls == 0 then
                                0
                        else
                                next.rolls + allRolls next.newGrid;
        allRollsPartitioned = grid:
                let
                        next = stepPartitioned grid;
                in
                        if next.rolls == 0 then
                                0
                        else
                                next.rolls + allRollsPartitioned next.newGrid;
}
