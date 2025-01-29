# a0: pointer to cell
# v0: number of viable candidates in the cell
num_candidates:
	li $t0, 0 			# candidate counter
	
num_candidates_loop:
	lb $t1, 0($a0)		# load byte from a0 into t2
	beqz $t1, num_candidates_end		# null terminator => end loop

	beq $t1, 46, num_candidates_next 	# branch if the current byte is '.'		
	addi $t0, $t0, 1 	# increment candidate counter

	num_candidates_next: 
	addi $a0, $a0, 1	# move to the next char
	j num_candidates_loop

num_candidates_end:
	move $v0, $t0		# move the counter into v0 to be returned
	jr $ra				# return 

#### Do not move this separator. Place all of your num_candidates code above this line. ####

# a0: pointer to cell
# a1: candidate to eliminate from cell 
rule_out_of_cell:
	add $t0, $a0, $a1	
	
	li $t1, '.'
	sb $t1, -1($t0)
	
	jr $ra

#### Do not move this separator. Place all of your rule_out_of_cell code above this line, and below previous separator. ###

# a0: pointer to board
# v0: number of solved cells
count_solved_cells:	
	# allocate onto stack a0, next moves a0 by 10, check if a0 greater than 810 to end, 
	li $v0, 0

	addi $sp, $sp, -12  # malloc on the stack
	sw $ra, 0($sp)		# add what is needed to stack memory
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	li $s0, 0	        # loop counter		
	li $s1, 0			# solved counter 

count_solved_cells_loop:
	li $t0, 81
	bge $s0, $t0, count_solved_cells_end 		# terminating condition

	addi $sp, $sp, -4 							# adjust memory
	sw $a0, 0($sp)
	
	jal is_cell_solved					
	beq $v0, $zero, count_solved_cells_next		# if not solved, branch to next

	lw $a0, 0($sp)								# re-adjust memory
	addi $sp, $sp, 4

	addi $a0, $a0, 10							# next cell
	addi $s0, $s0, 1							# loop counter increments
	addi $s1, $s1, 1							# solved counter increments

	j count_solved_cells_loop

count_solved_cells_next: 					# prepare for next loop iteration after jumping here
	lw $a0, 0($sp)
	addi $sp, $sp, 4
	addi $a0, $a0, 10
	addi $s0, $s0, 1
	j count_solved_cells_loop

count_solved_cells_end:							# tidy up memory and return
	move $v0, $s1
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	addi $sp, $sp, 12
	
	jr $ra

#### Do not move this separator. Place all of your count_solved_cells code above this line, and below previous separator. ###
	
# a0: pointer to board
solve_board:
	addi $sp, $sp, -16
	sw $ra, 0($sp)
	sw $s0, 4($sp)								
	sw $s1, 8($sp)
	sw $s2, 12($sp) 							# total cells counter

	li $s2, 0									# initialize counter to be zero
	move $s0, $a0								# store OG a0 in s0

outer_loop:
	move $s1, $a0
	jal count_solved_cells						# if all cells are solved, go to end
	li $t0, 81
	move $a0, $s1
	beq $v0, $t0, solve_board_end
	j inner_loop								# otherwise jump to inner loop

inner_loop:
	li $t1, 81
	beq $s2, $t1, reset_board					# if cell counter is 81, go to reset_board

	move $s1, $a0
	jal is_cell_solved
	move $a0, $s1
	beq $v0, $zero, solve_board_next			# if cell is not solved, go to next cell

												# run through all of the rule outs, making sure to rearrange a0,a1,s0,s1 as needed
	move $a1, $a0
	move $s1, $a0
	move $a0, $s0
	jal rule_out_of_row							
	move $a0, $s1

	move $a1, $a0
	move $s1, $a0
	move $a0, $s0
	jal rule_out_of_col
	move $a0, $s1

	move $a1, $a0
	move $s1, $a0
	move $a0, $s0
	jal rule_out_of_box
	move $a0, $s1

	j solve_board_next								# advance to the next cell

solve_board_next:
	addi $a0, $a0, 10							# next cell
	addi $s2, $s2, 1							# increment cell counter
	j inner_loop								# run back the inner loop

