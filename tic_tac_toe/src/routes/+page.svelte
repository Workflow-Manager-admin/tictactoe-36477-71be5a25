<script>
	// PUBLIC_INTERFACE
	/**
	 * Enhanced Svelte Main Container for TicTacToe.
	 * Adds play-vs-computer with 3 AI levels and properly manages flow and theming.
	 * All UI and modes directly inside this single file.
	 */

	// Board and state
	let board = [
		[null, null, null],
		[null, null, null],
		[null, null, null]
	];

	let currentPlayer = "X";
	let winner = null;
	let draw = false;
	let gameActive = true;

	const winLines = [
		[[0,0],[0,1],[0,2]], [[1,0],[1,1],[1,2]], [[2,0],[2,1],[2,2]],
		[[0,0],[1,0],[2,0]], [[0,1],[1,1],[2,1]], [[0,2],[1,2],[2,2]],
		[[0,0],[1,1],[2,2]], [[0,2],[1,1],[2,0]]
	];

	// Mode and AI settings
	let mode = "2p"; // "2p" or "ai"
	let aiLevel = "easy"; // "easy", "medium", "hard"
	let aiThinking = false;
	let playerSymbol = "X"; // Always X for now; O could be added

	/**
	 * PUBLIC_INTERFACE
	 * Handles user clicking a cell.
	 */
	function handleCellClick(row, col) {
		if (!gameActive || board[row][col] !== null || aiThinking) return;
		if (mode === 'ai' && currentPlayer !== playerSymbol) return;
		board[row][col] = currentPlayer;
		checkGameStatus();
		if (gameActive) {
			currentPlayer = currentPlayer === "X" ? "O" : "X";
			if (mode === "ai") maybeTriggerAIMove();
		}
	}

	/**
	 * PUBLIC_INTERFACE
	 * Checks game for winner or draw.
	 */
	function checkGameStatus() {
		for (const line of winLines) {
			const [a, b, c] = line;
			const v1 = board[a[0]][a[1]];
			const v2 = board[b[0]][b[1]];
			const v3 = board[c[0]][c[1]];
			if (v1 && v1 === v2 && v1 === v3) {
				winner = v1;
				gameActive = false;
				draw = false;
				return;
			}
		}
		const allFilled = board.flat().every(cell => cell);
		if (allFilled) {
			draw = true;
			gameActive = false;
		}
	}

	/**
	 * PUBLIC_INTERFACE
	 * Resets all state.
	 */
	function restartGame() {
		board = [
			[null, null, null],
			[null, null, null],
			[null, null, null]
		];
		currentPlayer = "X";
		winner = null;
		draw = false;
		gameActive = true;
		aiThinking = false;
		// Let AI start if it's O and vs computer
		if (mode === "ai" && playerSymbol !== "X") {
			currentPlayer = "O";
			maybeTriggerAIMove();
		}
	}

	/** 
	 * Called when mode or difficulty changes, also after player's move.
	 */
	function maybeTriggerAIMove() {
		if (mode === "ai" && gameActive && currentPlayer !== playerSymbol && !winner && !draw) {
			aiThinking = true;
			// Simulate AI thinking time for realism
			setTimeout(() => {
				const [row, col] = getBestAIMove(board, aiLevel, currentPlayer);
				if (row != null && col != null && !board[row][col]) {
					board[row][col] = currentPlayer;
					checkGameStatus();
					if (gameActive) {
						currentPlayer = currentPlayer === "X" ? "O" : "X";
					}
				}
				aiThinking = false;
			}, 340); // minor delay for feel
		}
	}

	/**
	 * PUBLIC_INTERFACE
	 * Returns a [row, col] move for given AI level and symbol.
	 */
	function getBestAIMove(currentBoard, level, symbol) {
		// Get array of all free cells: [ [row,col], ... ]
		const freeCells = [];
		for (let i=0; i<3; i++) for (let j=0; j<3; j++)
			if (!currentBoard[i][j]) freeCells.push([i, j]);

		if (level === "easy") {
			// Random move
			if (freeCells.length === 0) return [null, null];
			return freeCells[Math.floor(Math.random() * freeCells.length)];
		}
		if (level === "medium") {
			// Win if possible
			for (const [i, j] of freeCells) {
				const temp = cloneBoard(currentBoard);
				temp[i][j] = symbol;
				if (hasWinner(temp, symbol)) return [i, j];
			}
			// Block opponent's win
			const opp = symbol === "X" ? "O" : "X";
			for (const [i, j] of freeCells) {
				const temp = cloneBoard(currentBoard);
				temp[i][j] = opp;
				if (hasWinner(temp, opp)) return [i, j];
			}
			// Otherwise, random
			return freeCells[Math.floor(Math.random() * freeCells.length)];
		}
		if (level === "hard") {
			// Minimax
			const { move } = minimax(currentBoard, symbol, symbol, 0);
			return move || freeCells[0] || [null,null];
		}
		// Fallback (shouldn't happen)
		return freeCells.length > 0 ? freeCells[0] : [null, null];
	}

	// ------------------------------------
	// Helper AI functions

	/**
	 * Returns true if the player has won on this board.
	 */
	function hasWinner(boardState, player) {
		for (const line of winLines) {
			const [a, b, c] = line;
			if (
				boardState[a[0]][a[1]] === player &&
				boardState[b[0]][b[1]] === player &&
				boardState[c[0]][c[1]] === player
			) {
				return true;
			}
		}
		return false;
	}

	/**
	 * Returns true if full and no winner.
	 */
	function isDraw(boardState) {
		return boardState.flat().every(cell => cell) && 
			!hasWinner(boardState, "X") && !hasWinner(boardState, "O");
	}

	/**
	 * Returns an independent copy of a board.
	 */
	function cloneBoard(boardState) {
		return boardState.map(row => row.slice());
	}

	/**
	 * Minimax algorithm for TicTacToe.
	 * Returns: { score, move }
	 */
	function minimax(boardState, aiPlayer, turn, depth) {
		// Terminal state
		if (hasWinner(boardState, aiPlayer)) return { score: 10 - depth };
		const opp = aiPlayer === "X" ? "O" : "X";
		if (hasWinner(boardState, opp)) return { score: -10 + depth };
		if (isDraw(boardState)) return { score: 0 };

		// Recursion
		const freeCells = [];
		for (let i=0; i<3; i++)
			for (let j=0; j<3; j++)
				if (!boardState[i][j]) freeCells.push([i,j]);
		const moves = [];
		for (const [i, j] of freeCells) {
			const tmp = cloneBoard(boardState);
			tmp[i][j] = turn;
			const result = minimax(tmp, aiPlayer, turn === "X" ? "O" : "X", depth + 1);
			moves.push({
				score: result.score,
				move: [i, j]
			});
		}

		// Pick best for AI, worst for opp
		if (turn === aiPlayer) {
			// Maximize
			let max = -Infinity, chosen = null;
			for (const m of moves) {
				if (m.score > max) {
					max = m.score;
					chosen = m.move;
				}
			}
			return { score: max, move: chosen };
		} else {
			// Minimize
			let min = +Infinity, chosen = null;
			for (const m of moves) {
				if (m.score < min) {
					min = m.score;
					chosen = m.move;
				}
			}
			return { score: min, move: chosen };
		}
	}

	// -------------------------------------------------------
	// All UI control changes handled in control panel below

	// When switching to 2p or AI mode, restart cleanly
	function handleModeChange(newMode) {
		mode = newMode;
		restartGame();
	}

	function handleAIDifficultyChange(newLevel) {
		aiLevel = newLevel;
		restartGame();
	}

