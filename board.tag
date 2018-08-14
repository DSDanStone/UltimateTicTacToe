<board>
    <table>
        <tr>
            <td class="small-cell" id="{opts.bid}0"></td>
            <td class="small-cell" id="{opts.bid}1"></td>
            <td class="small-cell" id="{opts.bid}2"></td>
        </tr>
        <tr>
            <td class="small-cell" id="{opts.bid}3"></td>
            <td class="small-cell" id="{opts.bid}4"></td>
            <td class="small-cell" id="{opts.bid}5"></td>
        </tr>
        <tr>
            <td class="small-cell" id="{opts.bid}6"></td>
            <td class="small-cell" id="{opts.bid}7"></td>
            <td class="small-cell" id="{opts.bid}8"></td>
        </tr>
    </table>

    <style>
        td.small-cell {
            border: 2px solid black;
            height: 45px;
            width: 45px;
            text-align: center;
            vertical-align: middle;
            font-size: 32px;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            cursor: pointer;
        }

        table {
            border-collapse: collapse;
            position: relative;
            left: 2px;
        }
    </style>

    <script>
        let board;
        const player1 = 'X';
        const player2 = 'O';
        let currentPlayer = player1;
        let cells;
        let previousMoveWonBoard = true;
        let previousSlotPlayed;
        const winCombos = [
            [0, 1, 2],
            [3, 4, 5],
            [6, 7, 8],
            [0, 3, 6],
            [1, 4, 7],
            [2, 5, 8],
            [0, 4, 8],
            [2, 4, 6],
        ];

        this.on('mount', () => {
            cells = this.root.querySelectorAll('.small-cell');
            startGame();
        })

        opts.bus.on('end-turn', (data) => {
            currentPlayer = data.currentPlayer;
            previousMoveWonBoard = data.boardWon;
            previousSlotPlayed = data.slotPlayed;
        });

        opts.bus.on('reset-game', () => {
            startGame();
        });

        function startGame() {
            board = Array.from(Array(9).keys());
            for (let i = 0; i < cells.length; i++) {
                cells[i].innerText = '';
                cells[i].style.removeProperty('background-color');
                cells[i].addEventListener('click', turnClick);
            }
            document.querySelector("#current-turn").innerText = currentPlayer;
        }

        function turnClick(square) {
            if (typeof board[square.target.id[1]] == 'number' && document.getElementById(`${cells[0].id[0]}`).classList.contains("active-board")) {
                turn(square.target.id);
            }
        }

        function turn(squareId) {
            board[squareId[1]] = currentPlayer;
            document.getElementById(squareId).innerText = currentPlayer;
            const gameWon = checkWin();
            let bigGameWon;
            if (gameWon) {
                boardWon(gameWon);
                bigGameWon = checkBigWin();
            }
            else {
                checkBoardTie();
            }

            if (bigGameWon) {
                gameOver(bigGameWon);
            }
            else if (!checkBigTie()) {
                currentPlayer = (currentPlayer === player1) ? player2 : player1;
                document.querySelector("#current-turn").innerText = currentPlayer;

                const turnData = {
                    boardWon: (gameWon != null),
                    slotPlayed: squareId[1],
                    currentPlayer: currentPlayer
                };
                updateBoards(turnData);
                opts.bus.trigger('end-turn', turnData);
            }
        }

        function checkWin() {
            let plays = board.reduce((accumulator, element, i) =>
                (element === currentPlayer) ? accumulator.concat(i) : accumulator, []);
            let gameWon = null;
            for (let [index, win] of winCombos.entries()) {
                if (win.every(element => plays.indexOf(element) > -1)) {
                    gameWon = { index, currentPlayer };
                    break;
                }
            }
            return gameWon;
        }

        function boardWon(gameWon) {
            for (let i = 0; i < cells.length; i++) {
                let cell = document.getElementById(cells[0].id[0] + i);
                if (winCombos[gameWon.index].includes(i)) {
                    cell.style.backgroundColor =
                        (gameWon.currentPlayer == player1) ? "blue" : "red";
                    //cell.classList.add("win-slot")
                }
                else {
                    cell.style.backgroundColor =
                        gameWon.currentPlayer == player1 ? "lightblue" : "lightcoral";
                }
                //cells[i].removeEventListener('click', turnClick);
            }

            let cell = document.getElementById(cells[0].id[0]);
            cell.classList.add("board-done");
            cell.classList.add(currentPlayer);
            cell.style.backgroundColor =
                (gameWon.currentPlayer == player1) ? "lightblue" : "lightcoral";
            /*cell.innerHTML = currentPlayer;  */

            checkBigWin();
        }

        function checkBoardTie() {
            if (board.filter(element => typeof element == 'number').length == 0) {
                for (let i = 0; i < cells.length; i++) {
                    cells[i].removeEventListener('click', turnClick);
                }
                let bigCell = document.getElementById(cells[0].id[0]);
                bigCell.style.backgroundColor = "lightgreen";
                bigCell.classList.add("board-done");
            }
        }

        function updateBoards(data) {
            const bigCells = document.querySelectorAll(".big-cell");
            for (let i = 0; i < bigCells.length; i++) {
                bigCells[i].classList.remove("active-board");
            }
            const targetBoard = document.getElementById(data.slotPlayed);
            if (targetBoard.classList.contains("board-done")) {
                for (let i = 0; i < bigCells.length; i++) {
                    if (!bigCells[i].classList.contains("board-done")) {
                        bigCells[i].classList.add("active-board");
                    }
                }
            }
            else {
                targetBoard.classList.add("active-board");
            }
        }

        function checkBigWin() {
            let bigCells = document.querySelectorAll(".big-cell");
            let plays = [];
            for (let i = 0; i < bigCells.length; i++) {
                if (bigCells[i].classList.contains(currentPlayer)) {
                    plays.push(i);
                }
            }
            let gameWon = null;
            for (let [index, win] of winCombos.entries()) {
                if (win.every(element => plays.indexOf(element) > -1)) {
                    gameWon = { index, currentPlayer };
                    break;
                }
            }
            return gameWon;
        }

        function gameOver(gameWon) {
            let bigCells = document.querySelectorAll(".big-cell");
            for (let i = 0; i < bigCells.length; i++) {
                let cell = document.getElementById(i);
                cell.classList.remove("active-board");
                cell.style.cursor = "default";
                if (winCombos[gameWon.index].includes(i)) {
                    cell.style.backgroundColor =
                        (gameWon.currentPlayer == player1) ? "blue" : "red";
                }
                if (!cell.classList.contains("board-done")) {
                    cell.style.backgroundColor = "white";
                }
            }
            const winBox = document.querySelector('#endgame');
            winBox.innerText = gameWon.currentPlayer + " WINS!!!";
            winBox.style.backgroundColor = (gameWon.currentPlayer == player1)
                ? "rgba(173, 216, 230, .7)" : "rgba(240, 128, 128, .7)";
            winBox.style.color = (gameWon.currentPlayer == player1) ? "darkblue" : "darkred";
            winBox.style.display = "initial";
        }

        function checkBigTie() {
            let bigCells = document.querySelectorAll(".big-cell");
            if (Array.from(bigCells).filter(element => !element.classList.contains("board-done")).length == 0) {
                const winBox = document.querySelector('#endgame');
                winBox.innerText = "It's a Tie!";
                winBox.style.backgroundColor = "rgba(144, 238, 144, .7)"
                winBox.style.color = "darkgreen";
                winBox.style.display = "initial";
                return true;
            }
            return false;
        }
    </script>
</board>