reset_board:
	addi $a0, $a0, -810							# reset a0 to beginning of board
	li $s2, 0									# reset cell counter to 0
	j outer_loop								# jump back to outerloop to reiterate over board

solve_board_end:								# clean up stack memory and return 
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)

	addi $sp, $sp, 16
	
	jr $ra

#### Do not move this separator. 
main:
	addi $sp, $sp, -8
	sw $ra, 0($sp)
	sw $s0, 4($sp)

	##
	## Testing num_candidates
	##

	la $a0, num_candidates_test_msg
	jal print_string
	jal print_newline
	jal print_newline

	## should print:
	## 123456789
	## 9
	la $a0, testcell1
	jal num_candidates
	move $s0, $v0
	la $a0, testcell1
	jal print_string
	jal print_newline
	move $a0, $s0
	jal print_int
	jal print_newline
	jal print_newline

	## should print:
	## 1.34.6789
	## 7
	la $a0, testcell2
	jal num_candidates
	move $s0, $v0
	la $a0, testcell2
	jal print_string
	jal print_newline
	move $a0, $s0
	jal print_int
	jal print_newline
	jal print_newline

	## should print:
	## .2.4.6.8.
	## 4
	la $a0, testcell3
	jal num_candidates
	move $s0, $v0
	la $a0, testcell3
	jal print_string
	jal print_newline
	move $a0, $s0
	jal print_int
	jal print_newline
	jal print_newline

	## should print:
	## .....67..
	## 2
	la $a0, testcell4
	jal num_candidates
	move $s0, $v0
	la $a0, testcell4
	jal print_string
	jal print_newline
	move $a0, $s0
	jal print_int
	jal print_newline
	jal print_newline

	## should print:
	## .........
	## 0
	la $a0, testcell5
	jal num_candidates
	move $s0, $v0
	la $a0, testcell5
	jal print_string
	jal print_newline
	move $a0, $s0
	jal print_int
	jal print_newline
	jal print_newline
	
	##
	## Testing rule_out_of_cell
	##

	la $a0, rule_out_of_cell_test_msg
	jal print_string
	jal print_newline
	jal print_newline

	## should print:
	## 123456789
	## 12345678.
	la $a0, testcell1
	jal print_string
	jal print_newline
	la $a0, testcell1
	li $a1, 9
	jal rule_out_of_cell
	la $a0, testcell1
	jal print_string
	jal print_newline
	jal print_newline

	## should print:
	## 1.34.6789
	## 1.34.6789
	la $a0, testcell2
	jal print_string
	jal print_newline
	la $a0, testcell2
	li $a1, 5
	jal rule_out_of_cell
	la $a0, testcell2
	jal print_string
	jal print_newline
	jal print_newline

	## should print:
	## .2.4.6.8.
	## .2.4.6...
	la $a0, testcell3
	jal print_string
	jal print_newline
	la $a0, testcell3
	li $a1, 8
	jal rule_out_of_cell
	la $a0, testcell3
	jal print_string
	jal print_newline
	jal print_newline

	## should print:
	## .....67..
	## ......7..
	la $a0, testcell4
	jal print_string
	jal print_newline
	la $a0, testcell4
	li $a1, 6
	jal rule_out_of_cell
	la $a0, testcell4
	jal print_string
	jal print_newline
	jal print_newline

	## should print:
	## .........
	## .........
	la $a0, testcell5
	jal print_string
	jal print_newline
	la $a0, testcell5
	li $a1, 1
	jal rule_out_of_cell
	la $a0, testcell5
	jal print_string
	jal print_newline
	jal print_newline
	

	##
	## Testing count_solved_cells
	##

	la $a0, count_solved_cells_test_msg
	jal print_string
	jal print_newline
	jal print_newline

	## should print:
	##  ----------------------------------------------------------------------------------------------- 
	## | 123456789 .......8. 123456789 | ....5.... .....6... 123456789 | 123456789 ...4..... 123456789 |
	## | 123456789 ....5.... ..3...... | 123456789 123456789 .2....... | 123456789 ........9 123456789 |
	## | .2....... ......7.. 123456789 | .......8. 1........ 123456789 | 123456789 ..3...... .....6... |
	##  ----------------------------------------------------------------------------------------------- 
	## | ...4..... 123456789 123456789 | 123456789 123456789 123456789 | ......7.. .2....... ....5.... |
	## | .......8. ..3...... .....6... | 123456789 123456789 123456789 | 123456789 123456789 123456789 |
	## | 123456789 123456789 ......7.. | 1........ ........9 ...4..... | 123456789 123456789 123456789 |
	##  ----------------------------------------------------------------------------------------------- 
	## | 123456789 123456789 ....5.... | 123456789 .2....... ......7.. | 1........ 123456789 .......8. |
	## | 1........ ........9 123456789 | .....6... 123456789 .......8. | 123456789 123456789 ...4..... |
	## | 123456789 .....6... 123456789 | ...4..... ..3...... 123456789 | 123456789 ....5.... .2....... |
	##  ----------------------------------------------------------------------------------------------- 
	## 40

	la $a0, easyboard1
	jal count_solved_cells
	move $s0, $v0
	la $a0, easyboard1
	jal print_board
	move $a0, $s0
	jal print_int
	jal print_newline
	jal print_newline

	## should print:
	##  ----------------------------------------------------------------------------------------------- 
	## | 123456789 1........ 123456789 | .2....... .....6... ........9 | 123456789 ...4..... 123456789 |
	## | 123456789 ........9 123456789 | 123456789 .......8. ..3...... | 1........ 123456789 ......7.. |
	## | 123456789 ....5.... ..3...... | 123456789 123456789 ...4..... | 123456789 .......8. .....6... |
	##  ----------------------------------------------------------------------------------------------- 
	## | 123456789 123456789 123456789 | .....6... .2....... .......8. | ......7.. 1........ 123456789 |
	## | 1........ .....6... .......8. | 123456789 123456789 123456789 | 123456789 ........9 .2....... |
	## | ....5.... ......7.. 123456789 | ........9 123456789 1........ | 123456789 123456789 .......8. |
	##  ----------------------------------------------------------------------------------------------- 
	## | .....6... 123456789 ........9 | ...4..... ..3...... 123456789 | .......8. 123456789 123456789 |
	## | 123456789 123456789 1........ | 123456789 123456789 .2....... | .....6... ..3...... ........9 |
	## | ..3...... 123456789 ....5.... | 1........ ........9 123456789 | .2....... 123456789 123456789 |
	##  ----------------------------------------------------------------------------------------------- 
	## 45

	la $a0, easyboard2
	jal count_solved_cells
	move $s0, $v0
	la $a0, easyboard2
	jal print_board
	move $a0, $s0
	jal print_int
	jal print_newline
	jal print_newline

	##
	## Testing solve_board
	##
	
	la $a0, solve_board_test_msg
	jal print_string
	jal print_newline
	jal print_newline

	## should print:
	##  ----------------------------------------------------------------------------------------------- 
	## | 123456789 .......8. 123456789 | ....5.... .....6... 123456789 | 123456789 ...4..... 123456789 |
	## | 123456789 ....5.... ..3...... | 123456789 123456789 .2....... | 123456789 ........9 123456789 |
	## | .2....... ......7.. 123456789 | .......8. 1........ 123456789 | 123456789 ..3...... .....6... |
	##  ----------------------------------------------------------------------------------------------- 
	## | ...4..... 123456789 123456789 | 123456789 123456789 123456789 | ......7.. .2....... ....5.... |
	## | .......8. ..3...... .....6... | 123456789 123456789 123456789 | 123456789 123456789 123456789 |
	## | 123456789 123456789 ......7.. | 1........ ........9 ...4..... | 123456789 123456789 123456789 |
	##  ----------------------------------------------------------------------------------------------- 
	## | 123456789 123456789 ....5.... | 123456789 .2....... ......7.. | 1........ 123456789 .......8. |
	## | 1........ ........9 123456789 | .....6... 123456789 .......8. | 123456789 123456789 ...4..... |
	## | 123456789 .....6... 123456789 | ...4..... ..3...... 123456789 | 123456789 ....5.... .2....... |
	##  ----------------------------------------------------------------------------------------------- 
	##  ----------------------------------------------------------------------------------------------- 
	## | ........9 .......8. 1........ | ....5.... .....6... ..3...... | .2....... ...4..... ......7.. |
	## | .....6... ....5.... ..3...... | ......7.. ...4..... .2....... | .......8. ........9 1........ |
	## | .2....... ......7.. ...4..... | .......8. 1........ ........9 | ....5.... ..3...... .....6... |
	##  ----------------------------------------------------------------------------------------------- 
	## | ...4..... 1........ ........9 | ..3...... .......8. .....6... | ......7.. .2....... ....5.... |
	## | .......8. ..3...... .....6... | .2....... ......7.. ....5.... | ...4..... 1........ ........9 |
	## | ....5.... .2....... ......7.. | 1........ ........9 ...4..... | .....6... .......8. ..3...... |
	##  ----------------------------------------------------------------------------------------------- 
	## | ..3...... ...4..... ....5.... | ........9 .2....... ......7.. | 1........ .....6... .......8. |
	## | 1........ ........9 .2....... | .....6... ....5.... .......8. | ..3...... ......7.. ...4..... |
	## | ......7.. .....6... .......8. | ...4..... ..3...... 1........ | ........9 ....5.... .2....... |
	##  ----------------------------------------------------------------------------------------------- 
	la $a0, easyboard1
	jal print_board
	la $a0, easyboard1
	jal solve_board
	la $a0, easyboard1
	jal print_board
	jal print_newline
	jal print_newline
	
	## should print:
	##  ----------------------------------------------------------------------------------------------- 
	## | 123456789 1........ 123456789 | .2....... .....6... ........9 | 123456789 ...4..... 123456789 |
	## | 123456789 ........9 123456789 | 123456789 .......8. ..3...... | 1........ 123456789 ......7.. |
	## | 123456789 ....5.... ..3...... | 123456789 123456789 ...4..... | 123456789 .......8. .....6... |
	##  ----------------------------------------------------------------------------------------------- 
	## | 123456789 123456789 123456789 | .....6... .2....... .......8. | ......7.. 1........ 123456789 |
	## | 1........ .....6... .......8. | 123456789 123456789 123456789 | 123456789 ........9 .2....... |
	## | ....5.... ......7.. 123456789 | ........9 123456789 1........ | 123456789 123456789 .......8. |
	##  ----------------------------------------------------------------------------------------------- 
	## | .....6... 123456789 ........9 | ...4..... ..3...... 123456789 | .......8. 123456789 123456789 |
	## | 123456789 123456789 1........ | 123456789 123456789 .2....... | .....6... ..3...... ........9 |
	## | ..3...... 123456789 ....5.... | 1........ ........9 123456789 | .2....... 123456789 123456789 |
	##  ----------------------------------------------------------------------------------------------- 
	##  ----------------------------------------------------------------------------------------------- 
	## | .......8. 1........ ......7.. | .2....... .....6... ........9 | ....5.... ...4..... ..3...... |
	## | ...4..... ........9 .....6... | ....5.... .......8. ..3...... | 1........ .2....... ......7.. |
	## | .2....... ....5.... ..3...... | ......7.. 1........ ...4..... | ........9 .......8. .....6... |
	##  ----------------------------------------------------------------------------------------------- 
	## | ........9 ..3...... ...4..... | .....6... .2....... .......8. | ......7.. 1........ ....5.... |
	## | 1........ .....6... .......8. | ..3...... ......7.. ....5.... | ...4..... ........9 .2....... |
	## | ....5.... ......7.. .2....... | ........9 ...4..... 1........ | ..3...... .....6... .......8. |
	##  ----------------------------------------------------------------------------------------------- 
	## | .....6... .2....... ........9 | ...4..... ..3...... ......7.. | .......8. ....5.... 1........ |
	## | ......7.. ...4..... 1........ | .......8. ....5.... .2....... | .....6... ..3...... ........9 |
	## | ..3...... .......8. ....5.... | 1........ ........9 .....6... | .2....... ......7.. ...4..... |
	##  ----------------------------------------------------------------------------------------------- 
	la $a0, easyboard2
	jal print_board
	la $a0, easyboard2
	jal solve_board
	la $a0, easyboard2
	jal print_board
	jal print_newline
	jal print_newline

	lw $ra, 0($sp)
	lw $s0, 4($sp)
	addi $sp, $sp, 8
	jr $ra
	