</script>

<style>
	:root {
		--primary: #ffffff;
		--secondary: #000000;
		--accent: #2196f3;
	}

	:global(body) {
		margin: 0;
		padding: 0;
		background: var(--primary);
		color: var(--secondary);
		font-family: system-ui, sans-serif;
	}
	.app-container {
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		min-height: 100vh;
		background: var(--primary);
	}
	.tictactoe-title {
		color: var(--accent);
		letter-spacing: 2px;
		font-weight: 700;
		margin-bottom: 1rem;
		margin-top: 0;
	}
	.board {
		display: grid;
		grid-template-columns: repeat(3, 70px);
		grid-template-rows: repeat(3, 70px);
		gap: 10px;
		background: #00000010;
		padding: 18px 18px 8px 18px;
		border-radius: 18px;
		box-shadow: 0 4px 18px #00000018;
		margin-bottom: 1.5rem;
	}
	.cell {
		width: 70px;
		height: 70px;
		display: flex;
		align-items: center;
		justify-content: center;
		font-size: 2.5rem;
		font-weight: 600;
		background: var(--primary);
		border: 2px solid var(--accent);
		border-radius: 8px;
		cursor: pointer;
		color: var(--secondary);
		transition: background 0.12s, border-color 0.15s;
		user-select: none;
	}
	.cell:disabled, .cell.disabled {
		cursor: default;
		background: #eeeeee;
		color: #888888;
	}
	.control-panel {
		margin-top: 0.75rem;
		display: flex;
		flex-direction: column;
		align-items: center;
		gap: 0.6rem;
	}
	.status {
		font-size: 1.2rem;
		font-weight: 500;
		color: var(--secondary);
		margin-bottom: 0.25rem;
	}
	.restart-btn {
		background: var(--accent);
		color: #fff;
		border: none;
		border-radius: 5px;
		padding: 0.5em 1.6em;
		font-size: 1.05rem;
		font-weight: 600;
		cursor: pointer;
		margin-top: 0.2em;
		box-shadow: 0 2px 6px #0002;
		letter-spacing: 1px;
		transition: background 0.15s, color 0.13s;
	}
	.restart-btn:hover {
		background: #1762a6;
	}
	.mode-group, .difficulty-group {
		display: flex;
		align-items: center;
		gap: 1em;
		margin-bottom: 0.3em;
	}
	.mode-btn, .difficulty-btn {
		font-size: 1rem;
		border: 2px solid var(--accent);
		background: #fff;
		color: var(--secondary);
		border-radius: 18px;
		cursor: pointer;
		padding: 0.33em 1.1em;
		font-weight: 600;
		margin-left: 0.15em;
	}
	.mode-btn.selected, .difficulty-btn.selected {
		background: var(--accent);
		color: #fff;
		border: 2px solid var(--accent);
	}
	.mode-btn:not(.selected):hover,
	.difficulty-btn:not(.selected):hover {
		background: #f9f9ff;
		color: var(--accent);
	}
	.ai-think {
		color: var(--accent);
		font-style: italic;
		font-size: 1.03rem;
		margin-top: 0.1em;
	}
