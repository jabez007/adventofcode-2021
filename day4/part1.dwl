%dw 2.0

fun getNumbersAndBoards(text: Array<String>): Array<Array<String>> = do {
    var split = text dw::core::Arrays::splitWhere $ == ""
    ---
    if (isEmpty(split.l))
        [split.r]
    else
        [split.l] ++ getNumbersAndBoards(split.r dw::core::Arrays::drop 1) 
}

var numbersAndBoards = getNumbersAndBoards(payload splitBy "\n")

var drawNumbers = (numbersAndBoards[0][0] splitBy ",") map $ as Number

type Board = {
    rows: Array<Array<Number>>,
    columns: Array<Array<Number>>
}

var boards: Array<Board> = (numbersAndBoards dw::core::Arrays::drop 1) map (board) -> do {
    var rows = board map (r) -> r splitBy " " filter $ != "" map $ as Number
    ---
    {
        rows: rows,
        columns: rows map (r1, index1) -> rows map (r2, index2) -> rows[index2][index1]
    }
}

fun markBoard(board: Board, called: Number): Board =
    board update {
        case .rows -> $ map (r) -> r -- [called]
        case .columns -> $ map (c) -> c -- [called]
    }

fun checkBoard(board: Board): Boolean =
    (board.rows ++ board.columns) dw::core::Arrays::some isEmpty($)

fun playBingo(boards: Array<Board>, drawNumbers: Array<Number>): Number =
    if (isEmpty(drawNumbers))
        0
    else do {
        var calledNumber = drawNumbers[0]
        var markedBoards = boards map markBoard($, calledNumber)
        var wonBoard = markedBoards dw::core::Arrays::firstWith checkBoard($)
        ---
        if (wonBoard != null)
            calledNumber * sum(flatten(wonBoard.rows))
        else
            playBingo(markedBoards, drawNumbers dw::core::Arrays::drop 1)
    }

output application/json
---
playBingo(boards, drawNumbers)