# a0: pointer to board
# a1: pointer to solved cell
rule_out_of_row:
	addi $sp, $sp, -20
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	
	move $s0, $a0    # s0: pointer to board
 	move $s1, $a1    # s1: pointer to solved cell
	move $a0, $s1    # s2: value of solved cell
 	jal first_candidate
 	move $s2, $v0
	move $a0, $s0    # s3: pointer to base of row
	move $a1, $s1
	jal get_row_base
	move $s3, $v0

	# rule out of each cell in the row
 	addi $a0, $s3, 0
	beq $a0, $s1, rule_out_of_row_cell1
 	move $a1, $s2
 	jal rule_out_of_cell
rule_out_of_row_cell1:	
 	addi $a0, $s3, 10
	beq $a0, $s1, rule_out_of_row_cell2
 	move $a1, $s2
 	jal rule_out_of_cell
rule_out_of_row_cell2:	
 	addi $a0, $s3, 20
	beq $a0, $s1, rule_out_of_row_cell3
 	move $a1, $s2
 	jal rule_out_of_cell
rule_out_of_row_cell3:	
 	addi $a0, $s3, 30
	beq $a0, $s1, rule_out_of_row_cell4
 	move $a1, $s2
 	jal rule_out_of_cell
rule_out_of_row_cell4:	
 	addi $a0, $s3, 40
	beq $a0, $s1, rule_out_of_row_cell5
 	move $a1, $s2
 	jal rule_out_of_cell