</style>

<div class="app-container">
	<h1 class="tictactoe-title">TicTacToe</h1>
	<div class="board">
		{#each board as row, i (i)}
			{#each row as cell, j (j)}
				<button
					class="cell {cell || !gameActive ? 'disabled' : ''}"
					on:click={() => handleCellClick(i, j)}
					disabled={!!cell || !gameActive || (mode === 'ai' && currentPlayer !== playerSymbol) || aiThinking}
					aria-label="Cell {i+1}, {j+1}">
					{cell}
				</button>
			{/each}
		{/each}
	</div>
	<div class="control-panel">
		<div class="mode-group" aria-label="Game mode">
			<span>Mode:</span>
			<button class="mode-btn {mode == '2p' ? 'selected' : ''}" on:click={() => handleModeChange('2p')}>2-Player</button>
			<button class="mode-btn {mode == 'ai' ? 'selected' : ''}" on:click={() => handleModeChange('ai')}>Vs Computer</button>
		</div>
		{#if mode === "ai"}
			<div class="difficulty-group" aria-label="AI difficulty">
				<span>AI:</span>
				<button class="difficulty-btn {aiLevel == 'easy' ? 'selected' : ''}" on:click={() => handleAIDifficultyChange('easy')}>Easy</button>
				<button class="difficulty-btn {aiLevel == 'medium' ? 'selected' : ''}" on:click={() => handleAIDifficultyChange('medium')}>Medium</button>
				<button class="difficulty-btn {aiLevel == 'hard' ? 'selected' : ''}" on:click={() => handleAIDifficultyChange('hard')}>Hard</button>
			</div>
		{/if}
		<div class="status">
			{#if winner}
				<span style="color: var(--accent); font-weight: 700;">{winner}</span> wins!
			{:else if draw}
				It's a <span style="font-weight: 700;">draw!</span>
			{:else}
				{#if mode === "ai"}
					{#if aiThinking && currentPlayer !== playerSymbol}
						<span class="ai-think">Computer is thinking...</span>
					{:else}
						{#if currentPlayer === playerSymbol}
							Your turn (<span style="color: var(--accent); font-weight: 700;">{playerSymbol}</span>)
						{:else}
							Computer's turn (<span style="color: var(--accent); font-weight: 700;">{currentPlayer}</span>)
						{/if}
					{/if}
				{:else}
					Current turn: <span style="color: var(--accent); font-weight: 700;">{currentPlayer}</span>
				{/if}
			{/if}
		</div>
		<button class="restart-btn" type="button" on:click={restartGame}>Restart Game</button>
	</div>
</div>
