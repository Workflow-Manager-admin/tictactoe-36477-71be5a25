<script>
	// PUBLIC_INTERFACE
	/**
	 * Svelte Main Container for TicTacToe game.
	 * Implements a 3x3 board, local two-player, win/draw detection, restart functionality, and a light, center-aligned layout.
	 */

	// Theme colors as variables for maintainability
	const primary = "#ffffff";
	const secondary = "#000000";
	const accent = "#2196f3";

	// Represents the board state (3x3 grid, initialized to nulls)
	let board = [
		[null, null, null],
		[null, null, null],
		[null, null, null]
	];

	let currentPlayer = "X";
	let winner = null;         // "X", "O" or null
	let draw = false;          // Track if the game is a draw
	let gameActive = true;     // Track if moves are allowed

	// Winning line combinations (row/column/diagonal indices)
	const winLines = [
		// Rows
		[[0,0],[0,1],[0,2]],
		[[1,0],[1,1],[1,2]],
		[[2,0],[2,1],[2,2]],
		// Columns
		[[0,0],[1,0],[2,0]],
		[[0,1],[1,1],[2,1]],
		[[0,2],[1,2],[2,2]],
		// Diagonals
		[[0,0],[1,1],[2,2]],
		[[0,2],[1,1],[2,0]]
	];

	// PUBLIC_INTERFACE
	function handleCellClick(row, col) {
		if (!gameActive || board[row][col] !== null) {
			return;
		}
		board[row][col] = currentPlayer;
		checkGameStatus();
		if (gameActive) {
			currentPlayer = currentPlayer === "X" ? "O" : "X";
		}
	}

	// PUBLIC_INTERFACE
	function checkGameStatus() {
		// Check for win
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
		// Check for draw: if all cells are filled and no winner
		const allFilled = board.flat().every(cell => cell);
		if (allFilled) {
			draw = true;
			gameActive = false;
		}
	}

	// PUBLIC_INTERFACE
	function restartGame() {
		board = [
			[null, null, null],
			[null, null, null]
		];
		currentPlayer = "X";
		winner = null;
		draw = false;
		gameActive = true;
	}
</script>

<style>
	:global(body) {
		margin: 0;
		padding: 0;
		background: {primary};
		color: {secondary};
		font-family: system-ui, sans-serif;
	}
	.app-container {
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		min-height: 100vh;
		background: {primary};
	}
	.tictactoe-title {
		color: {accent};
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
		background: {secondary}10;
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
		background: {primary};
		border: 2px solid {accent};
		border-radius: 8px;
		cursor: pointer;
		color: {secondary};
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
		color: {secondary};
		margin-bottom: 0.25rem;
	}

	.restart-btn {
		background: {accent};
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
</style>

<div class="app-container">
	<h1 class="tictactoe-title">TicTacToe</h1>
	<div class="board">
		{#each board as row, i}
			{#each row as cell, j}
				<button
					class="cell {cell || !gameActive ? 'disabled' : ''}"
					on:click={() => handleCellClick(i, j)}
					disabled={!!cell || !gameActive}
					aria-label="Cell {i+1}, {j+1}">
					{cell}
				</button>
			{/each}
		{/each}
	</div>
	<div class="control-panel">
		<div class="status">
			{#if winner}
				<span style="color: {accent}; font-weight: 700;">{winner}</span> wins!
			{:else if draw}
				It's a <span style="font-weight: 700;">draw!</span>
			{:else}
				Current turn: <span style="color: {accent}; font-weight: 700;">{currentPlayer}</span>
			{/if}
		</div>
		<button class="restart-btn" type="button" on:click={restartGame}>Restart Game</button>
	</div>
</div>