rule_out_of_row_cell5:	
 	addi $a0, $s3, 50
	beq $a0, $s1, rule_out_of_row_cell6
 	move $a1, $s2
 	jal rule_out_of_cell
rule_out_of_row_cell6:	
 	addi $a0, $s3, 60
	beq $a0, $s1, rule_out_of_row_cell7
 	move $a1, $s2
 	jal rule_out_of_cell
rule_out_of_row_cell7:	
 	addi $a0, $s3, 70
	beq $a0, $s1, rule_out_of_row_cell8
 	move $a1, $s2
 	jal rule_out_of_cell
rule_out_of_row_cell8:	
 	addi $a0, $s3, 80
	beq $a0, $s1, rule_out_of_row_exit
 	move $a1, $s2
 	jal rule_out_of_cell
	
rule_out_of_row_exit:	
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	addi $sp, $sp, 20
	jr $ra

# a0: pointer to board
# a1: pointer to solved cell
rule_out_of_col:
	addi $sp, $sp, -20
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	
	move $s0, $a0          # s0: pointer to board
 	move $s1, $a1          # s1: pointer to solved cell
	move $a0, $s1          # s2: value of solved cell
 	jal first_candidate
 	move $s2, $v0
	move $a0, $s0          # s3: pointer to base of col
	move $a1, $s1
	jal get_col_base
	move $s3, $v0

	# rule out of each cell in the row
 	addi $a0, $s3, 0
	beq $a0, $s1, rule_out_of_col_cell1
 	move $a1, $s2
 	jal rule_out_of_cell
