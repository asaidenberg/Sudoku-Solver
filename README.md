# Sudoku-Solver
This project implements a **Sudoku Solver** in **MIPS Assembly**, designed to iteratively apply logical elimination rules to solve a 9x9 Sudoku board. The solver eliminates numbers from rows, columns, and 3x3 boxes until the board is fully solved.

## Features
- **`num_candidates`** – Counts the number of possible digits in a given cell.
- **`rule_out_of_cell`** – Eliminates a specific digit from a cell.
- **`count_solved_cells`** – Counts the number of fully solved cells on the board.
- **`solve_board`** – Iterates through the board, applying elimination rules until all 81 cells are solved.
- **`print_board`** – Displays the Sudoku board in ASCII format.

## Sudoku Representation
Each **cell** is a **10-byte null-terminated string**, listing possible numbers.  
- Example of an unsolved cell: `"123456789"`
- After eliminating `3`: `"12.456789"`
- A solved cell (e.g., `5`): `"....5...."`

The **9x9 board** consists of **81 cells (810 bytes total)** stored in **row-major order**.

## How to Run
1. Open `sudoku.s` in **MARS**.
2. Assemble the program.
3. Run the program to see the Sudoku board being solved.

## Notes
- The solver applies **constraint propagation** but does not use backtracking.
- The board is modified **in place** to store the final solution.
