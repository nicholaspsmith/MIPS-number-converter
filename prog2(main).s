####
## Nicholas Smith
## CSC 252 Rich Saunders
## March 20, 2013
####

.data

prompt:
	.asciiz "Please input a number to print, the base, and the width of the field:\n"
newline:
	.asciiz "\n"
	
	#save current stack pointer and return it at end
.text
	
main:
	# Main Prologue
	addiu	$sp, $sp, -24	# allocate stack space
	sw	$fp, 0($sp)	# save fp to temp space
	sw	$ra, 4($sp)	# save return address
	addiu	$fp, $sp, 20	# adjust to new fp
	
	# Print out prompt
	la	$a0, prompt
	li	$v0, 4
	syscall
	
	#get three values save into a0 a1 a2
	
	# Get first value
	addi	$v0, $zero, 5		#syscall 5 (read_int)
	syscall
	add	$s0, $v0, $zero		# s0 = number to convert (will move to a0 later)
	
	# Get second value
	addi	$v0, $zero, 5		#syscall 5 (read_int)
	syscall
	add	$a1, $v0, $zero		# a1 = base
	
	# Get third value
	addi	$v0, $zero, 5		#syscall 5 (read_int)
	syscall
	add	$a2, $v0, $zero		# a2 = width
	
	# Move first value to a0
	add	$a0, $s0, $zero 	# a0 = number to convert
	

	
	# Call subroutine
	jal baseprint

	
	# Main Epilogue
	lw	$ra, 4($sp)
	lw	$fp, 0($sp)
	addiu	$sp, $sp, 24
	jr	$ra
	



	
baseprint:

	# Subroutine Prologue
	addiu	$sp, $sp, -32
	sw	$fp, 0($sp)
	sw	$ra, 4($sp)
	sw	$a0, 8($sp)
	sw	$a1, 12($sp)
	sw	$a2, 16($sp)
	sw	$a3, 20($sp)
	add	$fp, $sp, 28
	
	# Save all S registers
	addiu	$sp, $sp, -32
	sw		$s7, 28($sp)
	sw		$s6, 24($sp)
	sw		$s5, 20($sp)
	sw		$s4, 16($sp)
	sw		$s3, 12($sp)
	sw		$s2, 8($sp)
	sw		$s1, 4($sp)
	sw		$s0, 0($sp)

	
	# Move arguments to s registers
	add	$s0, $a0, $zero	# s0 is number to convert
	add	$s1, $a1, $zero # s1 is the base
	add	$s2, $a2, $zero # s2 is the width
	
	# Is the number negative?
	bgt	$s0, $zero, s_not_negative
	
	# If so, convert to positive
	# flip bits
	nor	$s0, $s0, $zero
	# add 1
	addi	$s0, $s0, 1
	
	#store a 1 in t5 so we know to add a "-" to stack when appropriate
	addi	$t5, $zero, 1
s_not_negative:
	
	
	# Initialize a counter variable
	addi	$t8, $zero, 0
	
	
	# if s1 < 11 is false, print all stars
	slti	$t9, $s1, 11
	beq		$t9, $zero, s_print_all_stars
	# if s1 < 2, print all stars
	slti	$t9, $s1, 2
	bne		$t9, $zero, s_print_all_stars
	
	
	
s_divide:
	div	$s0, $s1
	# t0 = s0 / s1   --> our new number
	mflo	$t0
	# t1 = s0 % s1   --> put this on stack
	mfhi	$t1
	
	# is s0 > s1?
	blt	$s0, $s1, s_base_smaller
	
	
	j s_push_to_stack
s_base_smaller:	
	# base is smaller, we add s0 to stack
	add	$t1, $zero, $s0
s_push_to_stack:
	# allocate stack space
	addiu	$sp, $sp, -4
	# save number to stack
	sw	$t1, 0($sp)
	# i++
	addi	$t8, $t8, 1
	
	# t7 is the length of our answer plus a +/- sign
	addi	$t7, $t8, 1
	
	# is (s0/s1) < 1? 
	slti	$t9, $t0, 1
	# do we need to print any stars?
	# is s2 > t7(actual length of answer)
	bne	$t9, $zero, s_print
	
	# s0 = s0 / s1 
	add	$s0, $zero, $t0
#############
	bgt	$t7, $s2, s_print_all_stars
	beq	$t7, $s2, s_print_all_stars
	# if so, print all stars
	
	j s_divide
	
s_print:
	bgt	$s2, $t8, s_print_stars  # use t7 or t8 here   ???
	
s_print_nums:
	# if t3 is 1, we have already printed +/-
	bne	$t3, $zero, s_sign_printed
	# print + or -
	# if t5 is 1, we need to print a "-" otherwise print a "+"
	bgt	$t5, $zero, s_print_negative
	# Print a +
	li	$a0, '+'
	li	$v0, 11
	syscall
	addi	$t3, $zero, 1
	j s_sign_printed
s_print_negative:
	# Print a -
	li	$a0, '-'
	li	$v0, 11
	syscall
	addi	$t3, $zero, 1
	
s_sign_printed:

	

	# print number
	lw	$a0, 0($sp)
	li	$v0, 1
	syscall
	# shrink stack
	addiu	$sp, $sp, 4
	# i--
	addi	$t8, $t8, -1
	# if counter = 0, we're done
	beq		$t8, $zero, s_done
	j	s_print_nums
	
s_print_stars:
	# t4 = number width - actual width - 1
	# this is the number of stars we need to print
	# t7 is the size of our number + 1
	sub	$t4, $s2, $t7

s_print_stars_loop:	
	# t4 = number of stars to print
	# is t4 = 0?  print number
	beq	$t4, $zero, s_print_nums
	
	# Print a *
	li	$a0, '*'
	li	$v0, 11
	syscall
		
	
	# t4--
	addi	$t4, $t4, -1
	
	j	s_print_stars_loop
	
s_print_all_stars:

	# Print out *
	li	$a0, '*'
	li	$v0, 11
	syscall
	# decrement s2
	addi	$s2, $s2, -1
	# check s2
	beq	$s2, $zero, s_done
	j s_print_all_stars
	
s_done:

	# Restore all S registers
	lw	$s7, 28($sp)
	lw	$s6, 24($sp)
	lw	$s5, 20($sp)
	lw	$s4, 16($sp)
	lw	$s3, 12($sp)
	lw	$s2, 8($sp)
	lw	$s1, 4($sp)
	lw	$s0, 0($sp)
	addiu	$sp, $sp, 32
	

	# Subroutine Epilogue
	lw	$ra, 4($sp)
	lw	$fp, 0($sp)
	addiu	$sp, $sp, 32
	jr	$ra