rule_out_of_col_cell1:	
 	addi $a0, $s3, 90
	beq $a0, $s1, rule_out_of_col_cell2
 	move $a1, $s2
 	jal rule_out_of_cell
rule_out_of_col_cell2:	
 	addi $a0, $s3, 180
	beq $a0, $s1, rule_out_of_col_cell3
 	move $a1, $s2
 	jal rule_out_of_cell
rule_out_of_col_cell3:	
 	addi $a0, $s3, 270
	beq $a0, $s1, rule_out_of_col_cell4
 	move $a1, $s2
 	jal rule_out_of_cell
rule_out_of_col_cell4:	
 	addi $a0, $s3, 360
	beq $a0, $s1, rule_out_of_col_cell5
 	move $a1, $s2
 	jal rule_out_of_cell
rule_out_of_col_cell5:	
 	addi $a0, $s3, 450
	beq $a0, $s1, rule_out_of_col_cell6
 	move $a1, $s2
 	jal rule_out_of_cell
rule_out_of_col_cell6:	
 	addi $a0, $s3, 540
	beq $a0, $s1, rule_out_of_col_cell7
 	move $a1, $s2
 	jal rule_out_of_cell
rule_out_of_col_cell7:	
 	addi $a0, $s3, 630
	beq $a0, $s1, rule_out_of_col_cell8
 	move $a1, $s2
 	jal rule_out_of_cell
rule_out_of_col_cell8:	
 	addi $a0, $s3, 720
	beq $a0, $s1, rule_out_of_col_exit
 	move $a1, $s2
 	jal rule_out_of_cell
	
rule_out_of_col_exit:	
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	addi $sp, $sp, 20
	jr $ra


# a0: pointer to board
# a1: pointer to solved cell
rule_out_of_box:
	addi $sp, $sp, -20
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	
	move $s0, $a0         # s0: pointer to board
 	move $s1, $a1         # s1: pointer to solved cell
	move $a0, $s1         # s2: value of solved cell
 	jal first_candidate
 	move $s2, $v0 
	move $a0, $s0         # s3: pointer to base of box
	move $a1, $s1
	jal get_box_base
	move $s3, $v0

	# rule out of each cell in the box
 	addi $a0, $s3, 0
	beq $a0, $s1, rule_out_of_box_cell1
 	move $a1, $s2
 	jal rule_out_of_cell
rule_out_of_box_cell1:	
 	addi $a0, $s3, 10
	beq $a0, $s1, rule_out_of_box_cell2
 	move $a1, $s2
 	jal rule_out_of_cell
rule_out_of_box_cell2:	
 	addi $a0, $s3, 20
	beq $a0, $s1, rule_out_of_box_cell3
 	move $a1, $s2
 	jal rule_out_of_cell
rule_out_of_box_cell3:	
 	addi $a0, $s3, 90
	beq $a0, $s1, rule_out_of_box_cell4
 	move $a1, $s2
 	jal rule_out_of_cell
rule_out_of_box_cell4:	
 	addi $a0, $s3, 100
	beq $a0, $s1, rule_out_of_box_cell5
 	move $a1, $s2
 	jal rule_out_of_cell
rule_out_of_box_cell5:	
 	addi $a0, $s3, 110
	beq $a0, $s1, rule_out_of_box_cell6
 	move $a1, $s2
 	jal rule_out_of_cell
rule_out_of_box_cell6:	
 	addi $a0, $s3, 180
	beq $a0, $s1, rule_out_of_box_cell7
 	move $a1, $s2
 	jal rule_out_of_cell
rule_out_of_box_cell7:	
 	addi $a0, $s3, 190
	beq $a0, $s1, rule_out_of_box_cell8
 	move $a1, $s2
 	jal rule_out_of_cell
rule_out_of_box_cell8:	
 	addi $a0, $s3, 200
	beq $a0, $s1, rule_out_of_box_exit
 	move $a1, $s2
 	jal rule_out_of_cell
	
rule_out_of_box_exit:	
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	addi $sp, $sp, 20
	jr $ra
	

# a0: pointer to board
# a1: pointer to cell
# v0: pointer to base of col containing cell 
get_col_base:
	# t0: cell offset in board
	sub $t0, $a1, $a0
	# t1: col offset, i.e., cell offset % 90
	li $t1, 90
	rem $t1, $t0, $t1
	# v0: pointer to base of col, i.e., board + col offset
	add $v0, $a0, $t1
	jr $ra

# a0: pointer to board
# a1: pointer to cell
# v0: pointer to base of row containing cell 
get_row_base:
	# t0: cell offset in board
	sub $t0, $a1, $a0
	# t1: row offset in board, i.e., cell offset - (cell offset % 90)
	li $t1, 90
	rem $t1, $t0, $t1
	sub $t1, $t0, $t1
	# v0: pointer to base of row, i.e., board + row offset
	add $v0, $a0, $t1
	jr $ra

# a0: pointer to board
# a1: pointer to cell
# v0: pointer to base of box containing cell 
get_box_base:
	# t0: cell offset in board
	sub $t0, $a1, $a0
	# t1: t0 % 270
	li $t1, 270
	rem $t1, $t0, $t1
	# t2: t0 % 90
	li $t2, 90
	rem $t2, $t0, $t2
	# t3: t0 % 30
	li $t3, 30
	rem $t3, $t0, $t3
	# t4: offset of cell in box, i.e., (t1 - t2) + t3
	sub $t4, $t1, $t2
	add $t4, $t4, $t3
	# v0: pointer to base of box, i.e., cell - offset of cell in box
	sub $v0, $a1, $t4
	jr $ra
	

# a0: pointer to board
print_board:
	addi $sp, $sp, -16
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)

	move $s0, $a0          # s0: pointer to board
	addi $s1, $a0, 810     # s1: end of board
	move $s2, $a0	       # s2: current cell
print_board_top:
	# t1: cell offset
	# if cell offset % 270 == 0, print hsep
	sub $t1, $s2, $s0
	li $t0, 270
	rem $t0, $t1, $t0
	bnez $t0, print_board_skip_hsep
	jal print_hsep
	jal print_newline
print_board_skip_hsep:
	# check to see if end of board
	beq $s2, $s1, print_board_exit
	# if cell offset % 30 == 0, print vsep
	li $t0, 30
	rem $t0, $t1, $t0
	bnez $t0, print_board_skip_vsep
	jal print_vsep
	jal print_space
print_board_skip_vsep:
	# print cell
	move $a0, $s2
	jal print_string
	jal print_space
	# if cell offset % 90 == 80, print another vsep and newline
	li $t0, 90
	rem $t0, $t1, $t0
	li $t1, 80
	bne $t0, $t1, print_board_skip_second_vsep
	jal print_vsep
	jal print_newline
print_board_skip_second_vsep:
	# advance cell pointer and repeat
	addi $s2, $s2, 10
	b print_board_top

print_board_exit:	
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	addi $sp, $sp, 16
	jr $ra

# a0: pointer to cell
# v0: 1 if cell solved, 0 otherwise
is_cell_solved:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	# get number of candidates
	jal num_candidates
	# if num candidates, is one, cell is solved
	li $t0, 1	
	beq $v0, $t0, is_cell_solved_true
	b is_cell_solved_false
is_cell_solved_true:
	li $v0, 1
	b is_cell_solved_exit
is_cell_solved_false:
	li $v0, 0
is_cell_solved_exit:	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
# a0: pointer to cell
# v0: value of first possible digit (if no candidates, returns 0)
first_candidate:
	# v0: value of digit checking
	li $v0, 1
	# keep ascii code for eliminated digit handy
	li $t1, 46
first_candidate_top:
	# t0: pointer to char (a0 + v0 - 1)
	add $t0, $a0, $v0
	addi $t0, $t0, -1
	# load char
	lbu $t0, 0($t0)
	# if end of string, exit having found no viable digits
	beqz $t0, first_candidate_none_found
	# if curr digit not viable (already eliminated), move on to next digit
	beq $t0, $t1, first_candidate_advance
	# else, this is a viable digit, exit
	jr $ra
first_candidate_advance:	
	addi $v0, $v0, 1
	b first_candidate_top
first_candidate_none_found:
	li $v0, 0	
	jr $ra

# prints | 	
print_vsep:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	la $a0, vsep
	jal print_string
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

# prints horizontal line	
print_hsep:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	la $a0, hsep
	jal print_string
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

print_newline:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	la $a0, newline
	jal print_string
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

print_space:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	la $a0, space
	jal print_string
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

# a0: integer to print	
print_int:
	li $v0, 1
	syscall
	jr $ra

# a0: string to print	
print_string:	
	li $v0, 4
	syscall
	jr $ra
	
.data

newline:	.asciiz "\n"
vsep:   	.asciiz "|"
hsep:   	.asciiz " ----------------------------------------------------------------------------------------------- "
space:		.asciiz " "

testcell1:	.asciiz "123456789"
testcell2:	.asciiz "1.34.6789"
testcell3:	.asciiz ".2.4.6.8."
testcell4:	.asciiz ".....67.."
testcell5:	.asciiz "........."
	
num_candidates_test_msg:	.asciiz "*** Testing num_candidates ***"
rule_out_of_cell_test_msg:	.asciiz "*** Testing rule_out_of_cell ***"
count_solved_cells_test_msg:	.asciiz "*** Testing count_solved_cells ***"
solve_board_test_msg:		.asciiz "*** Testing solve_board ***"
	
easyboard1:
.asciiz "123456789"
.asciiz ".......8."
.asciiz "123456789"
.asciiz "....5...."
.asciiz ".....6..."
.asciiz "123456789"
.asciiz "123456789"
.asciiz "...4....."
.asciiz "123456789"
.asciiz "123456789"
.asciiz "....5...."
.asciiz "..3......"
.asciiz "123456789"
.asciiz "123456789"
.asciiz ".2......."
.asciiz "123456789"
.asciiz "........9"
.asciiz "123456789"
.asciiz ".2......."
.asciiz "......7.."
.asciiz "123456789"
.asciiz ".......8."
.asciiz "1........"
.asciiz "123456789"
.asciiz "123456789"
.asciiz "..3......"
.asciiz ".....6..."
.asciiz "...4....."
.asciiz "123456789"
.asciiz "123456789"
.asciiz "123456789"
.asciiz "123456789"
.asciiz "123456789"
.asciiz "......7.."
.asciiz ".2......."
.asciiz "....5...."
.asciiz ".......8."
.asciiz "..3......"
.asciiz ".....6..."
.asciiz "123456789"
.asciiz "123456789"
.asciiz "123456789"
.asciiz "123456789"
.asciiz "123456789"
.asciiz "123456789"
.asciiz "123456789"
.asciiz "123456789"
.asciiz "......7.."
.asciiz "1........"
.asciiz "........9"
.asciiz "...4....."
.asciiz "123456789"
.asciiz "123456789"
.asciiz "123456789"
.asciiz "123456789"
.asciiz "123456789"
.asciiz "....5...."
.asciiz "123456789"
.asciiz ".2......."
.asciiz "......7.."
.asciiz "1........"
.asciiz "123456789"
.asciiz ".......8."
.asciiz "1........"
.asciiz "........9"
.asciiz "123456789"
.asciiz ".....6..."
.asciiz "123456789"
.asciiz ".......8."
.asciiz "123456789"
.asciiz "123456789"
.asciiz "...4....."
.asciiz "123456789"
.asciiz ".....6..."
.asciiz "123456789"
.asciiz "...4....."
.asciiz "..3......"
.asciiz "123456789"
.asciiz "123456789"
.asciiz "....5...."
.asciiz ".2......."

easyboard2:
.asciiz "123456789"
.asciiz "1........"
.asciiz "123456789"
.asciiz ".2......."
.asciiz ".....6..."
.asciiz "........9"
.asciiz "123456789"
.asciiz "...4....."
.asciiz "123456789"
.asciiz "123456789"
.asciiz "........9"
.asciiz "123456789"
.asciiz "123456789"
.asciiz ".......8."
.asciiz "..3......"
.asciiz "1........"
.asciiz "123456789"
.asciiz "......7.."
.asciiz "123456789"
.asciiz "....5...."
.asciiz "..3......"
.asciiz "123456789"
.asciiz "123456789"
.asciiz "...4....."
.asciiz "123456789"
.asciiz ".......8."
.asciiz ".....6..."
.asciiz "123456789"
.asciiz "123456789"
.asciiz "123456789"
.asciiz ".....6..."
.asciiz ".2......."
.asciiz ".......8."
.asciiz "......7.."
.asciiz "1........"
.asciiz "123456789"
.asciiz "1........"
.asciiz ".....6..."
.asciiz ".......8."
.asciiz "123456789"
.asciiz "123456789"
.asciiz "123456789"
.asciiz "123456789"
.asciiz "........9"
.asciiz ".2......."
.asciiz "....5...."
.asciiz "......7.."
.asciiz "123456789"
.asciiz "........9"
.asciiz "123456789"
.asciiz "1........"
.asciiz "123456789"
.asciiz "123456789"
.asciiz ".......8."
.asciiz ".....6..."
.asciiz "123456789"
.asciiz "........9"
.asciiz "...4....."
.asciiz "..3......"
.asciiz "123456789"
.asciiz ".......8."
.asciiz "123456789"
.asciiz "123456789"
.asciiz "123456789"
.asciiz "123456789"
.asciiz "1........"
.asciiz "123456789"
.asciiz "123456789"
.asciiz ".2......."
.asciiz ".....6..."
.asciiz "..3......"
.asciiz "........9"
.asciiz "..3......"
.asciiz "123456789"
.asciiz "....5...."
.asciiz "1........"
.asciiz "........9"
.asciiz "123456789"
.asciiz ".2......."
.asciiz "123456789"
.asciiz "123456789"
	
